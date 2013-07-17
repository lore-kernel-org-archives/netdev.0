From: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
Subject: [PATCH 1/2] igb: Add macro for RETA indirection table
Date: Wed, 17 Jul 2013 09:50:05 +0300
Message-ID: <1374043806-17284-1-git-send-email-laura.vasilescu@rosedu.org>
Cc: jeffrey.t.kirsher@intel.com, carolyn.wyborny@intel.com,
	anjali.singhai@intel.com,
	Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:59247 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956Ab3GQGuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 02:50:22 -0400
Received: by mail-qc0-f181.google.com with SMTP id u12so896257qcx.12
        for <netdev@vger.kernel.org>; Tue, 16 Jul 2013 23:50:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
---
 drivers/net/ethernet/intel/igb/igb.h      |    2 ++
 drivers/net/ethernet/intel/igb/igb_main.c |    2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 15ea8dc..96fdfe2 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -456,6 +456,8 @@ struct igb_adapter {
 #define IGB_FLAG_RSS_FIELD_IPV6_UDP	(1 << 7)
 #define IGB_FLAG_WOL_SUPPORTED		(1 << 8)
 
+#define IGB_RETA_SIZE		32
+
 /* DMA Coalescing defines */
 #define IGB_MIN_TXPBSIZE	20408
 #define IGB_TX_BUF_4096		4096
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 6a0c1b6..09ea855a 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3127,7 +3127,7 @@ static void igb_setup_mrqc(struct igb_adapter *adapter)
 	 * we are generating the results for n and n+2 and then interleaving
 	 * those with the results with n+1 and n+3.
 	 */
-	for (j = 0; j < 32; j++) {
+	for (j = 0; j < IGB_RETA_SIZE; j++) {
 		/* first pass generates n and n+2 */
 		u32 base = ((j * 0x00040004) + 0x00020000) * num_rx_queues;
 		u32 reta = (base & 0x07800780) >> (7 - shift);
-- 
1.7.10.4
