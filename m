From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipip: Fix bug added to ipip_tunnel_xmit().
Date: Tue, 24 Jan 2012 18:24:02 -0500 (EST)
Message-ID: <20120124.182402.1379481101464791767.davem@davemloft.net>
References: <20120124.181838.1470195215432711102.davem@davemloft.net>
	<1327447295.14373.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43122 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004Ab2AXXYJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 18:24:09 -0500
In-Reply-To: <1327447295.14373.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 Jan 2012 00:21:35 +0100

> Le mardi 24 janvier 2012 =E0 18:18 -0500, David Miller a =E9crit :
>> We can remove the rt_gateway =3D=3D 0 check but we shouldn't
>> remove the 'dst' initialization too.
>>=20
>> Noticed by Eric Dumazet.
>>=20
>> Signed-off-by: David S. Miller <davem@davemloft.net>
>> ---
>>  net/ipv4/ipip.c |    1 +
>>  1 files changed, 1 insertions(+), 0 deletions(-)
>>=20
>> diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
>> index 87c63b6..f84ebff 100644
>> --- a/net/ipv4/ipip.c
>> +++ b/net/ipv4/ipip.c
>> @@ -454,6 +454,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_bu=
ff *skb, struct net_device *dev)
>>  			dev->stats.tx_fifo_errors++;
>>  			goto tx_error;
>>  		}
>> +		dst =3D rt->rt_gateway;
>>  	}
>> =20
>>  	rt =3D ip_route_output_ports(dev_net(dev), &fl4, NULL,
>=20
>=20
> Well, a similar fix is needed for net/ipv4/ip_gre.c :)

Indeed:

--------------------
ip_gre: Fix bug added to ipgre_tunnel_xmit().

We can remove the rt_gateway =3D=3D 0 check but we shouldn't
remove the 'dst' initialization too.

Noticed by Eric Dumazet.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ip_gre.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index fc21335..05f7419 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -724,8 +724,10 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buf=
f *skb, struct net_device *dev
 			goto tx_error;
 		}
=20
-		if (skb->protocol =3D=3D htons(ETH_P_IP))
+		if (skb->protocol =3D=3D htons(ETH_P_IP)) {
 			rt =3D skb_rtable(skb);
+			dst =3D rt->rt_gateway;
+		}
 #if IS_ENABLED(CONFIG_IPV6)
 		else if (skb->protocol =3D=3D htons(ETH_P_IPV6)) {
 			struct neighbour *neigh =3D dst_get_neighbour_noref(skb_dst(skb));
--=20
1.7.7.6
