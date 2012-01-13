From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: release idev when ip6_neigh_lookup failed in
 icmp6_dst_alloc
Date: Fri, 13 Jan 2012 10:11:09 -0800 (PST)
Message-ID: <20120113.101109.1309327184308507695.davem@davemloft.net>
References: <1326443626-19580-1-git-send-email-roy.qing.li@gmail.com>
	<1326448121.2272.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: roy.qing.li@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49276 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752231Ab2AMSLM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 13:11:12 -0500
In-Reply-To: <1326448121.2272.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 13 Jan 2012 10:48:41 +0100

> Le vendredi 13 janvier 2012 =E0 16:33 +0800, roy.qing.li@gmail.com a
> =E9crit :
>> From: RongQing.Li <roy.qing.li@gmail.com>
>>=20
>> release idev when ip6_neigh_lookup failed in icmp6_dst_alloc
>>=20
>> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
>> ---
>>  net/ipv6/route.c |    1 +
>>  1 files changed, 1 insertions(+), 0 deletions(-)
>>=20
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index 07361df..8c2e3ab 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -1091,6 +1091,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_d=
evice *dev,
>>  	else {
>>  		neigh =3D ip6_neigh_lookup(&rt->dst, &fl6->daddr);
>>  		if (IS_ERR(neigh)) {
>> +			in6_dev_put(idev);
>>  			dst_free(&rt->dst);
>>  			return ERR_CAST(neigh);
>>  		}
>=20
> Good catch, thanks.
>=20
> Bug added in commit b43faac6906 (ipv6: If neigh lookup fails during
> icmp6 dst allocation, propagate error.),=20
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
