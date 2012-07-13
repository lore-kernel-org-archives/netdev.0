From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 2/8] ethernet: Use eth_random_addr
Date: Thu, 12 Jul 2012 22:33:06 -0700
Message-ID: <4a900f859bae29a1bb3051366a61663438ca467f.1342157022.git.joe@perches.com>
References: <1341968967.13724.23.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jay Cliburn <jcliburn@gmail.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, Chris Snook <chris.snook@gmail.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, John Ronciak <john.ronciak@intel.com>,
	Johannes Berg <johannes@sipsolutions.net>
To: David Miller <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Chris Metcalf <cmetcalf@tilera.com>, Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1341968967.13724.23.camel@joe2Laptop>
In-Reply-To: <cover.1342157022.git.joe@perches.com>
References: <cover.1342157022.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Convert the existing uses of random_ether_addr to
the new eth_random_addr.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.c     |    2 +-
 drivers/net/ethernet/atheros/atlx/atl1.c          |    2 +-
 drivers/net/ethernet/atheros/atlx/atl2.c          |    2 +-
 drivers/net/ethernet/ethoc.c                      |    2 +-
 drivers/net/ethernet/intel/igb/igb_main.c         |    4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |    2 +-
 drivers/net/ethernet/lantiq_etop.c                |    2 +-
 drivers/net/ethernet/micrel/ks8851.c              |    2 +-
 drivers/net/ethernet/micrel/ks8851_mll.c          |    2 +-
 drivers/net/ethernet/smsc/smsc911x.c              |    2 +-
 drivers/net/ethernet/ti/cpsw.c                    |    2 +-
 drivers/net/ethernet/tile/tilegx.c                |    2 +-
 drivers/net/ethernet/wiznet/w5100.c               |    2 +-
 drivers/net/ethernet/wiznet/w5300.c               |    2 +-
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c |    2 +-
 15 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
index 801f012..21e261f 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
@@ -199,7 +199,7 @@ int atl1c_read_mac_addr(struct atl1c_hw *hw)
 
 	err = atl1c_get_permanent_address(hw);
 	if (err)
-		random_ether_addr(hw->perm_mac_addr);
+		eth_random_addr(hw->perm_mac_addr);
 
 	memcpy(hw->mac_addr, hw->perm_mac_addr, sizeof(hw->perm_mac_addr));
 	return err;
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index f2402f3..7bae2ad 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -538,7 +538,7 @@ static s32 atl1_read_mac_addr(struct atl1_hw *hw)
 	u16 i;
 
 	if (atl1_get_permanent_address(hw)) {
-		random_ether_addr(hw->perm_mac_addr);
+		eth_random_addr(hw->perm_mac_addr);
 		ret = 1;
 	}
 
diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
index 7c0b7e2..57d64b8 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -2346,7 +2346,7 @@ static s32 atl2_read_mac_addr(struct atl2_hw *hw)
 {
 	if (get_permanent_address(hw)) {
 		/* for test */
-		/* FIXME: shouldn't we use random_ether_addr() here? */
+		/* FIXME: shouldn't we use eth_random_addr() here? */
 		hw->perm_mac_addr[0] = 0x00;
 		hw->perm_mac_addr[1] = 0x13;
 		hw->perm_mac_addr[2] = 0x74;
diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 2029788..94b7bfc 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -1057,7 +1057,7 @@ static int __devinit ethoc_probe(struct platform_device *pdev)
 	/* Check the MAC again for validity, if it still isn't choose and
 	 * program a random one. */
 	if (!is_valid_ether_addr(netdev->dev_addr)) {
-		random_ether_addr(netdev->dev_addr);
+		eth_random_addr(netdev->dev_addr);
 		random_mac = true;
 	}
 
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 60e3075..8adeca9 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5008,7 +5008,7 @@ static int igb_vf_configure(struct igb_adapter *adapter, int vf)
 	unsigned int device_id;
 	u16 thisvf_devfn;
 
-	random_ether_addr(mac_addr);
+	eth_random_addr(mac_addr);
 	igb_set_vf_mac(adapter, vf, mac_addr);
 
 	switch (adapter->hw.mac.type) {
@@ -5417,7 +5417,7 @@ static void igb_vf_reset_event(struct igb_adapter *adapter, u32 vf)
 
 	/* generate a new mac address as we were hotplug removed/added */
 	if (!(adapter->vf_data[vf].flags & IGB_VF_FLAG_PF_SET_MAC))
-		random_ether_addr(vf_mac);
+		eth_random_addr(vf_mac);
 
 	/* process remaining reset events */
 	igb_vf_reset(adapter, vf);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 2d971d1..eb3f67c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -467,7 +467,7 @@ int ixgbe_vf_configuration(struct pci_dev *pdev, unsigned int event_mask)
 	bool enable = ((event_mask & 0x10000000U) != 0);
 
 	if (enable) {
-		random_ether_addr(vf_mac_addr);
+		eth_random_addr(vf_mac_addr);
 		e_info(probe, "IOV: VF %d is enabled MAC %pM\n",
 		       vfn, vf_mac_addr);
 		/*
diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 9fa39eb..003c5bc 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -645,7 +645,7 @@ ltq_etop_init(struct net_device *dev)
 	memcpy(&mac, &priv->pldata->mac, sizeof(struct sockaddr));
 	if (!is_valid_ether_addr(mac.sa_data)) {
 		pr_warn("etop: invalid MAC, using random\n");
-		random_ether_addr(mac.sa_data);
+		eth_random_addr(mac.sa_data);
 		random_mac = true;
 	}
 
diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index 5e313e9..1540ebe 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -422,7 +422,7 @@ static void ks8851_read_mac_addr(struct net_device *dev)
  *
  * Get or create the initial mac address for the device and then set that
  * into the station address register. If there is an EEPROM present, then
- * we try that. If no valid mac address is found we use random_ether_addr()
+ * we try that. If no valid mac address is found we use eth_random_addr()
  * to create a new one.
  */
 static void ks8851_init_mac(struct ks8851_net *ks)
diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index 59ef568..38529ed 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -1609,7 +1609,7 @@ static int __devinit ks8851_probe(struct platform_device *pdev)
 	memcpy(ks->mac_addr, pdata->mac_addr, 6);
 	if (!is_valid_ether_addr(ks->mac_addr)) {
 		/* Use random MAC address if none passed */
-		random_ether_addr(ks->mac_addr);
+		eth_random_addr(ks->mac_addr);
 		netdev_info(netdev, "Using random mac address\n");
 	}
 	netdev_info(netdev, "Mac address is: %pM\n", ks->mac_addr);
diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 54ca99d..62d1baf 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2488,7 +2488,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 			eth_hw_addr_random(dev);
 			smsc911x_set_hw_mac_address(pdata, dev->dev_addr);
 			SMSC_TRACE(pdata, probe,
-				   "MAC Address is set to random_ether_addr");
+				   "MAC Address is set to eth_random_addr");
 		}
 	}
 
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 6685bbb..ca381d3 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -748,7 +748,7 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 		memcpy(priv->mac_addr, data->slave_data[0].mac_addr, ETH_ALEN);
 		pr_info("Detected MACID = %pM", priv->mac_addr);
 	} else {
-		random_ether_addr(priv->mac_addr);
+		eth_random_addr(priv->mac_addr);
 		pr_info("Random MACID = %pM", priv->mac_addr);
 	}
 
diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 83b4b38..7f50028 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -1844,7 +1844,7 @@ static void tile_net_dev_init(const char *name, const uint8_t *mac)
 		memcpy(dev->dev_addr, mac, 6);
 		dev->addr_len = 6;
 	} else {
-		random_ether_addr(dev->dev_addr);
+		eth_random_addr(dev->dev_addr);
 	}
 
 	/* Register the network device. */
diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index a75e9ef..a5826a3 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -637,7 +637,7 @@ static int __devinit w5100_hw_probe(struct platform_device *pdev)
 	if (data && is_valid_ether_addr(data->mac_addr)) {
 		memcpy(ndev->dev_addr, data->mac_addr, ETH_ALEN);
 	} else {
-		random_ether_addr(ndev->dev_addr);
+		eth_random_addr(ndev->dev_addr);
 		ndev->addr_assign_type |= NET_ADDR_RANDOM;
 	}
 
diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
index 3306a20..bdd8891 100644
--- a/drivers/net/ethernet/wiznet/w5300.c
+++ b/drivers/net/ethernet/wiznet/w5300.c
@@ -557,7 +557,7 @@ static int __devinit w5300_hw_probe(struct platform_device *pdev)
 	if (data && is_valid_ether_addr(data->mac_addr)) {
 		memcpy(ndev->dev_addr, data->mac_addr, ETH_ALEN);
 	} else {
-		random_ether_addr(ndev->dev_addr);
+		eth_random_addr(ndev->dev_addr);
 		ndev->addr_assign_type |= NET_ADDR_RANDOM;
 	}
 
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 9c365e1..0793299 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -312,7 +312,7 @@ static void axienet_set_mac_address(struct net_device *ndev, void *address)
 	if (address)
 		memcpy(ndev->dev_addr, address, ETH_ALEN);
 	if (!is_valid_ether_addr(ndev->dev_addr))
-		random_ether_addr(ndev->dev_addr);
+		eth_random_addr(ndev->dev_addr);
 
 	/* Set up unicast MAC address filter set its mac address */
 	axienet_iow(lp, XAE_UAW0_OFFSET,
-- 
1.7.8.111.gad25c.dirty


------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
