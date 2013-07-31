From: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
Subject: [PATCH 1/2 v2] igb: Add macro for size of RETA indirection table
Date: Wed, 31 Jul 2013 14:47:52 +0300
Message-ID: <1375271273-20122-1-git-send-email-laura.vasilescu@rosedu.org>
Cc: carolyn.wyborny@intel.com, anjali.singhai@intel.com,
	jeffrey.t.kirsher@intel.com, alexander.h.duyck@intel.com,
	Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f51.google.com ([209.85.128.51]:43299 "EHLO
	mail-qe0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098Ab3GaLr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 07:47:57 -0400
Received: by mail-qe0-f51.google.com with SMTP id nd7so296306qeb.38
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 04:47:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RETA indirection table is used to assign the received data to a CPU
in order to maintain an efficient distribution of network receive
processing accross multiple CPUs.

This patch removes the hard-coded value for the size of the indirection
table and defines a new macro.

Signed-off-by: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
---
Changes since v1:
	* enhance commit description

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
