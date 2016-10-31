From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 3/4] net: pim: add all RFC7761 message types
Date: Mon, 31 Oct 2016 13:21:04 +0100
Message-ID: <1477916465-20406-4-git-send-email-nikolay@cumulusnetworks.com>
References: <1477916465-20406-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, dwalton@cumulusnetworks.com,
        stephen@networkplumber.org, davem@davemloft.net,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:35855 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941442AbcJaMVU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 08:21:20 -0400
Received: by mail-wm0-f49.google.com with SMTP id p190so143767831wmp.1
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 05:21:19 -0700 (PDT)
In-Reply-To: <1477916465-20406-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/linux/pim.h | 31 ++++++++++++++++++++++++++++++-
 net/ipv4/ipmr.c     |  2 +-
 net/ipv6/ip6mr.c    |  2 +-
 3 files changed, 32 insertions(+), 3 deletions(-)

diff --git a/include/linux/pim.h b/include/linux/pim.h
index 1b6c0dbba94e..0e81b2778ae0 100644
--- a/include/linux/pim.h
+++ b/include/linux/pim.h
@@ -10,7 +10,36 @@
 
 /* Message types - V2 */
 #define PIM_VERSION		2
-#define PIM_REGISTER		1
+
+/* RFC7761, sec 4.9:
+ *  Type
+ *        Types for specific PIM messages.  PIM Types are:
+ *
+ *  Message Type                          Destination
+ *  ---------------------------------------------------------------------
+ *  0 = Hello                             Multicast to ALL-PIM-ROUTERS
+ *  1 = Register                          Unicast to RP
+ *  2 = Register-Stop                     Unicast to source of Register
+ *                                        packet
+ *  3 = Join/Prune                        Multicast to ALL-PIM-ROUTERS
+ *  4 = Bootstrap                         Multicast to ALL-PIM-ROUTERS
+ *  5 = Assert                            Multicast to ALL-PIM-ROUTERS
+ *  6 = Graft (used in PIM-DM only)       Unicast to RPF'(S)
+ *  7 = Graft-Ack (used in PIM-DM only)   Unicast to source of Graft
+ *                                        packet
+ *  8 = Candidate-RP-Advertisement        Unicast to Domain's BSR
+ */
+enum {
+	PIM_TYPE_HELLO,
+	PIM_TYPE_REGISTER,
+	PIM_TYPE_REGISTER_STOP,
+	PIM_TYPE_JOIN_PRUNE,
+	PIM_TYPE_BOOTSTRAP,
+	PIM_TYPE_ASSERT,
+	PIM_TYPE_GRAFT,
+	PIM_TYPE_GRAFT_ACK,
+	PIM_TYPE_CANDIDATE_RP_ADV
+};
 
 #define PIM_NULL_REGISTER	cpu_to_be32(0x40000000)
 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 5f006e13de56..51d71a70fbbe 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2053,7 +2053,7 @@ static int pim_rcv(struct sk_buff *skb)
 		goto drop;
 
 	pim = (struct pimreghdr *)skb_transport_header(skb);
-	if (pim->type != ((PIM_VERSION << 4) | (PIM_REGISTER)) ||
+	if (pim->type != ((PIM_VERSION << 4) | (PIM_TYPE_REGISTER)) ||
 	    (pim->flags & PIM_NULL_REGISTER) ||
 	    (ip_compute_csum((void *)pim, sizeof(*pim)) != 0 &&
 	     csum_fold(skb_checksum(skb, 0, skb->len, 0))))
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 7f4265b1649b..52101b37ad6e 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -636,7 +636,7 @@ static int pim6_rcv(struct sk_buff *skb)
 		goto drop;
 
 	pim = (struct pimreghdr *)skb_transport_header(skb);
-	if (pim->type != ((PIM_VERSION << 4) | PIM_REGISTER) ||
+	if (pim->type != ((PIM_VERSION << 4) | PIM_TYPE_REGISTER) ||
 	    (pim->flags & PIM_NULL_REGISTER) ||
 	    (csum_ipv6_magic(&ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
 			     sizeof(*pim), IPPROTO_PIM,
-- 
2.1.4
