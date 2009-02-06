From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] udp: Fix potential wrong ip_hdr(skb) pointers
Date: Fri, 06 Feb 2009 11:04:50 +0100
Message-ID: <498C0B42.7080309@cosmosbay.com>
References: <1233838027.20497.132.camel@localhost.localdomain>	 <20090205.150612.208352009.davem@davemloft.net>	 <1233910824.21135.6.camel@localhost.localdomain>	 <20090206.010824.99072382.davem@davemloft.net> <1233914158.21135.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59568 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752277AbZBFKE7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 05:04:59 -0500
In-Reply-To: <1233914158.21135.11.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer a =E9crit :
> On Fri, 2009-02-06 at 01:08 -0800, David Miller wrote:
>> Please respin this patch of your's with proper commit message
>> and signoffs, thanks!
>=20
> Like the UDP header fix, pskb_may_pull() can potentially
> alter the SKB buffer.  Thus the saddr and daddr, pointers
> may point to the old skb->data buffer.
>=20

I dont know... daddr and saddr are not pointers but integers.

Patch makes sense as a cleanup, but ChangeLog seems wrong ?

> I haven't seen corruptions, as its only seen if the old
> skb->data buffer were reallocated by another user and
> written into very quickly (or poison'd by SLAB debugging).
>=20
> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
> ---
>=20
>  net/ipv4/udp.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
>=20
>=20
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index cc3a0a0..c47c989 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1234,8 +1234,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct =
udp_table *udptable,
>  	struct udphdr *uh;
>  	unsigned short ulen;
>  	struct rtable *rt =3D (struct rtable*)skb->dst;
> -	__be32 saddr =3D ip_hdr(skb)->saddr;
> -	__be32 daddr =3D ip_hdr(skb)->daddr;
> +	__be32 saddr, daddr;
>  	struct net *net =3D dev_net(skb->dev);
> =20
>  	/*
> @@ -1259,6 +1258,9 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct =
udp_table *udptable,
>  	if (udp4_csum_init(skb, uh, proto))
>  		goto csum_error;
> =20
> +	saddr =3D ip_hdr(skb)->saddr;
> +	daddr =3D ip_hdr(skb)->daddr;
> +
>  	if (rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST))
>  		return __udp4_lib_mcast_deliver(net, skb, uh,
>  				saddr, daddr, udptable);
>=20
>


