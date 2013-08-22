From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 10/15] igb: Add macro for size of RETA indirection table
Date: Thu, 22 Aug 2013 02:49:46 -0700
Message-ID: <1377164991-27988-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1377164991-27988-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:48257 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752850Ab3HVJuC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 05:50:02 -0400
In-Reply-To: <1377164991-27988-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>

RETA indirection table is used to assign the received data to a CPU
in order to maintain an efficient distribution of network receive
processing across multiple CPUs.

This patch removes the hard-coded value for the size of the indirection
table and defines a new macro.

Signed-off-by: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      | 2 ++
 drivers/net/ethernet/intel/igb/igb_main.c | 2 +-
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
index 7f6cf65..1acd9c0 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3157,7 +3157,7 @@ static void igb_setup_mrqc(struct igb_adapter *adapter)
 	 * we are generating the results for n and n+2 and then interleaving
 	 * those with the results with n+1 and n+3.
 	 */
-	for (j = 0; j < 32; j++) {
+	for (j = 0; j < IGB_RETA_SIZE / 4; j++) {
 		/* first pass generates n and n+2 */
 		u32 base = ((j * 0x00040004) + 0x00020000) * num_rx_queues;
 		u32 reta = (base & 0x07800780) >> (7 - shift);
-- 
1.8.3.1
