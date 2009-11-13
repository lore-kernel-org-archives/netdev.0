From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] vlan: GRO rx statistics
Date: Fri, 13 Nov 2009 17:41:21 +0100
Message-ID: <4AFD8C31.10703@gmail.com>
References: <4AF99A50.5080301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:51620 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752562AbZKMQlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 11:41:24 -0500
In-Reply-To: <4AF99A50.5080301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> It seems vlan interfaces with hardware-assisted VLAN reception=20
> dont have rx statistics.
>=20
> Following patch cures the problem for me but I have no idea
> if it is correct ?
>=20
> Another problem about all rx stats is about multi rx queues devices.
> Several cpus can access these counters in parallel ?
>=20
>=20
> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
> index 8d5ca2a..e13b007 100644
> --- a/net/8021q/vlan_core.c
> +++ b/net/8021q/vlan_core.c
> @@ -89,6 +89,11 @@ vlan_gro_common(struct napi_struct *napi, struct v=
lan_group *grp,
>  	if (!skb->dev)
>  		goto drop;
> =20
> +	skb->dev->stats.rx_packets++;
> +	skb->dev->stats.rx_bytes +=3D skb->len;
> +	if (skb->pkt_type =3D=3D PACKET_MULTICAST)
> +		skb->dev->stats.multicast++;
> +
>  	for (p =3D napi->gro_list; p; p =3D p->next) {
>  		NAPI_GRO_CB(p)->same_flow =3D
>  			p->dev =3D=3D skb->dev && !compare_ether_header(
>=20

Replying to myself, I found root of the problem and posted a fix.

Still the race while updating dev->stats.tx_{bytes|packets} should be a=
ddressed eventually...

