From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: [PATCH 5/6] [IPV4] SNMP: Support OutMcastPkts and OutBcastPkts
Date: Tue, 17 Apr 2007 20:14:18 +0900
Message-ID: <20070417201418.e6f1a379.mitch@linux.vnet.ibm.com>
References: <20070417200944.bd82ded2.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:47288 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753804AbXDQLO2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2007 07:14:28 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l3HBFKFx030463
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 07:15:20 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l3HBERqi543208
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 07:14:27 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l3HBELoj028137
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 07:14:21 -0400
In-Reply-To: <20070417200944.bd82ded2.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A transmitted IP multicast datagram should be counted as OutMcastPkts.
By the same token, a transmitted IP broadcast datagram should be
counted as OutBcastPkts.

Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
---
 net/ipv4/ip_output.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 704bc44..4442185 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -160,9 +160,15 @@ EXPORT_SYMBOL_GPL(ip_build_and_send_pkt)
 static inline int ip_finish_output2(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
+	struct rtable *rt = (struct rtable *)dst;
 	struct net_device *dev = dst->dev;
 	int hh_len = LL_RESERVED_SPACE(dev);
 
+	if (rt->rt_type == RTN_MULTICAST)
+		IP_INC_STATS(IPSTATS_MIB_OUTMCASTPKTS);
+	else if (rt->rt_type == RTN_BROADCAST)
+		IP_INC_STATS(IPSTATS_MIB_OUTBCASTPKTS);
+
 	/* Be paranoid, rather than too clever. */
 	if (unlikely(skb_headroom(skb) < hh_len && dev->hard_header)) {
 		struct sk_buff *skb2;
-- 
1.4.3.4

