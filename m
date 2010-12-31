From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] UDPCP Communication Protocol
Date: Fri, 31 Dec 2010 11:41:06 +0100
Message-ID: <1293792066.2973.43.camel@edumazet-laptop>
References: <1293787785-3834-1-git-send-email-stefani@seibold.net>
	 <1293789629.2973.26.camel@edumazet-laptop>
	 <1293790979.4787.10.camel@wall-e>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Stefani Seibold <stefani@seibold.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293790979.4787.10.camel@wall-e>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 31 d=C3=A9cembre 2010 =C3=A0 11:22 +0100, Stefani Seibold a=
 =C3=A9crit :
> Am Freitag, den 31.12.2010, 11:00 +0100 schrieb Eric Dumazet:
> > Le vendredi 31 d=C3=A9cembre 2010 =C3=A0 10:29 +0100, stefani@seibo=
ld.net a
> > =C3=A9crit :
> > > From: Stefani Seibold <stefani@seibold.net>
> > >=20
> > > =20
> > >  /*
> > >   *	Handle MSG_ERRQUEUE
> > > diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> > > index 2d3ded4..f9890a2 100644
> > > --- a/net/ipv4/udp.c
> > > +++ b/net/ipv4/udp.c
> > > @@ -1310,7 +1310,7 @@ static int __udp_queue_rcv_skb(struct sock =
*sk, struct sk_buff *skb)
> > >  	if (inet_sk(sk)->inet_daddr)
> > >  		sock_rps_save_rxhash(sk, skb->rxhash);
> > > =20
> > > -	rc =3D ip_queue_rcv_skb(sk, skb);
> > > +	rc =3D sock_queue_rcv_skb(sk, skb);
> >=20
> > Ouch... Care to explain why you changed this part ???
> >=20
> > You just destroyed commit f84af32cbca70a intent, without any word i=
n
> > your changelog. Making UDP slower, while others try to speed it mus=
t be
> > explained and advertised.
> > =20
> > In general, we prefer a preliminary patch introducing all the chang=
es in
> > current stack, then another one with the new protocol.
> >=20
>=20
> I reverted this for two reasons:
>=20
> First ip_queue_rcv_skb drops the dst entry, which breaks the user lan=
d
> application which expect packet info after a
>=20
> setsockopt(handle, IPPROTO_IP, IP_PKTINFO, &const_int_1, sizeof(int))=
;
>=20
> But for packets already in the queue this information will be lost. S=
o
> it is a potential race condition.
>=20

Exactly same race with packet filters.=20

If your life depends on that, you must flush incoming queue _after_
issuing setsockopt(handle, IPPROTO_IP, IP_PKTINFO, &const_int_1,
sizeof(int)). So that all following packets have the information needed=
=2E



> Second it breaks my UDPCP communication protocol stack module, which
> works very well till 2.6.35. I need this information in the data_read=
y()
> function to generate an ACK.
>=20
>=20

See now why you should not proceed like that ?

You know _perfectly_ there is a problem but prefer to keep it for you,
and hope this bit will be unnoticed ?

This is not how things are dealed in linux, really.

You'll have to find a way so that things work well for everybody, not
only for you.

I guess you must fix UDPCP protocol stack, not 'fix linux'
