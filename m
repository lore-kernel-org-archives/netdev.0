From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] e1000: use netdev_priv
Date: Wed, 5 Jan 2005 15:19:10 -0800
Message-ID: <20050105151910.1e9a50fe@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeb Cramer <cramerj@intel.com>, john.ronciak@intel.com,
        ganesh.venkatesan@intel.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert e1000 to use netdev_priv which should generate better code

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
--- a/drivers/net/e1000/e1000_ethtool.c	2005-01-05 13:53:02 -08:00
+++ b/drivers/net/e1000/e1000_ethtool.c	2005-01-05 13:53:02 -08:00
@@ -104,7 +104,7 @@
 static int
 e1000_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
 	if(hw->media_type == e1000_media_type_copper) {
@@ -178,7 +178,7 @@
 static int
 e1000_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
 	if(ecmd->autoneg == AUTONEG_ENABLE) {
@@ -205,7 +205,7 @@
 e1000_get_pauseparam(struct net_device *netdev,
                      struct ethtool_pauseparam *pause)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
 	pause->autoneg = 
@@ -225,7 +225,7 @@
 e1000_set_pauseparam(struct net_device *netdev,
                      struct ethtool_pauseparam *pause)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	
 	adapter->fc_autoneg = pause->autoneg;
@@ -258,14 +258,14 @@
 static uint32_t
 e1000_get_rx_csum(struct net_device *netdev)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	return adapter->rx_csum;
 }
 
 static int
 e1000_set_rx_csum(struct net_device *netdev, uint32_t data)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	adapter->rx_csum = data;
 
 	if(netif_running(netdev)) {
@@ -285,7 +285,7 @@
 static int
 e1000_set_tx_csum(struct net_device *netdev, uint32_t data)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 
 	if(adapter->hw.mac_type < e1000_82543) {
 		if (!data)
@@ -305,7 +305,7 @@
 static int
 e1000_set_tso(struct net_device *netdev, uint32_t data)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	if ((adapter->hw.mac_type < e1000_82544) ||
 	    (adapter->hw.mac_type == e1000_82547)) 
 		return data ? -EINVAL : 0;
@@ -321,14 +321,14 @@
 static uint32_t
 e1000_get_msglevel(struct net_device *netdev)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	return adapter->msg_enable;
 }
 
 static void
 e1000_set_msglevel(struct net_device *netdev, uint32_t data)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	adapter->msg_enable = data;
 }
 
@@ -343,7 +343,7 @@
 e1000_get_regs(struct net_device *netdev,
 	       struct ethtool_regs *regs, void *p)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	uint32_t *regs_buff = p;
 	uint16_t phy_data;
@@ -431,7 +431,7 @@
 static int
 e1000_get_eeprom_len(struct net_device *netdev)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	return adapter->hw.eeprom.word_size * 2;
 }
 
@@ -439,7 +439,7 @@
 e1000_get_eeprom(struct net_device *netdev,
                       struct ethtool_eeprom *eeprom, uint8_t *bytes)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	uint16_t *eeprom_buff;
 	int first_word, last_word;
@@ -485,7 +485,7 @@
 e1000_set_eeprom(struct net_device *netdev,
                       struct ethtool_eeprom *eeprom, uint8_t *bytes)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	uint16_t *eeprom_buff;
 	void *ptr;
@@ -546,7 +546,7 @@
 e1000_get_drvinfo(struct net_device *netdev,
                        struct ethtool_drvinfo *drvinfo)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 
 	strncpy(drvinfo->driver,  e1000_driver_name, 32);
 	strncpy(drvinfo->version, e1000_driver_version, 32);
@@ -562,7 +562,7 @@
 e1000_get_ringparam(struct net_device *netdev,
                     struct ethtool_ringparam *ring)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	e1000_mac_type mac_type = adapter->hw.mac_type;
 	struct e1000_desc_ring *txdr = &adapter->tx_ring;
 	struct e1000_desc_ring *rxdr = &adapter->rx_ring;
@@ -583,7 +583,7 @@
 e1000_set_ringparam(struct net_device *netdev,
                     struct ethtool_ringparam *ring)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	e1000_mac_type mac_type = adapter->hw.mac_type;
 	struct e1000_desc_ring *txdr = &adapter->tx_ring;
 	struct e1000_desc_ring *rxdr = &adapter->rx_ring;
