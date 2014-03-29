From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 03/17] atl1e: remove open-coded skb_cow_head.
Date: Sat, 29 Mar 2014 12:26:16 +0100
Message-ID: <fde4b278662d5023e39e1a555ca4875f9d01eb16.1396090802.git.romieu@fr.zoreil.com>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
Cc: netdev@vger.kernel.org, Chris Snook <chris.snook@gmail.com>,
	Jay Cliburn <jcliburn@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60856 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591AbaC2L0t (ORCPT
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
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index 422aab2..4345332 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -1641,17 +1641,17 @@ static u16 atl1e_cal_tdp_req(const struct sk_buff *skb)
 static int atl1e_tso_csum(struct atl1e_adapter *adapter,
 		       struct sk_buff *skb, struct atl1e_tpd_desc *tpd)
 {
+	unsigned short offload_type;
 	u8 hdr_len;
 	u32 real_len;
-	unsigned short offload_type;
-	int err;
 
 	if (skb_is_gso(skb)) {
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
+
 		offload_type = skb_shinfo(skb)->gso_type;
 
 		if (offload_type & SKB_GSO_TCPV4) {
-- 
1.9.0
