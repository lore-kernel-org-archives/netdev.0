From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Handle PMTU in ICMP error handlers.
Date: Fri, 15 Jun 2012 20:02:16 -0700 (PDT)
Message-ID: <20120615.200216.1185728435617216812.davem@davemloft.net>
References: <20120615.150052.774388947489484043.davem@davemloft.net>
	<CADVnQyn+t8VjgqqACDvSDR3yMN-q8xntGwVwWNxB4TFLxUYU8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52943 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755253Ab2FPDCU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2012 23:02:20 -0400
In-Reply-To: <CADVnQyn+t8VjgqqACDvSDR3yMN-q8xntGwVwWNxB4TFLxUYU8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Neal Cardwell <ncardwell@google.com>
Date: Fri, 15 Jun 2012 22:42:25 -0400

> On Fri, Jun 15, 2012 at 6:00 PM, David Miller <davem@davemloft.net> w=
rote:
>> +++ b/include/net/ip6_route.h
>> +extern void ip6_update_pmtu(struct sk_buff *skb, struct net *net, _=
_be32 mtu,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int oif, u32 m=
ark);
> ...
>> +++ b/net/ipv6/route.c
>> +void ip6_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int oif, __be32 mark)
>=20
> The .h and .c files disagree on the types of mtu and mark for
> ip6_update_pmtu(). Looks like the mtu should be __be32 in both. I'm
> guessing mark should also be __be32 in both, though I'm not yet
> familiar with that area of the code.
>=20
> Otherwise looks great to me.

Thanks Neal, I've fixed it up as follows:

--------------------
[PATCH] ipv6: Fix types of ip6_update_pmtu().

The mtu should be a __be32, not the mark.

Reported-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv6/route.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c7ccc36..1c279fe 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1065,8 +1065,8 @@ static void ip6_rt_update_pmtu(struct dst_entry *=
dst, u32 mtu)
 	}
 }
=20
-void ip6_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu,
-		     int oif, __be32 mark)
+void ip6_update_pmtu(struct sk_buff *skb, struct net *net, __be32 mtu,
+		     int oif, u32 mark)
 {
 	const struct ipv6hdr *iph =3D (struct ipv6hdr *) skb->data;
 	struct dst_entry *dst;
--=20
1.7.10.2
