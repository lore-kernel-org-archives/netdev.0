From: Stefani Seibold <stefani@seibold.net>
Subject: Re: [PATCH] UDPCP Communication Protocol
Date: Fri, 31 Dec 2010 12:23:09 +0100
Message-ID: <1293794589.5285.16.camel@wall-e>
References: <1293787785-3834-1-git-send-email-stefani@seibold.net>
	 <1293789629.2973.26.camel@edumazet-laptop>
	 <1293790979.4787.10.camel@wall-e>
	 <1293792066.2973.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www84.your-server.de ([213.133.104.84]:43488 "EHLO
	www84.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752919Ab0LaLWS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 06:22:18 -0500
In-Reply-To: <1293792066.2973.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, den 31.12.2010, 11:41 +0100 schrieb Eric Dumazet:
> Le vendredi 31 d=E9cembre 2010 =E0 11:22 +0100, Stefani Seibold a =E9=
crit :
> > Am Freitag, den 31.12.2010, 11:00 +0100 schrieb Eric Dumazet:
> > > Le vendredi 31 d=E9cembre 2010 =E0 10:29 +0100, stefani@seibold.n=
et a
> > > =E9crit :
> > > > From: Stefani Seibold <stefani@seibold.net>
> > > >=20
> > > > =20
> > > >  /*
> > > >   *	Handle MSG_ERRQUEUE
> > > > diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> > > > index 2d3ded4..f9890a2 100644
> > > > --- a/net/ipv4/udp.c
> > > > +++ b/net/ipv4/udp.c
> > > > @@ -1310,7 +1310,7 @@ static int __udp_queue_rcv_skb(struct soc=
k *sk, struct sk_buff *skb)
> > > >  	if (inet_sk(sk)->inet_daddr)
> > > >  		sock_rps_save_rxhash(sk, skb->rxhash);
> > > > =20
> > > > -	rc =3D ip_queue_rcv_skb(sk, skb);
> > > > +	rc =3D sock_queue_rcv_skb(sk, skb);
> > >=20
> > > Ouch... Care to explain why you changed this part ???
> > >=20
> > > You just destroyed commit f84af32cbca70a intent, without any word=
 in
> > > your changelog. Making UDP slower, while others try to speed it m=
ust be
> > > explained and advertised.
> > > =20
> > > In general, we prefer a preliminary patch introducing all the cha=
nges in
> > > current stack, then another one with the new protocol.
> > >=20
> >=20
> > I reverted this for two reasons:
> >=20
> > First ip_queue_rcv_skb drops the dst entry, which breaks the user l=
and
> > application which expect packet info after a
> >=20
> > setsockopt(handle, IPPROTO_IP, IP_PKTINFO, &const_int_1, sizeof(int=
));
> >=20
> > But for packets already in the queue this information will be lost.=
 So
> > it is a potential race condition.
> >=20
>=20
> Exactly same race with packet filters.=20
>=20
> If your life depends on that, you must flush incoming queue _after_
> issuing setsockopt(handle, IPPROTO_IP, IP_PKTINFO, &const_int_1,
> sizeof(int)). So that all following packets have the information need=
ed.
>=20
>=20

I though always that the linux kernel never breaks user land. This is a
break!

>=20
> > Second it breaks my UDPCP communication protocol stack module, whic=
h
> > works very well till 2.6.35. I need this information in the data_re=
ady()
> > function to generate an ACK.
> >=20
> >=20
>=20
> See now why you should not proceed like that ?
>=20
> You know _perfectly_ there is a problem but prefer to keep it for you=
,
> and hope this bit will be unnoticed ?
>=20

Stop to accuse me. There was a feature that was gone. An it took me six
hours to figure out whats going wrong. I did not saw and see a real
problem with this patch. It looked for me like an easy and clean
solution. It was never my intention to trick somebody, especially u.

> This is not how things are dealed in linux, really.
>=20
> You'll have to find a way so that things work well for everybody, not
> only for you.
>=20
> I guess you must fix UDPCP protocol stack, not 'fix linux'
>=20

I cannot fix it, because the information is still lost, and i need it.=20

In my opinion it was a very bad idea to throw away important
information. I checked it and Linux handle this since 2.6.0 in this way=
=2E

It would be better not to accuse than to work on a solution.=20

Question: How much performace gain does the early drop give. Are there
benchmark results?



