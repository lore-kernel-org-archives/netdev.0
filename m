From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: force a fresh timestamp for ingress
	packets
Date: Fri, 17 Dec 2010 07:30:15 +0000
Message-ID: <20101217073015.GA6907@ff.dom.local>
References: <1292428252.3427.342.camel@edumazet-laptop> <20101216211744.GA2191@del.dom.local> <1292535039.2655.13.camel@edumazet-laptop> <20101216220838.GB2191@del.dom.local> <1292538363.2655.20.camel@edumazet-laptop> <20101216224237.GC2191@del.dom.local> <1292542305.2655.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:44666 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869Ab0LQHaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 02:30:22 -0500
Received: by fxm18 with SMTP id 18so374604fxm.2
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 23:30:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1292542305.2655.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 17, 2010 at 12:31:45AM +0100, Eric Dumazet wrote:
> Le jeudi 16 d=E9cembre 2010 ?? 23:42 +0100, Jarek Poplawski a =E9crit=
 :
> > On Thu, Dec 16, 2010 at 11:26:03PM +0100, Eric Dumazet wrote:
> > > Le jeudi 16 d=E9cembre 2010 ?? 23:08 +0100, Jarek Poplawski a =E9=
crit :
> > >=20
> > > > Hmm... Do you expect more people start debugging SFQ or I misse=
d your
> > > > point? ;-) Maybe such a change would be reasonable on a cloned =
skb?
> > >=20
> > > My point was to permit an admin to check his ingress shaping work=
s or
> > > not. In this respect, netem was a specialization of a general pro=
blem.
> > >=20
> > > We had a prior discussion on timestamping skb in RX path, when RP=
S came
> > > in : Should we take timestamp before RPS or after. At that time w=
e added
> > > a sysctl. Not sure it was the right choice :-(
> > >=20
> > > I feel tcpdump (on TX side) should really display time of packet =
right
> > > before being given to device, but this is probably a matter of ta=
ste.
> >=20
> > It might be reasonable unless it changes data for later users. That=
's
> > why I mentioned cloning.
> >=20
> > >=20
> > > Before commit 8caf153974f2 (net: sch_netem: Fix an inconsistency =
in
> > > ingress netem timestamps.), this is what was done.
> >=20
> > Then why don't you try to let turn it off in netem, where it only
> > matters?

=46orget this advice - I lost the point how you tested that.

> Because, if you read again my patch, you'll see :
>=20
> #ifdef CONFIG_NET_CLS_ACT
>        if (!skb->tstamp.tv64 || (G_TC_FROM(skb->tc_verd) & AT_INGRESS=
))
>                 net_timestamp_set(skb);
> #else
>=20
> So :=20
>=20
> If we are handling an INGRESS packet, we force a timestamp renew.

It is wrong because it brings back the inconsistency with ping etc.
described by Alex Sidorenko in the changelog of netem patch, but
use normal (not netem) ingress scheduling (ping results shouldn't
depend on sniffers).

>=20
> Therefore :
>=20
> We dont need in netem_dequeue() to force :
>=20
> -#ifdef CONFIG_NET_CLS_ACT
> -                       /*
> -                        * If it's at ingress let's pretend the delay=
 is
> -                        * from the network (tstamp will be updated).
> -                        */
> -                       if (G_TC_FROM(skb->tc_verd) & AT_INGRESS)
> -                               skb->tstamp.tv64 =3D 0;
> -#endif
>=20
> Since :
>=20
> We are going to renew timestamp anyway.
>=20
> Conclusion :
>=20
> I am eliminating dead code.
>=20
> Is that OK ?

Not to me.

Thanks,
Jarek P.
