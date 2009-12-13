From: re.emese@gmail.com
Subject: [PATCH 1/3] Constify struct e1000_mac_operations 2.6.32-git-a252e7 v2
Date: Mon, 14 Dec 2009 00:59:40 +0100
Message-ID: <2e6aa47e1fb4d002daf67ee374e7608d5fabe944.1260707013.git.re.emese@gmail.com>
References: <cover.1260707013.git.re.emese@gmail.com>
Cc: Emese Revfy <re.emese@gmail.com>, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, davem@davemloft.net
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756008AbZLNAQr@vger.kernel.org>
In-Reply-To: <cover.1260707013.git.re.emese@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Emese Revfy <re.emese@gmail.com>


Signed-off-by: Emese Revfy <re.emese@gmail.com>
---
 drivers/net/e1000e/82571.c    |    3 ++-
 drivers/net/e1000e/e1000.h    |    2 +-
 drivers/net/e1000e/es2lan.c   |    3 ++-
 drivers/net/e1000e/hw.h       |    1 +
 drivers/net/e1000e/ich8lan.c  |    2 +-
 drivers/net/igb/e1000_82575.c |    2 +-
 drivers/net/igb/e1000_hw.h    |    3 ++-
 drivers/net/igbvf/vf.h        |    1 +
 8 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index c1a42cf..f388cba 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -207,6 +207,7 @@ static s32 e1000_init_mac_params_82571(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_mac_info *mac = &hw->mac;
+	/* cannot be const, see this function */
 	struct e1000_mac_operations *func = &mac->ops;
 	u32 swsm = 0;
 	u32 swsm2 = 0;
@@ -1692,7 +1693,7 @@ static void e1000_clear_hw_cntrs_82571(struct e1000_hw *hw)
 	er32(ICRXDMTC);
 }
 
-static struct e1000_mac_operations e82571_mac_ops = {
+static const struct e1000_mac_operations e82571_mac_ops = {
 	/* .check_mng_mode: mac type dependent */
 	/* .check_for_link: media type dependent */
 	.id_led_init		= e1000e_id_led_init,
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index cebbd90..68e66b2 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -379,7 +379,7 @@ struct e1000_info {
 	u32			pba;
 	u32			max_hw_frame_size;
 	s32			(*get_variants)(struct e1000_adapter *);
-	struct e1000_mac_operations *mac_ops;
+	const struct e1000_mac_operations *mac_ops;
 	struct e1000_phy_operations *phy_ops;
 	struct e1000_nvm_operations *nvm_ops;
 };
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index d2a1047..c44d30a 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -202,6 +202,7 @@ static s32 e1000_init_mac_params_80003es2lan(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_mac_info *mac = &hw->mac;
+	/* cannot be const, see this function */
 	struct e1000_mac_operations *func = &mac->ops;
 
 	/* Set media type */
@@ -1369,7 +1370,7 @@ static void e1000_clear_hw_cntrs_80003es2lan(struct e1000_hw *hw)
 	er32(ICRXDMTC);
 }
 
-static struct e1000_mac_operations es2_mac_ops = {
+static const struct e1000_mac_operations es2_mac_ops = {
 	.id_led_init		= e1000e_id_led_init,
 	.check_mng_mode		= e1000e_check_mng_mode_generic,
 	/* check_for_link dependent on media type */
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index a7d08da..2238d4d 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -791,6 +791,7 @@ struct e1000_nvm_operations {
 };
 
 struct e1000_mac_info {
+	/* cannot be const, see drivers/net/e1000e/ich8lan.c:e1000_init_mac_params_ich8lan */
 	struct e1000_mac_operations ops;
 
 	u8 addr[6];
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 7b33be9..614a0d4 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -3291,7 +3291,7 @@ static void e1000_clear_hw_cntrs_ich8lan(struct e1000_hw *hw)
 	}
 }
 
-static struct e1000_mac_operations ich8_mac_ops = {
+static const struct e1000_mac_operations ich8_mac_ops = {
 	.id_led_init		= e1000e_id_led_init,
 	.check_mng_mode		= e1000_check_mng_mode_ich8lan,
 	.check_for_link		= e1000_check_for_copper_link_ich8lan,
diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index e8e9e91..34b847a 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -1585,7 +1585,7 @@ u16 igb_rxpbs_adjust_82580(u32 data)
 	return ret_val;
 }
 
-static struct e1000_mac_operations e1000_mac_ops_82575 = {
+static const struct e1000_mac_operations e1000_mac_ops_82575 = {
 	.init_hw              = igb_init_hw_82575,
 	.check_for_link       = igb_check_for_link_82575,
 	.rar_set              = igb_rar_set,
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index dbaeb5f..854b252 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -324,7 +324,7 @@ struct e1000_nvm_operations {
 
 struct e1000_info {
 	s32 (*get_invariants)(struct e1000_hw *);
-	struct e1000_mac_operations *mac_ops;
+	const struct e1000_mac_operations *mac_ops;
 	struct e1000_phy_operations *phy_ops;
 	struct e1000_nvm_operations *nvm_ops;
 };
@@ -332,6 +332,7 @@ struct e1000_info {
 extern const struct e1000_info e1000_82575_info;
 
 struct e1000_mac_info {
+	/* cannot be const, see drivers/net/igb/e1000_82575.c:igb_get_invariants_82575 */
 	struct e1000_mac_operations ops;
 
 	u8 addr[6];
diff --git a/drivers/net/igbvf/vf.h b/drivers/net/igbvf/vf.h
index 1e8ce37..4f12659 100644
--- a/drivers/net/igbvf/vf.h
+++ b/drivers/net/igbvf/vf.h
@@ -189,6 +189,7 @@ struct e1000_mac_operations {
 };
 
 struct e1000_mac_info {
+	/* cannot be const, see drivers/net/igbvf/vf.c:e1000_init_mac_params_vf */
 	struct e1000_mac_operations ops;
 	u8 addr[6];
 	u8 perm_addr[6];
-- 
1.6.5.3
