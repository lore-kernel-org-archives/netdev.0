From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/11] e1000e: resolve -Wunused-parameter compile warnings
Date: Thu, 31 Jan 2013 23:53:30 -0800
Message-ID: <1359705211-11342-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1359705211-11342-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48871 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755863Ab3BAHyS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 02:54:18 -0500
In-Reply-To: <1359705211-11342-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Remove the unused parameter when possible, otherwise use __always_unused
attribute.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ethtool.c | 16 ++++++++------
 drivers/net/ethernet/intel/e1000e/ich8lan.c |  4 ++--
 drivers/net/ethernet/intel/e1000e/mac.c     |  4 ++--
 drivers/net/ethernet/intel/e1000e/netdev.c  | 33 ++++++++++++-----------------
 drivers/net/ethernet/intel/e1000e/phy.c     |  2 +-
 drivers/net/ethernet/intel/e1000e/ptp.c     |  5 +++--
 6 files changed, 31 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 58df18c..b144778 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -418,7 +418,7 @@ static void e1000_set_msglevel(struct net_device *netdev, u32 data)
 	adapter->msg_enable = data;
 }
 
-static int e1000_get_regs_len(struct net_device *netdev)
+static int e1000_get_regs_len(struct net_device __always_unused *netdev)
 {
 #define E1000_REGS_LEN 32 /* overestimate */
 	return E1000_REGS_LEN * sizeof(u32);
@@ -934,7 +934,7 @@ static int e1000_eeprom_test(struct e1000_adapter *adapter, u64 *data)
 	return *data;
 }
 
-static irqreturn_t e1000_test_intr(int irq, void *data)
+static irqreturn_t e1000_test_intr(int __always_unused irq, void *data)
 {
 	struct net_device *netdev = (struct net_device *) data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
@@ -1705,7 +1705,8 @@ static int e1000_link_test(struct e1000_adapter *adapter, u64 *data)
 	return *data;
 }
 
