From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: NAT regression in next tree
Date: Fri, 19 Feb 2010 10:11:27 -0800
Message-ID: <20100219101127.462f5fe2@nehalam>
References: <20100216173658.519b6245@nehalam>
	<201002171526.02493.arnd@arndb.de>
	<20100218173633.30bb8c41@nehalam>
	<4B7E2587.3050608@trash.net>
	<20100218215106.557be6b0@nehalam>
	<4B7E386E.4070502@trash.net>
	<1266564056.2877.15.camel@edumazet-laptop>
	<4B7E3D65.2030203@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B7E3D65.2030203@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 19 Feb 2010 08:27:33 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Eric Dumazet wrote:
> > Le vendredi 19 f=C3=A9vrier 2010 =C3=A0 08:06 +0100, Patrick McHard=
y a =C3=A9crit :
> >>     netfilter: restore POST_ROUTING hook in NF_HOOK_COND
> >>    =20
> >>     Commit 2249065 ("netfilter: get rid of the grossness in netfil=
ter.h")
> >>     inverted the logic for conditional hook invocation, breaking t=
he
> >>     POST_ROUTING hook invoked by ip_output().
> >>    =20
> >>     Correct the logic and remove an unnecessary initialization.
> >>    =20
> >>     Reported-by: Stephen Hemminger <shemminger@vyatta.com>
> >>     Signed-off-by: Patrick McHardy <kaber@trash.net>
> >>
> >> diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
> >> index 7007945..89341c3 100644
> >> --- a/include/linux/netfilter.h
> >> +++ b/include/linux/netfilter.h
> >> @@ -212,8 +212,9 @@ NF_HOOK_COND(uint8_t pf, unsigned int hook, st=
ruct sk_buff *skb,
> >>  	     struct net_device *in, struct net_device *out,
> >>  	     int (*okfn)(struct sk_buff *), bool cond)
> >>  {
> >> -	int ret =3D 1;
> >> -	if (cond ||
> >> +	int ret;
> >> +
> >> +	if (!cond ||
> >>  	    (ret =3D nf_hook_thresh(pf, hook, skb, in, out, okfn, INT_MI=
N) =3D=3D 1))
> >>  		ret =3D okfn(skb);
> >>  	return ret;
> >=20
> > I dont quite get it
> >=20
> > Original code was :
> >=20
> >=20
> > #define NF_HOOK_COND(pf, hook, skb, indev, outdev, okfn, cond)     =
           \
> > ({int __ret;                                                       =
           \
> > if ((cond) || (__ret =3D nf_hook_thresh(pf, hook, (skb), indev, out=
dev, okfn, INT_MIN)) =3D=3D 1)\
> >        __ret =3D (okfn)(skb);                                      =
             \
> > __ret;})
> >=20
> >=20
> > There was no condition inversion.
>=20
> Right, I quoted the wrong patch, it was actually broken in
> 23f3733 ("netfilter: reduce NF_HOOK by one argument"), which
> moved the cond check from nf_hook_thresh() to NF_HOOK_COND().

Yes, this fixes the problem I was seeing.

Acked-by: Stephen Hemminger <shemminger@vyatta.com>

--=20
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
