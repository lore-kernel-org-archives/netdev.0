From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 01/17] atl1: remove open-coded skb_cow_head.
Date: Sat, 29 Mar 2014 12:26:14 +0100
Message-ID: <820e5094e5f5400abed56c80b2fb2e3ddce85269.1396090802.git.romieu@fr.zoreil.com>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
Cc: netdev@vger.kernel.org, Chris Snook <chris.snook@gmail.com>,
	Jay Cliburn <jcliburn@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60854 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587AbaC2L0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 07:26:49 -0400
In-Reply-To: <cover.1396090802.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1396090802.git.romieu@fr.zoreil.com>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Chris Snook <chris.snook@gmail.com>
Cc: Jay Cliburn <jcliburn@gmail.com>
---
 drivers/net/ethernet/atheros/atlx/atl1.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 287272d..dfd0e91 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -2118,18 +2118,17 @@ static u16 atl1_tpd_avail(struct atl1_tpd_ring *tpd_ring)
 }
 
 static int atl1_tso(struct atl1_adapter *adapter, struct sk_buff *skb,
-	struct tx_packet_desc *ptpd)
+		    struct tx_packet_desc *ptpd)
 {
 	u8 hdr_len, ip_off;
 	u32 real_len;
-	int err;
 
 	if (skb_shinfo(skb)->gso_size) {
-		if (skb_header_cloned(skb)) {
-			err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-			if (unlikely(err))
-				return -1;
-		}
+		int err;
+
+		err = skb_cow_head(skb, 0);
+		if (err < 0)
+			return err;
 
 		if (skb->protocol == htons(ETH_P_IP)) {
 			struct iphdr *iph = ip_hdr(skb);
@@ -2175,7 +2174,7 @@ static int atl1_tso(struct atl1_adapter *adapter, struct sk_buff *skb,
 			return 3;
 		}
 	}
-	return false;
+	return 0;
 }
 
 static int atl1_tx_csum(struct atl1_adapter *adapter, struct sk_buff *skb,
-- 
1.9.0