-static int e1000e_get_sset_count(struct net_device *netdev, int sset)
+static int e1000e_get_sset_count(struct net_device __always_unused *netdev,
+				 int sset)
 {
 	switch (sset) {
 	case ETH_SS_TEST:
@@ -1968,7 +1969,7 @@ static int e1000_nway_reset(struct net_device *netdev)
 }
 
 static void e1000_get_ethtool_stats(struct net_device *netdev,
-				    struct ethtool_stats *stats,
+				    struct ethtool_stats __always_unused *stats,
 				    u64 *data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
@@ -1997,8 +1998,8 @@ static void e1000_get_ethtool_stats(struct net_device *netdev,
 	}
 }
 
-static void e1000_get_strings(struct net_device *netdev, u32 stringset,
-			      u8 *data)
+static void e1000_get_strings(struct net_device __always_unused *netdev,
+			      u32 stringset, u8 *data)
 {
 	u8 *p = data;
 	int i;
@@ -2018,7 +2019,8 @@ static void e1000_get_strings(struct net_device *netdev, u32 stringset,
 }
 
 static int e1000_get_rxnfc(struct net_device *netdev,
-			   struct ethtool_rxnfc *info, u32 *rule_locs)
+			   struct ethtool_rxnfc *info,
+			   u32 __always_unused *rule_locs)
 {
 	info->data = 0;
 
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 2ca6f2f..5ca21f9 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1082,7 +1082,7 @@ static DEFINE_MUTEX(nvm_mutex);
  *
  *  Acquires the mutex for performing NVM operations.
  **/
-static s32 e1000_acquire_nvm_ich8lan(struct e1000_hw *hw)
+static s32 e1000_acquire_nvm_ich8lan(struct e1000_hw __always_unused *hw)
 {
 	mutex_lock(&nvm_mutex);
 
@@ -1095,7 +1095,7 @@ static s32 e1000_acquire_nvm_ich8lan(struct e1000_hw *hw)
  *
  *  Releases the mutex used while performing NVM operations.
  **/
-static void e1000_release_nvm_ich8lan(struct e1000_hw *hw)
+static void e1000_release_nvm_ich8lan(struct e1000_hw __always_unused *hw)
 {
 	mutex_unlock(&nvm_mutex);
 }
diff --git a/drivers/net/ethernet/intel/e1000e/mac.c b/drivers/net/ethernet/intel/e1000e/mac.c
index 5992eef..7365288 100644
--- a/drivers/net/ethernet/intel/e1000e/mac.c
+++ b/drivers/net/ethernet/intel/e1000e/mac.c
@@ -1356,8 +1356,8 @@ s32 e1000e_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed,
  *  Sets the speed and duplex to gigabit full duplex (the only possible option)
  *  for fiber/serdes links.
  **/
-s32 e1000e_get_speed_and_duplex_fiber_serdes(struct e1000_hw *hw, u16 *speed,
-					     u16 *duplex)
+s32 e1000e_get_speed_and_duplex_fiber_serdes(struct e1000_hw __always_unused
+					     *hw, u16 *speed, u16 *duplex)
 {
 	*speed = SPEED_1000;
 	*duplex = FULL_DUPLEX;
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 3bb7b01..eb01a55 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1747,7 +1747,7 @@ static void e1000e_downshift_workaround(struct work_struct *work)
  * @irq: interrupt number
  * @data: pointer to a network interface device structure
  **/
-static irqreturn_t e1000_intr_msi(int irq, void *data)
+static irqreturn_t e1000_intr_msi(int __always_unused irq, void *data)
 {
 	struct net_device *netdev = data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
@@ -1813,7 +1813,7 @@ static irqreturn_t e1000_intr_msi(int irq, void *data)
  * @irq: interrupt number
  * @data: pointer to a network interface device structure
  **/
-static irqreturn_t e1000_intr(int irq, void *data)
+static irqreturn_t e1000_intr(int __always_unused irq, void *data)
 {
 	struct net_device *netdev = data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
@@ -1888,7 +1888,7 @@ static irqreturn_t e1000_intr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-static irqreturn_t e1000_msix_other(int irq, void *data)
+static irqreturn_t e1000_msix_other(int __always_unused irq, void *data)
 {
 	struct net_device *netdev = data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
@@ -1920,8 +1920,7 @@ no_link_interrupt:
 	return IRQ_HANDLED;
 }
 
-
-static irqreturn_t e1000_intr_msix_tx(int irq, void *data)
+static irqreturn_t e1000_intr_msix_tx(int __always_unused irq, void *data)
 {
 	struct net_device *netdev = data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
@@ -1939,7 +1938,7 @@ static irqreturn_t e1000_intr_msix_tx(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-static irqreturn_t e1000_intr_msix_rx(int irq, void *data)
+static irqreturn_t e1000_intr_msix_rx(int __always_unused irq, void *data)
 {
 	struct net_device *netdev = data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
@@ -2496,9 +2495,7 @@ void e1000e_free_rx_resources(struct e1000_ring *rx_ring)
  *      while increasing bulk throughput.  This functionality is controlled
  *      by the InterruptThrottleRate module parameter.
  **/
-static unsigned int e1000_update_itr(struct e1000_adapter *adapter,
-				     u16 itr_setting, int packets,
-				     int bytes)
+static unsigned int e1000_update_itr(u16 itr_setting, int packets, int bytes)
 {
 	unsigned int retval = itr_setting;
 
@@ -2558,18 +2555,16 @@ static void e1000_set_itr(struct e1000_adapter *adapter)
 		goto set_itr_now;
 	}
 
-	adapter->tx_itr = e1000_update_itr(adapter,
-				    adapter->tx_itr,
-				    adapter->total_tx_packets,
-				    adapter->total_tx_bytes);
+	adapter->tx_itr = e1000_update_itr(adapter->tx_itr,
+					   adapter->total_tx_packets,
+					   adapter->total_tx_bytes);
 	/* conservative mode (itr 3) eliminates the lowest_latency setting */
 	if (adapter->itr_setting == 3 && adapter->tx_itr == lowest_latency)
 		adapter->tx_itr = low_latency;
 
-	adapter->rx_itr = e1000_update_itr(adapter,
-				    adapter->rx_itr,
-				    adapter->total_rx_packets,
-				    adapter->total_rx_bytes);
+	adapter->rx_itr = e1000_update_itr(adapter->rx_itr,
+					   adapter->total_rx_packets,
+					   adapter->total_rx_bytes);
 	/* conservative mode (itr 3) eliminates the lowest_latency setting */
 	if (adapter->itr_setting == 3 && adapter->rx_itr == lowest_latency)
 		adapter->rx_itr = low_latency;
@@ -4115,7 +4110,7 @@ static int e1000_sw_init(struct e1000_adapter *adapter)
  * @irq: interrupt number
  * @data: pointer to a network interface device structure
  **/
-static irqreturn_t e1000_intr_msi_test(int irq, void *data)
+static irqreturn_t e1000_intr_msi_test(int __always_unused irq, void *data)
 {
 	struct net_device *netdev = data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
@@ -6249,7 +6244,7 @@ static void e1000_shutdown(struct pci_dev *pdev)
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 
-static irqreturn_t e1000_intr_msix(int irq, void *data)
+static irqreturn_t e1000_intr_msix(int __always_unused irq, void *data)
 {
 	struct net_device *netdev = data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index 8dd1da0..6f32811 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -2178,7 +2178,7 @@ s32 e1000e_phy_hw_reset_generic(struct e1000_hw *hw)
  *  Generic function to wait 10 milli-seconds for configuration to complete
  *  and return success.
  **/
-s32 e1000e_get_cfg_done_generic(struct e1000_hw *hw)
+s32 e1000e_get_cfg_done_generic(struct e1000_hw __always_unused *hw)
 {
 	mdelay(10);
 
diff --git a/drivers/net/ethernet/intel/e1000e/ptp.c b/drivers/net/ethernet/intel/e1000e/ptp.c
index 6b8df65..b477fa5 100644
--- a/drivers/net/ethernet/intel/e1000e/ptp.c
+++ b/drivers/net/ethernet/intel/e1000e/ptp.c
@@ -165,8 +165,9 @@ static int e1000e_phc_settime(struct ptp_clock_info *ptp,
  * Enable (or disable) ancillary features of the PHC subsystem.
  * Currently, no ancillary features are supported.
  **/
-static int e1000e_phc_enable(struct ptp_clock_info *ptp,
-			     struct ptp_clock_request *request, int on)
+static int e1000e_phc_enable(struct ptp_clock_info __always_unused *ptp,
+			     struct ptp_clock_request __always_unused *request,
+			     int __always_unused on)
 {
 	return -EOPNOTSUPP;
 }
-- 
1.7.11.7
