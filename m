From: Emese Revfy <re.emese@gmail.com>
Subject: Re: [PATCH 06/31] Constify struct e1000_mac_operations for 2.6.32
 v1
Date: Sat, 05 Dec 2009 01:03:03 +0100
Message-ID: <4B19A337.6060808__17807.1881448433$1259971303$gmane$org@gmail.com>
References: <4B198670.2000406@gmail.com> <4B198A33.7080705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com, torvalds@linux-foundation.org,
	linux-kernel@
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:39894 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932635AbZLEABM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2009 19:01:12 -0500
In-Reply-To: <4B198A33.7080705@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emese Revfy <re.emese@gmail.com>

Constify struct e1000_mac_operations with some exceptions.
Per Dave Miller's suggestion, resend with proper CC list and patch format.

Signed-off-by: Emese Revfy <re.emese@gmail.com>
---
 drivers/net/e1000e/82571.c    |    3 ++-
 drivers/net/e1000e/e1000.h    |    2 +-
 drivers/net/e1000e/es2lan.c   |    3 ++-
 drivers/net/e1000e/ich8lan.c  |    2 +-
 drivers/net/igb/e1000_82575.c |    2 +-
 drivers/net/igb/e1000_hw.h    |    2 +-
 6 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index d1e0563..16ffb11 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -212,6 +212,7 @@ static s32 e1000_init_mac_params_82571(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_mac_info *mac = &hw->mac;
+	/* cannot be const */
 	struct e1000_mac_operations *func = &mac->ops;
 	u32 swsm = 0;
 	u32 swsm2 = 0;
@@ -1656,7 +1657,7 @@ static void e1000_clear_hw_cntrs_82571(struct e1000_hw *hw)
 	temp = er32(ICRXDMTC);
 }
 
-static struct e1000_mac_operations e82571_mac_ops = {
+static const struct e1000_mac_operations e82571_mac_ops = {
 	/* .check_mng_mode: mac type dependent */
 	/* .check_for_link: media type dependent */
 	.id_led_init		= e1000e_id_led_init,
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 3e187b0..933f5da 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -375,7 +375,7 @@ struct e1000_info {
 	u32			pba;
 	u32			max_hw_frame_size;
 	s32			(*get_variants)(struct e1000_adapter *);
-	struct e1000_mac_operations *mac_ops;
+	const struct e1000_mac_operations *mac_ops;
 	struct e1000_phy_operations *phy_ops;
 	struct e1000_nvm_operations *nvm_ops;
 };
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index ae5d736..06d47e0 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -207,6 +207,7 @@ static s32 e1000_init_mac_params_80003es2lan(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_mac_info *mac = &hw->mac;
+	/* cannot be const */
 	struct e1000_mac_operations *func = &mac->ops;
 
 	/* Set media type */
@@ -1365,7 +1366,7 @@ static void e1000_clear_hw_cntrs_80003es2lan(struct e1000_hw *hw)
 	temp = er32(ICRXDMTC);
 }
 
-static struct e1000_mac_operations es2_mac_ops = {
+static const struct e1000_mac_operations es2_mac_ops = {
 	.id_led_init		= e1000e_id_led_init,
 	.check_mng_mode		= e1000e_check_mng_mode_generic,
 	/* check_for_link dependent on media type */
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index eff3f47..3e0065b 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -3451,7 +3451,7 @@ static void e1000_clear_hw_cntrs_ich8lan(struct e1000_hw *hw)
 	}
 }
 
-static struct e1000_mac_operations ich8_mac_ops = {
+static const struct e1000_mac_operations ich8_mac_ops = {
 	.id_led_init		= e1000e_id_led_init,
 	.check_mng_mode		= e1000_check_mng_mode_ich8lan,
 	.check_for_link		= e1000_check_for_copper_link_ich8lan,
diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index f8f5772..3d5794f 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -1400,7 +1400,7 @@ void igb_vmdq_set_replication_pf(struct e1000_hw *hw, bool enable)
 	wr32(E1000_VT_CTL, vt_ctl);
 }
 
-static struct e1000_mac_operations e1000_mac_ops_82575 = {
+static const struct e1000_mac_operations e1000_mac_ops_82575 = {
 	.reset_hw             = igb_reset_hw_82575,
 	.init_hw              = igb_init_hw_82575,
 	.check_for_link       = igb_check_for_link_82575,
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 119869b..d58b7e5 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -310,7 +310,7 @@ struct e1000_nvm_operations {
 
 struct e1000_info {
 	s32 (*get_invariants)(struct e1000_hw *);
-	struct e1000_mac_operations *mac_ops;
+	const struct e1000_mac_operations *mac_ops;
 	struct e1000_phy_operations *phy_ops;
 	struct e1000_nvm_operations *nvm_ops;
 };

