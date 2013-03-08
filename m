From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] e1000e: cleanup unusually placed comments
Date: Fri,  8 Mar 2013 02:07:12 -0800
Message-ID: <1362737237-13363-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1362737237-13363-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12686 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933993Ab3CHKHe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 05:07:34 -0500
In-Reply-To: <1362737237-13363-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/80003es2lan.c |  2 +-
 drivers/net/ethernet/intel/e1000e/82571.c       |  2 +-
 drivers/net/ethernet/intel/e1000e/e1000.h       |  5 ++--
 drivers/net/ethernet/intel/e1000e/ethtool.c     | 15 ++++++-----
 drivers/net/ethernet/intel/e1000e/ich8lan.c     |  2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c      |  2 +-
 drivers/net/ethernet/intel/e1000e/param.c       | 36 ++++++++++++++++---------
 7 files changed, 39 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/80003es2lan.c b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
index d75ace9..303aa8a 100644
--- a/drivers/net/ethernet/intel/e1000e/80003es2lan.c
+++ b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
@@ -753,9 +753,9 @@ static s32 e1000_init_hw_80003es2lan(struct e1000_hw *hw)
 
 	/* Initialize identification LED */
 	ret_val = mac->ops.id_led_init(hw);
+	/* An error is not fatal and we should not stop init due to this */
 	if (ret_val)
 		e_dbg("Error initializing identification LED\n");
-		/* This is not fatal and we should not stop init due to this */
 
 	/* Disabling VLAN filtering */
 	e_dbg("Initializing the IEEE VLAN\n");
diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index 49341c0..49bce4e 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -1096,9 +1096,9 @@ static s32 e1000_init_hw_82571(struct e1000_hw *hw)
 
 	/* Initialize identification LED */
 	ret_val = mac->ops.id_led_init(hw);
+	/* An error is not fatal and we should not stop init due to this */
 	if (ret_val)
 		e_dbg("Error initializing identification LED\n");
-		/* This is not fatal and we should not stop init due to this */
 
 	/* Disabling VLAN filtering */
 	e_dbg("Initializing the IEEE VLAN\n");
diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 3ecc988..6ba1149 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -238,9 +238,8 @@ struct e1000_adapter {
 	u16 tx_itr;
 	u16 rx_itr;
 
-	/* Tx */
-	struct e1000_ring *tx_ring /* One per active queue */
-						____cacheline_aligned_in_smp;
+	/* Tx - one ring per active queue */
+	struct e1000_ring *tx_ring ____cacheline_aligned_in_smp;
 	u32 tx_fifo_limit;
 
 	struct napi_struct napi;
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index c47dee6..9dbf5d0 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -812,10 +812,10 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 	u32 wlock_mac = 0;
 
 	/* The status register is Read Only, so a write should fail.
-	 * Some bits that get toggled are ignored.
+	 * Some bits that get toggled are ignored.  There are several bits
+	 * on newer hardware that are r/w.
 	 */
 	switch (mac->type) {
-	/* there are several bits on newer hardware that are r/w */
 	case e1000_82571:
 	case e1000_82572:
 	case e1000_80003es2lan:
@@ -1600,8 +1600,10 @@ static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 
 	k = 0;
 	l = 0;
-	for (j = 0; j <= lc; j++) { /* loop count loop */
-		for (i = 0; i < 64; i++) { /* send the packets */
+	/* loop count loop */
+	for (j = 0; j <= lc; j++) {
+		/* send the packets */
+		for (i = 0; i < 64; i++) {
 			buffer_info = &tx_ring->buffer_info[k];
 
 			e1000_create_lbtest_frame(buffer_info->skb, 1024);
@@ -1618,7 +1620,8 @@ static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 		msleep(200);
 		time = jiffies; /* set the start time for the receive */
 		good_cnt = 0;
-		do { /* receive the sent packets */
+		/* receive the sent packets */
+		do {
 			buffer_info = &rx_ring->buffer_info[l];
 
 			dma_sync_single_for_cpu(&pdev->dev,
@@ -1645,7 +1648,7 @@ static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 			ret_val = 14; /* error code for time out error */
 			break;
 		}
-	} /* end loop count loop */
+	}
 	return ret_val;
 }
 
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 6ff7ff5..d249db9 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -3452,9 +3452,9 @@ static s32 e1000_init_hw_ich8lan(struct e1000_hw *hw)
 
 	/* Initialize identification LED */
 	ret_val = mac->ops.id_led_init(hw);
+	/* An error is not fatal and we should not stop init due to this */
 	if (ret_val)
 		e_dbg("Error initializing identification LED\n");
-		/* This is not fatal and we should not stop init due to this */
 
 	/* Setup the receive address. */
 	e1000e_init_rx_addrs(hw, mac->rar_entry_count);
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 172d2e3..5337137 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -2558,8 +2558,8 @@ static void e1000_set_itr(struct e1000_adapter *adapter)
 
 	current_itr = max(adapter->rx_itr, adapter->tx_itr);
 
-	switch (current_itr) {
 	/* counts and packets in update_itr are dependent on these numbers */
+	switch (current_itr) {
 	case lowest_latency:
 		new_itr = 70000;
 		break;
diff --git a/drivers/net/ethernet/intel/e1000e/param.c b/drivers/net/ethernet/intel/e1000e/param.c
index 39fb507..36bf39d 100644
--- a/drivers/net/ethernet/intel/e1000e/param.c
+++ b/drivers/net/ethernet/intel/e1000e/param.c
@@ -161,11 +161,13 @@ struct e1000_option {
 	const char *err;
 	int def;
 	union {
-		struct { /* range_option info */
+		/* range_option info */
+		struct {
 			int min;
 			int max;
 		} r;
-		struct { /* list_option info */
+		/* list_option info */
+		struct {
 			int nr;
 			struct e1000_opt_list { int i; char *str; } *p;
 		} l;
@@ -247,7 +249,8 @@ void e1000e_check_options(struct e1000_adapter *adapter)
 			   "Using defaults for all values\n");
 	}
 
-	{ /* Transmit Interrupt Delay */
+	/* Transmit Interrupt Delay */
+	{
 		static const struct e1000_option opt = {
 			.type = range_option,
 			.name = "Transmit Interrupt Delay",
@@ -266,7 +269,8 @@ void e1000e_check_options(struct e1000_adapter *adapter)
 			adapter->tx_int_delay = opt.def;
 		}
 	}
-	{ /* Transmit Absolute Interrupt Delay */
+	/* Transmit Absolute Interrupt Delay */
+	{
 		static const struct e1000_option opt = {
 			.type = range_option,
 			.name = "Transmit Absolute Interrupt Delay",
@@ -285,7 +289,8 @@ void e1000e_check_options(struct e1000_adapter *adapter)
 			adapter->tx_abs_int_delay = opt.def;
 		}
 	}
-	{ /* Receive Interrupt Delay */
+	/* Receive Interrupt Delay */
+	{
 		static struct e1000_option opt = {
 			.type = range_option,
 			.name = "Receive Interrupt Delay",
@@ -304,7 +309,8 @@ void e1000e_check_options(struct e1000_adapter *adapter)
 			adapter->rx_int_delay = opt.def;
 		}
 	}
-	{ /* Receive Absolute Interrupt Delay */
+	/* Receive Absolute Interrupt Delay */
+	{
 		static const struct e1000_option opt = {
 			.type = range_option,
 			.name = "Receive Absolute Interrupt Delay",
@@ -323,7 +329,8 @@ void e1000e_check_options(struct e1000_adapter *adapter)
 			adapter->rx_abs_int_delay = opt.def;
 		}
 	}
-	{ /* Interrupt Throttling Rate */
+	/* Interrupt Throttling Rate */
+	{
 		static const struct e1000_option opt = {
 			.type = range_option,
 			.name = "Interrupt Throttling Rate (ints/sec)",
@@ -393,7 +400,8 @@ void e1000e_check_options(struct e1000_adapter *adapter)
 			break;
 		}
 	}
-	{ /* Interrupt Mode */
+	/* Interrupt Mode */
+	{
 		static struct e1000_option opt = {
 			.type = range_option,
 			.name = "Interrupt Mode",
@@ -436,7 +444,8 @@ void e1000e_check_options(struct e1000_adapter *adapter)
 		kfree(opt.err);
 #endif
 	}
-	{ /* Smart Power Down */
+	/* Smart Power Down */
+	{
 		static const struct e1000_option opt = {
 			.type = enable_option,
 			.name = "PHY Smart Power Down",
@@ -451,7 +460,8 @@ void e1000e_check_options(struct e1000_adapter *adapter)
 				adapter->flags |= FLAG_SMART_POWER_DOWN;
 		}
 	}
-	{ /* CRC Stripping */
+	/* CRC Stripping */
+	{
 		static const struct e1000_option opt = {
 			.type = enable_option,
 			.name = "CRC Stripping",
@@ -471,7 +481,8 @@ void e1000e_check_options(struct e1000_adapter *adapter)
 			adapter->flags2 |= FLAG2_DFLT_CRC_STRIPPING;
 		}
 	}
-	{ /* Kumeran Lock Loss Workaround */
+	/* Kumeran Lock Loss Workaround */
+	{
 		static const struct e1000_option opt = {
 			.type = enable_option,
 			.name = "Kumeran Lock Loss Workaround",
@@ -490,7 +501,8 @@ void e1000e_check_options(struct e1000_adapter *adapter)
 			e1000e_set_kmrn_lock_loss_workaround_ich8lan(hw,
 								     enabled);
 	}
-	{ /* Write-protect NVM */
+	/* Write-protect NVM */
+	{
 		static const struct e1000_option opt = {
 			.type = enable_option,
 			.name = "Write-protect NVM",
-- 
1.7.11.7
