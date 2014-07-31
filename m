From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 06/15] i40e: Move some variable declarations out of a loop
Date: Wed, 30 Jul 2014 17:32:02 -0700
Message-ID: <1406766731-4209-7-git-send-email-aaron.f.brown@intel.com>
References: <1406766731-4209-1-git-send-email-aaron.f.brown@intel.com>
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:24422 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756033AbaGaA2S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2014 20:28:18 -0400
In-Reply-To: <1406766731-4209-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>

Declare some variables once outside of the loop instead of in
every iteration of the loop.

Change-ID: I436913777c7da3c16dc0031b59e3ffa61de74718
Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 6ac8487..66a1070 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -812,7 +812,10 @@ static void i40e_update_vsi_stats(struct i40e_vsi *vsi)
 	struct i40e_eth_stats *oes;
 	struct i40e_eth_stats *es;     /* device's eth stats */
 	u32 tx_restart, tx_busy;
+	struct i40e_ring *p;
 	u32 rx_page, rx_buf;
+	u64 bytes, packets;
+	unsigned int start;
 	u64 rx_p, rx_b;
 	u64 tx_p, tx_b;
 	u16 q;
@@ -836,10 +839,6 @@ static void i40e_update_vsi_stats(struct i40e_vsi *vsi)
 	rx_buf = 0;
 	rcu_read_lock();
 	for (q = 0; q < vsi->num_queue_pairs; q++) {
-		struct i40e_ring *p;
-		u64 bytes, packets;
-		unsigned int start;
-
 		/* locate Tx ring */
 		p = ACCESS_ONCE(vsi->tx_rings[q]);
 
-- 
1.9.3
