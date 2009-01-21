From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 3/9] bnx2x: annotate addr_hi/addr_lo as le32
Date: Tue, 20 Jan 2009 21:50:48 -0800
Message-ID: <1232517048.9701.21.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.231]:49189 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509AbZAUFuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 00:50:55 -0500
Received: by rv-out-0506.google.com with SMTP id k40so3470392rvb.1
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2009 21:50:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove a completely unused structure definition as well.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/bnx2x_hsi.h  |   27 ++++++++-------------------
 drivers/net/bnx2x_main.c |    8 ++++----
 2 files changed, 12 insertions(+), 23 deletions(-)

diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index a3c1068..b62d45e 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -1496,16 +1496,16 @@ struct ustorm_eth_st_context_config {
  * The eth Rx Buffer Descriptor
  */
 struct eth_rx_bd {
-	u32 addr_lo;
-	u32 addr_hi;
+	__le32 addr_lo;
+	__le32 addr_hi;
 };
 
 /*
  * The eth Rx SGE Descriptor
  */
 struct eth_rx_sge {
-	u32 addr_lo;
-	u32 addr_hi;
+	__le32 addr_lo;
+	__le32 addr_hi;
 };
 
 /*
@@ -1908,8 +1908,8 @@ struct eth_tx_bd_flags {
  * The eth Tx Buffer Descriptor
  */
 struct eth_tx_bd {
-	u32 addr_lo;
-	u32 addr_hi;
+	__le32 addr_lo;
+	__le32 addr_hi;
 	u16 nbd;
 	u16 nbytes;
 	u16 vlan;
@@ -2262,17 +2262,6 @@ union eth_ramrod_data {
 	struct ramrod_data general;
 };
 
-
-/*
- * Rx Last BD in page (in ETH)
- */
-struct eth_rx_bd_next_page {
-	u32 addr_lo;
-	u32 addr_hi;
-	u8 reserved[8];
-};
-
-
 /*
  * Eth Rx Cqe structure- general structure for ramrods
  */
@@ -2297,8 +2286,8 @@ struct common_ramrod_eth_rx_cqe {
  * Rx Last CQE in page (in ETH)
  */
 struct eth_rx_cqe_next_page {
-	u32 addr_lo;
-	u32 addr_hi;
+	__le32 addr_lo;
+	__le32 addr_hi;
 	u32 reserved[6];
 };
 
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 2f8d64c..021c31c 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -987,8 +987,8 @@ static inline void bnx2x_free_rx_sge(struct bnx2x *bp,
 	__free_pages(page, PAGES_PER_SGE_SHIFT);
 
 	sw_buf->page = NULL;
-	sge->addr_hi = 0;
-	sge->addr_lo = 0;
+	sge->addr_hi = cpu_to_le32(0);
+	sge->addr_lo = cpu_to_le32(0);
 }
 
 static inline void bnx2x_free_rx_sge_range(struct bnx2x *bp,
@@ -9419,7 +9419,7 @@ static inline u32 bnx2x_xmit_type(struct bnx2x *bp, struct sk_buff *skb)
 		rc = XMIT_PLAIN;
 
 	else {
-		if (skb->protocol == ntohs(ETH_P_IPV6)) {
+		if (skb->protocol == htons(ETH_P_IPV6)) {
 			rc = XMIT_CSUM_V6;
 			if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
 				rc |= XMIT_CSUM_TCP;
@@ -9627,7 +9627,7 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		/* for now NS flag is not used in Linux */
 		pbd->global_data = (hlen |
-				    ((skb->protocol == ntohs(ETH_P_8021Q)) <<
+				    ((skb->protocol == cpu_to_be16(ETH_P_8021Q)) <<
 				     ETH_TX_PARSE_BD_LLC_SNAP_EN_SHIFT));
 
 		pbd->ip_hlen = (skb_transport_header(skb) -
-- 
1.6.1.249.g455e5


