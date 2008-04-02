From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 4/5] e1000e: rename a few functions
Date: Wed, 02 Apr 2008 13:48:18 -0700
Message-ID: <20080402204818.29122.51388.stgit@localhost.localdomain>
References: <20080402204802.29122.81707.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080402204802.29122.81707.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Several minor cosmetic function renames.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/82571.c   |    8 ++++----
 drivers/net/e1000e/e1000.h   |    4 ++--
 drivers/net/e1000e/es2lan.c  |    4 ++--
 drivers/net/e1000e/ich8lan.c |    6 +++---
 drivers/net/e1000e/lib.c     |    6 +++---
 drivers/net/e1000e/netdev.c  |    8 ++++----
 6 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 85e4764..01c8866 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -248,7 +248,7 @@ static s32 e1000_init_mac_params_82571(struct e1000_adapter *adapter)
 	return 0;
 }
 
-static s32 e1000_get_invariants_82571(struct e1000_adapter *adapter)
+static s32 e1000_get_variants_82571(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	static int global_quad_port_a; /* global port a indication */
@@ -1337,7 +1337,7 @@ struct e1000_info e1000_82571_info = {
 				  | FLAG_TARC_SPEED_MODE_BIT /* errata */
 				  | FLAG_APME_CHECK_PORT_B,
 	.pba			= 38,
-	.get_invariants		= e1000_get_invariants_82571,
+	.get_variants		= e1000_get_variants_82571,
 	.mac_ops		= &e82571_mac_ops,
 	.phy_ops		= &e82_phy_ops_igp,
 	.nvm_ops		= &e82571_nvm_ops,
@@ -1355,7 +1355,7 @@ struct e1000_info e1000_82572_info = {
 				  | FLAG_HAS_STATS_ICR_ICT
 				  | FLAG_TARC_SPEED_MODE_BIT, /* errata */
 	.pba			= 38,
-	.get_invariants		= e1000_get_invariants_82571,
+	.get_variants		= e1000_get_variants_82571,
 	.mac_ops		= &e82571_mac_ops,
 	.phy_ops		= &e82_phy_ops_igp,
 	.nvm_ops		= &e82571_nvm_ops,
@@ -1375,7 +1375,7 @@ struct e1000_info e1000_82573_info = {
 				  | FLAG_HAS_ERT
 				  | FLAG_HAS_SWSM_ON_LOAD,
 	.pba			= 20,
-	.get_invariants		= e1000_get_invariants_82571,
+	.get_variants		= e1000_get_variants_82571,
 	.mac_ops		= &e82571_mac_ops,
 	.phy_ops		= &e82_phy_ops_m88,
 	.nvm_ops		= &e82571_nvm_ops,
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index b941a6b..5a89dff 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -271,7 +271,7 @@ struct e1000_info {
 	enum e1000_mac_type	mac;
 	unsigned int		flags;
 	u32			pba;
-	s32			(*get_invariants)(struct e1000_adapter *);
+	s32			(*get_variants)(struct e1000_adapter *);
 	struct e1000_mac_operations *mac_ops;
 	struct e1000_phy_operations *phy_ops;
 	struct e1000_nvm_operations *nvm_ops;
@@ -357,7 +357,7 @@ extern struct e1000_info e1000_ich8_info;
 extern struct e1000_info e1000_ich9_info;
 extern struct e1000_info e1000_es2_info;
 
-extern s32 e1000e_read_part_num(struct e1000_hw *hw, u32 *part_num);
+extern s32 e1000e_read_pba_num(struct e1000_hw *hw, u32 *pba_num);
 
 extern s32  e1000e_commit_phy(struct e1000_hw *hw);
 
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 10e17cf..d59a99a 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -238,7 +238,7 @@ static s32 e1000_init_mac_params_80003es2lan(struct e1000_adapter *adapter)
 	return 0;
 }
 
-static s32 e1000_get_invariants_80003es2lan(struct e1000_adapter *adapter)
+static s32 e1000_get_variants_80003es2lan(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	s32 rc;
@@ -1243,7 +1243,7 @@ struct e1000_info e1000_es2_info = {
 				  | FLAG_DISABLE_FC_PAUSE_TIME /* errata */
 				  | FLAG_TIPG_MEDIUM_FOR_80003ESLAN,
 	.pba			= 38,
-	.get_invariants		= e1000_get_invariants_80003es2lan,
+	.get_variants		= e1000_get_variants_80003es2lan,
 	.mac_ops		= &es2_mac_ops,
 	.phy_ops		= &es2_phy_ops,
 	.nvm_ops		= &es2_nvm_ops,
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index bbb51e1..768485d 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -316,7 +316,7 @@ static s32 e1000_init_mac_params_ich8lan(struct e1000_adapter *adapter)
 	return 0;
 }
 
-static s32 e1000_get_invariants_ich8lan(struct e1000_adapter *adapter)
+static s32 e1000_get_variants_ich8lan(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	s32 rc;
@@ -2253,7 +2253,7 @@ struct e1000_info e1000_ich8_info = {
 				  | FLAG_HAS_FLASH
 				  | FLAG_APME_IN_WUC,
 	.pba			= 8,
-	.get_invariants		= e1000_get_invariants_ich8lan,
+	.get_variants		= e1000_get_variants_ich8lan,
 	.mac_ops		= &ich8_mac_ops,
 	.phy_ops		= &ich8_phy_ops,
 	.nvm_ops		= &ich8_nvm_ops,
@@ -2270,7 +2270,7 @@ struct e1000_info e1000_ich9_info = {
 				  | FLAG_HAS_FLASH
 				  | FLAG_APME_IN_WUC,
 	.pba			= 10,
-	.get_invariants		= e1000_get_invariants_ich8lan,
+	.get_variants		= e1000_get_variants_ich8lan,
 	.mac_ops		= &ich8_mac_ops,
 	.phy_ops		= &ich8_phy_ops,
 	.nvm_ops		= &ich8_nvm_ops,
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index ea3ff63..f1f4e9d 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -2477,7 +2477,7 @@ bool e1000e_enable_mng_pass_thru(struct e1000_hw *hw)
 	return ret_val;
 }
 
-s32 e1000e_read_part_num(struct e1000_hw *hw, u32 *part_num)
+s32 e1000e_read_pba_num(struct e1000_hw *hw, u32 *pba_num)
 {
 	s32 ret_val;
 	u16 nvm_data;
@@ -2487,14 +2487,14 @@ s32 e1000e_read_part_num(struct e1000_hw *hw, u32 *part_num)
 		hw_dbg(hw, "NVM Read Error\n");
 		return ret_val;
 	}
-	*part_num = (u32)(nvm_data << 16);
+	*pba_num = (u32)(nvm_data << 16);
 
 	ret_val = e1000_read_nvm(hw, NVM_PBA_OFFSET_1, 1, &nvm_data);
 	if (ret_val) {
 		hw_dbg(hw, "NVM Read Error\n");
 		return ret_val;
 	}
-	*part_num |= nvm_data;
+	*pba_num |= nvm_data;
 
 	return 0;
 }
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index b8bb4fe..c8dc47f 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3824,7 +3824,7 @@ static void e1000_print_device_info(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
-	u32 part_num;
+	u32 pba_num;
 
 	/* print bus type/speed/width info */
 	ndev_info(netdev, "(PCI Express:2.5GB/s:%s) "
@@ -3839,10 +3839,10 @@ static void e1000_print_device_info(struct e1000_adapter *adapter)
 	ndev_info(netdev, "Intel(R) PRO/%s Network Connection\n",
 		  (hw->phy.type == e1000_phy_ife)
 		   ? "10/100" : "1000");
-	e1000e_read_part_num(hw, &part_num);
+	e1000e_read_pba_num(hw, &pba_num);
 	ndev_info(netdev, "MAC: %d, PHY: %d, PBA No: %06x-%03x\n",
 		  hw->mac.type, hw->phy.type,
-		  (part_num >> 8), (part_num & 0xff));
+		  (pba_num >> 8), (pba_num & 0xff));
 }
 
 /**
@@ -3974,7 +3974,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	memcpy(&hw->nvm.ops, ei->nvm_ops, sizeof(hw->nvm.ops));
 	memcpy(&hw->phy.ops, ei->phy_ops, sizeof(hw->phy.ops));
 
-	err = ei->get_invariants(adapter);
+	err = ei->get_variants(adapter);
 	if (err)
 		goto err_hw_init;
 


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
