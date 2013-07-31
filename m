From: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
Subject: [PATCH 1/2] igb: Add macro for size of RETA indirection table
Date: Wed, 31 Jul 2013 11:43:31 +0300
Message-ID: <1375260212-19351-1-git-send-email-laura.vasilescu@rosedu.org>
Cc: carolyn.wyborny@intel.com, anjali.singhai@intel.com,
	jeffrey.t.kirsher@intel.com, alexander.h.duyck@intel.com,
	Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:46396 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754023Ab3GaInf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 04:43:35 -0400
Received: by mail-qa0-f45.google.com with SMTP id l18so2877225qak.4
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 01:43:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
---
 drivers/net/ethernet/intel/igb/igb.h      |    2 ++
 drivers/net/ethernet/intel/igb/igb_main.c |    2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 15ea8dc..5a2659b 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -343,6 +343,8 @@ struct hwmon_buff {
 	};
 #endif
 
+#define IGB_RETA_SIZE	128
+
 /* board specific private data structure */
 struct igb_adapter {
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 6a0c1b6..00f5d96 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3127,7 +3127,7 @@ static void igb_setup_mrqc(struct igb_adapter *adapter)
 	 * we are generating the results for n and n+2 and then interleaving
 	 * those with the results with n+1 and n+3.
 	 */
-	for (j = 0; j < 32; j++) {
+	for (j = 0; j < IGB_RETA_SIZE / 4; j++) {
 		/* first pass generates n and n+2 */
 		u32 base = ((j * 0x00040004) + 0x00020000) * num_rx_queues;
 		u32 reta = (base & 0x07800780) >> (7 - shift);
-- 
1.7.10.4
