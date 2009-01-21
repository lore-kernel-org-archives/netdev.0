From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 2/9] bnx2x: annotate struct eth_tx_db_data
Date: Tue, 20 Jan 2009 21:50:47 -0800
Message-ID: <1232517047.9701.20.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:24781 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886AbZAUFux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 00:50:53 -0500
Received: by wf-out-1314.google.com with SMTP id 27so4192261wfd.4
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2009 21:50:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Always treated as little-endian values, annotate as such, use
the leXX_add_cpu helpers rather than opencoded byteswapping.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/bnx2x_hsi.h  |    4 ++--
 drivers/net/bnx2x_main.c |   12 ++++--------
 2 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index efd7644..a3c1068 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -2355,8 +2355,8 @@ struct eth_spe {
  * doorbell data in host memory
  */
 struct eth_tx_db_data {
-	u32 packets_prod;
-	u16 bds_prod;
+	__le32 packets_prod;
+	__le16 bds_prod;
 	u16 reserved;
 };
 
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 897f370..2f8d64c 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -8774,11 +8774,9 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 
 	wmb();
 
-	fp->hw_tx_prods->bds_prod =
-		cpu_to_le16(le16_to_cpu(fp->hw_tx_prods->bds_prod) + 1);
+	le16_add_cpu(&fp->hw_tx_prods->bds_prod, 1);
 	mb(); /* FW restriction: must not reorder writing nbd and packets */
-	fp->hw_tx_prods->packets_prod =
-		cpu_to_le32(le32_to_cpu(fp->hw_tx_prods->packets_prod) + 1);
+	le32_add_cpu(&fp->hw_tx_prods->packets_prod, 1);
 	DOORBELL(bp, fp->index, 0);
 
 	mmiowb();
@@ -9774,11 +9772,9 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	wmb();
 
-	fp->hw_tx_prods->bds_prod =
-		cpu_to_le16(le16_to_cpu(fp->hw_tx_prods->bds_prod) + nbd);
+	le16_add_cpu(&fp->hw_tx_prods->bds_prod, nbd);
 	mb(); /* FW restriction: must not reorder writing nbd and packets */
-	fp->hw_tx_prods->packets_prod =
-		cpu_to_le32(le32_to_cpu(fp->hw_tx_prods->packets_prod) + 1);
+	le32_add_cpu(&fp->hw_tx_prods->packets_prod, 1);
 	DOORBELL(bp, fp->index, 0);
 
 	mmiowb();
-- 
1.6.1.249.g455e5


