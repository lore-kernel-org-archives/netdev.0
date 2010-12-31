From: Stefani Seibold <stefani@seibold.net>
Subject: Re: [PATCH] UDPCP Communication Protocol
Date: Fri, 31 Dec 2010 11:22:59 +0100
Message-ID: <1293790979.4787.10.camel@wall-e>
References: <1293787785-3834-1-git-send-email-stefani@seibold.net>
	 <1293789629.2973.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293789629.2973.26.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Freitag, den 31.12.2010, 11:00 +0100 schrieb Eric Dumazet:
> Le vendredi 31 d=E9cembre 2010 =E0 10:29 +0100, stefani@seibold.net a
> =E9crit :
> > From: Stefani Seibold <stefani@seibold.net>
> >=20
> > =20
> >  /*
> >   *	Handle MSG_ERRQUEUE
> > diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> > index 2d3ded4..f9890a2 100644
> > --- a/net/ipv4/udp.c
> > +++ b/net/ipv4/udp.c
> > @@ -1310,7 +1310,7 @@ static int __udp_queue_rcv_skb(struct sock *s=
k, struct sk_buff *skb)
> >  	if (inet_sk(sk)->inet_daddr)
> >  		sock_rps_save_rxhash(sk, skb->rxhash);
> > =20
> > -	rc =3D ip_queue_rcv_skb(sk, skb);
> > +	rc =3D sock_queue_rcv_skb(sk, skb);
>=20
> Ouch... Care to explain why you changed this part ???
>=20
> You just destroyed commit f84af32cbca70a intent, without any word in
> your changelog. Making UDP slower, while others try to speed it must =
be
> explained and advertised.
> =20
> In general, we prefer a preliminary patch introducing all the changes=
 in
> current stack, then another one with the new protocol.
>=20

I reverted this for two reasons:

=46irst ip_queue_rcv_skb drops the dst entry, which breaks the user lan=
d
application which expect packet info after a

setsockopt(handle, IPPROTO_IP, IP_PKTINFO, &const_int_1, sizeof(int));

But for packets already in the queue this information will be lost. So
it is a potential race condition.

Second it breaks my UDPCP communication protocol stack module, which
works very well till 2.6.35. I need this information in the data_ready(=
)
function to generate an ACK.
