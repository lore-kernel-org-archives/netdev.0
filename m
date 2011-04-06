From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] ipv6: Enable RFS sk_rxhash tracking for ipv6 sockets
Date: Wed, 6 Apr 2011 14:39:13 -0400
Message-ID: <20110406183913.GB6825@hmsreliant.think-freely.org>
References: <1302112465-6842-1-git-send-email-nhorman@tuxdriver.com>
 <1302113253.3209.126.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40066 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756228Ab1DFSjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 14:39:17 -0400
Content-Disposition: inline
In-Reply-To: <1302113253.3209.126.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 06, 2011 at 08:07:33PM +0200, Eric Dumazet wrote:
> Le mercredi 06 avril 2011 =E0 13:54 -0400, Neil Horman a =E9crit :
>=20
> > diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> > index d7037c0..aa3e327 100644
> > --- a/net/ipv6/udp.c
> > +++ b/net/ipv6/udp.c
> > @@ -505,6 +505,8 @@ int udpv6_queue_rcv_skb(struct sock * sk, struc=
t sk_buff *skb)
> >  	int rc;
> >  	int is_udplite =3D IS_UDPLITE(sk);
> > =20
> > +	sock_rps_save_rxhash(sk, skb->rxhash);
> > +
> >  	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
> >  		goto drop;
> > =20
>=20
> Problem is every packet received might have a different rxhash if
> multiple senders are active.=20
>=20
> This can hurt performance (cache misses on RFS table) on a DNS server
> workload for example.
>=20
> This is why we used on ipv4 :
>=20
> if (inet_sk(sk)->inet_daddr)
> 	sock_rps_save_rxhash(sk, skb->rxhash);
>=20
Ok, I can absolutely do that, I'll respin shortly.  Just to make sure I
understand how to do this, the ipv6 equivalant of inet_daddr is
inet6_sk(sk)->daddr, correct? I ask because the above v4 equivalent is =
stored in
the sk_common struct, and I want to make sure I'm testing the right dat=
a.=20

Also, do we have a macro already to see if an ipv6 address is all zeros=
?  I'm
not finding one, but I'd hate to re-invent the wheel if I'm just missin=
g it.

>=20
> Only arm RFS on UDP if socket is bound to a given remote peer.
>=20
> BTW you forgot Tom Herbert. (I added him in CC)
Thanks, sorry Tom, Just took the output of get_maintainers.pl without c=
hecking
all the results.
Neil

>=20
>=20
>=20
>=20
