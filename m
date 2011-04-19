From: kaber@trash.net
Subject: [PATCH 1/3] netfilter: ipset: bitmap:ip,mac type requires "src" for MAC
Date: Tue, 19 Apr 2011 16:51:43 +0200
Message-ID: <1303224705-17400-2-git-send-email-kaber@trash.net>
References: <1303224705-17400-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40014 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505Ab1DSOvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 10:51:49 -0400
In-Reply-To: <1303224705-17400-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Enforce that the second "src/dst" parameter of the set match and SET target
must be "src", because we have access to the source MAC only in the packet.
The previous behaviour, that the type required the second parameter
but actually ignored the value was counter-intuitive and confusing.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/ipset/ip_set_bitmap_ipmac.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index 00a3324..a274300 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -343,6 +343,10 @@ bitmap_ipmac_kadt(struct ip_set *set, const struct sk_buff *skb,
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct ipmac data;
 
+	/* MAC can be src only */
+	if (!(flags & IPSET_DIM_TWO_SRC))
+		return 0;
+
 	data.id = ntohl(ip4addr(skb, flags & IPSET_DIM_ONE_SRC));
 	if (data.id < map->first_ip || data.id > map->last_ip)
 		return -IPSET_ERR_BITMAP_RANGE;
-- 
1.7.2.3