@@ -765,7 +765,7 @@
 		struct pt_regs *regs)
 {
 	struct net_device *netdev = (struct net_device *) data;
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 
 	adapter->test_icr |= E1000_READ_REG(&adapter->hw, ICR);
 
@@ -1376,7 +1376,7 @@
 e1000_diag_test(struct net_device *netdev,
 		   struct ethtool_test *eth_test, uint64_t *data)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	boolean_t if_running = netif_running(netdev);
 
 	if(eth_test->flags == ETH_TEST_FL_OFFLINE) {
@@ -1436,7 +1436,7 @@
 static void
 e1000_get_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
 	switch(adapter->hw.device_id) {
@@ -1481,7 +1481,7 @@
 static int
 e1000_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
 	switch(adapter->hw.device_id) {
@@ -1540,7 +1540,7 @@
 static int
 e1000_phys_id(struct net_device *netdev, uint32_t data)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 
 	if(!data || data > (uint32_t)(MAX_SCHEDULE_TIMEOUT / HZ))
 		data = (uint32_t)(MAX_SCHEDULE_TIMEOUT / HZ);
@@ -1568,7 +1568,7 @@
 static int
 e1000_nway_reset(struct net_device *netdev)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	if(netif_running(netdev)) {
 		e1000_down(adapter);
 		e1000_up(adapter);
@@ -1586,7 +1586,7 @@
 e1000_get_ethtool_stats(struct net_device *netdev, 
 		struct ethtool_stats *stats, uint64_t *data)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	int i;
 
 	e1000_update_stats(adapter);
diff -Nru a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
--- a/drivers/net/e1000/e1000_main.c	2005-01-05 13:53:02 -08:00
+++ b/drivers/net/e1000/e1000_main.c	2005-01-05 13:53:02 -08:00
@@ -411,7 +411,7 @@
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
 	pci_set_drvdata(pdev, netdev);
-	adapter = netdev->priv;
+	adapter = netdev_priv(netdev);
 	adapter->netdev = netdev;
 	adapter->pdev = pdev;
 	adapter->hw.back = adapter;
@@ -608,7 +608,7 @@
 e1000_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	uint32_t manc;
 
 	if(adapter->hw.mac_type >= e1000_82540 &&
@@ -723,7 +723,7 @@
 static int
 e1000_open(struct net_device *netdev)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	int err;
 
 	/* allocate transmit descriptors */
@@ -766,7 +766,7 @@
 static int
 e1000_close(struct net_device *netdev)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 
 	e1000_down(adapter);
 
@@ -1226,7 +1226,7 @@
 static int
 e1000_set_mac(struct net_device *netdev, void *p)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct sockaddr *addr = p;
 
 	if(!is_valid_ether_addr(addr->sa_data))
@@ -1261,7 +1261,7 @@
 static void
 e1000_set_multi(struct net_device *netdev)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	struct dev_mc_list *mc_ptr;
 	uint32_t rctl;
@@ -1752,7 +1752,7 @@
 static int
 e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	unsigned int first, max_per_txd = E1000_MAX_DATA_PER_TXD;
 	unsigned int max_txd_pwr = E1000_MAX_TXD_PWR;
 	unsigned int tx_flags = 0;
@@ -1856,7 +1856,7 @@
 static void
 e1000_tx_timeout(struct net_device *netdev)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 
 	/* Do the reset outside of interrupt context */
 	schedule_work(&adapter->tx_timeout_task);
@@ -1865,7 +1865,7 @@
 static void
 e1000_tx_timeout_task(struct net_device *netdev)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 
 	e1000_down(adapter);
 	e1000_up(adapter);
@@ -1882,7 +1882,7 @@
 static struct net_device_stats *
 e1000_get_stats(struct net_device *netdev)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 
 	e1000_update_stats(adapter);
 	return &adapter->net_stats;
@@ -1899,7 +1899,7 @@
 static int
 e1000_change_mtu(struct net_device *netdev, int new_mtu)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	int old_mtu = adapter->rx_buffer_len;
 	int max_frame = new_mtu + ENET_HEADER_SIZE + ETHERNET_FCS_SIZE;
 
@@ -2112,7 +2112,7 @@
 e1000_intr(int irq, void *data, struct pt_regs *regs)
 {
 	struct net_device *netdev = data;
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	uint32_t icr = E1000_READ_REG(hw, ICR);
 #ifndef CONFIG_E1000_NAPI
@@ -2157,7 +2157,7 @@
 static int
 e1000_clean(struct net_device *netdev, int *budget)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	int work_to_do = min(*budget, netdev->quota);
 	int tx_cleaned;
 	int work_done = 0;
@@ -2503,7 +2503,7 @@
 static int
 e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct mii_ioctl_data *data = if_mii(ifr);
 	int retval;
 	uint16_t mii_reg;
@@ -2670,7 +2670,7 @@
 static void
 e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	uint32_t ctrl, rctl;
 
 	e1000_irq_disable(adapter);
@@ -2705,7 +2705,7 @@
 static void
 e1000_vlan_rx_add_vid(struct net_device *netdev, uint16_t vid)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	uint32_t vfta, index;
 
 	/* add VID to filter table */
@@ -2718,7 +2718,7 @@
 static void
 e1000_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	uint32_t vfta, index;
 
 	e1000_irq_disable(adapter);
@@ -2802,7 +2802,7 @@
 e1000_suspend(struct pci_dev *pdev, uint32_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	uint32_t ctrl, ctrl_ext, rctl, manc, status;
 	uint32_t wufc = adapter->wol;
 
@@ -2882,7 +2882,7 @@
 e1000_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	uint32_t manc, ret;
 
 	pci_set_power_state(pdev, 0);
@@ -2922,7 +2922,7 @@
 static void
 e1000_netpoll (struct net_device *netdev)
 {
-	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	disable_irq(adapter->pdev->irq);
 	e1000_intr(adapter->pdev->irq, netdev, NULL);
 	enable_irq(adapter->pdev->irq);
