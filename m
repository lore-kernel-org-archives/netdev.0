From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 11/11] drivers/net/ethernet/intel: Remove
	useless return variables
Date: Sat, 31 May 2014 10:14:11 -0300
Message-ID: <1401542051-3174-11-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux NICS <linux.nics@intel.com>, e1000-devel@lists.sourceforge.net,
	kernel-janitors@vger.kernel.org, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This patch remove variables that are initialized with a constant,
are never updated, and are only used as parameter of return.
Return the constant instead of using a variable.

Verified by compilation only.

The coccinelle script that find and fixes this issue is:
// <smpl>
@@
type T;
constant C;
identifier ret;
@@
- T ret = C;
... when != ret
    when strict
return
- ret
+ C
;
// </smpl>

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c   |   12 +++---------
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c |   12 +++---------
 drivers/net/ethernet/intel/igb/e1000_82575.c    |   22 ++++++++--------------
 3 files changed, 14 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index 34415d3..524f8ca 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -464,8 +464,6 @@ init_adminq_exit:
  **/
 static i40e_status i40e_shutdown_asq(struct i40e_hw *hw)
 {
-	i40e_status ret_code = 0;
-
 	if (hw->aq.asq.count == 0)
 		return I40E_ERR_NOT_READY;
 
@@ -484,7 +482,7 @@ static i40e_status i40e_shutdown_asq(struct i40e_hw *hw)
 
 	mutex_unlock(&hw->aq.asq_mutex);
 
-	return ret_code;
+	return 0;
 }
 
 /**
@@ -495,8 +493,6 @@ static i40e_status i40e_shutdown_asq(struct i40e_hw *hw)
  **/
 static i40e_status i40e_shutdown_arq(struct i40e_hw *hw)
 {
-	i40e_status ret_code = 0;
-
 	if (hw->aq.arq.count == 0)
 		return I40E_ERR_NOT_READY;
 
@@ -515,7 +511,7 @@ static i40e_status i40e_shutdown_arq(struct i40e_hw *hw)
 
 	mutex_unlock(&hw->aq.arq_mutex);
 
-	return ret_code;
+	return 0;
 }
 
 /**
@@ -622,8 +618,6 @@ init_adminq_exit:
  **/
 i40e_status i40e_shutdown_adminq(struct i40e_hw *hw)
 {
-	i40e_status ret_code = 0;
-
 	if (i40e_check_asq_alive(hw))
 		i40e_aq_queue_shutdown(hw, true);
 
@@ -632,7 +626,7 @@ i40e_status i40e_shutdown_adminq(struct i40e_hw *hw)
 
 	/* destroy the locks */
 
-	return ret_code;
+	return 0;
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
index 68b4aac..1534c32 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
@@ -462,8 +462,6 @@ init_adminq_exit:
  **/
 static i40e_status i40e_shutdown_asq(struct i40e_hw *hw)
 {
-	i40e_status ret_code = 0;
-
 	if (hw->aq.asq.count == 0)
 		return I40E_ERR_NOT_READY;
 
@@ -482,7 +480,7 @@ static i40e_status i40e_shutdown_asq(struct i40e_hw *hw)
 
 	mutex_unlock(&hw->aq.asq_mutex);
 
-	return ret_code;
+	return 0;
 }
 
 /**
@@ -493,8 +491,6 @@ static i40e_status i40e_shutdown_asq(struct i40e_hw *hw)
  **/
 static i40e_status i40e_shutdown_arq(struct i40e_hw *hw)
 {
-	i40e_status ret_code = 0;
-
 	if (hw->aq.arq.count == 0)
 		return I40E_ERR_NOT_READY;
 
@@ -513,7 +509,7 @@ static i40e_status i40e_shutdown_arq(struct i40e_hw *hw)
 
 	mutex_unlock(&hw->aq.arq_mutex);
 
-	return ret_code;
+	return 0;
 }
 
 /**
@@ -574,8 +570,6 @@ init_adminq_exit:
  **/
 i40e_status i40evf_shutdown_adminq(struct i40e_hw *hw)
 {
-	i40e_status ret_code = 0;
-
 	if (i40evf_check_asq_alive(hw))
 		i40evf_aq_queue_shutdown(hw, true);
 
@@ -584,7 +578,7 @@ i40e_status i40evf_shutdown_adminq(struct i40e_hw *hw)
 
 	/* destroy the locks */
 
-	return ret_code;
+	return 0;
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index 2e36c67..0175290 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -1004,7 +1004,6 @@ out:
 static s32 igb_set_d0_lplu_state_82580(struct e1000_hw *hw, bool active)
 {
 	struct e1000_phy_info *phy = &hw->phy;
-	s32 ret_val = 0;
 	u16 data;
 
 	data = rd32(E1000_82580_PHY_POWER_MGMT);
@@ -1028,7 +1027,7 @@ static s32 igb_set_d0_lplu_state_82580(struct e1000_hw *hw, bool active)
 			data &= ~E1000_82580_PM_SPD; }
 
 	wr32(E1000_82580_PHY_POWER_MGMT, data);
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -1048,7 +1047,6 @@ static s32 igb_set_d0_lplu_state_82580(struct e1000_hw *hw, bool active)
 static s32 igb_set_d3_lplu_state_82580(struct e1000_hw *hw, bool active)
 {
 	struct e1000_phy_info *phy = &hw->phy;
-	s32 ret_val = 0;
 	u16 data;
 
 	data = rd32(E1000_82580_PHY_POWER_MGMT);
@@ -1073,7 +1071,7 @@ static s32 igb_set_d3_lplu_state_82580(struct e1000_hw *hw, bool active)
 	}
 
 	wr32(E1000_82580_PHY_POWER_MGMT, data);
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -1199,7 +1197,6 @@ static void igb_release_swfw_sync_82575(struct e1000_hw *hw, u16 mask)
 static s32 igb_get_cfg_done_82575(struct e1000_hw *hw)
 {
 	s32 timeout = PHY_CFG_TIMEOUT;
-	s32 ret_val = 0;
 	u32 mask = E1000_NVM_CFG_DONE_PORT_0;
 
 	if (hw->bus.func == 1)
@@ -1223,7 +1220,7 @@ static s32 igb_get_cfg_done_82575(struct e1000_hw *hw)
 	    (hw->phy.type == e1000_phy_igp_3))
 		igb_phy_init_script_igp3(hw);
 
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -2552,7 +2549,6 @@ s32 igb_read_emi_reg(struct e1000_hw *hw, u16 addr, u16 *data)
  **/
 s32 igb_set_eee_i350(struct e1000_hw *hw)
 {
-	s32 ret_val = 0;
 	u32 ipcnfg, eeer;
 
 	if ((hw->mac.type < e1000_i350) ||
@@ -2586,7 +2582,7 @@ s32 igb_set_eee_i350(struct e1000_hw *hw)
 	rd32(E1000_EEER);
 out:
 
-	return ret_val;
+	return 0;
 }
 
 /**
@@ -2713,7 +2709,6 @@ static const u8 e1000_emc_therm_limit[4] = {
  **/
 static s32 igb_get_thermal_sensor_data_generic(struct e1000_hw *hw)
 {
-	s32 status = E1000_SUCCESS;
 	u16 ets_offset;
 	u16 ets_cfg;
 	u16 ets_sensor;
@@ -2731,7 +2726,7 @@ static s32 igb_get_thermal_sensor_data_generic(struct e1000_hw *hw)
 	/* Return the internal sensor only if ETS is unsupported */
 	hw->nvm.ops.read(hw, NVM_ETS_CFG, 1, &ets_offset);
 	if ((ets_offset == 0x0000) || (ets_offset == 0xFFFF))
-		return status;
+		return E1000_SUCCESS;
 
 	hw->nvm.ops.read(hw, ets_offset, 1, &ets_cfg);
 	if (((ets_cfg & NVM_ETS_TYPE_MASK) >> NVM_ETS_TYPE_SHIFT)
@@ -2755,7 +2750,7 @@ static s32 igb_get_thermal_sensor_data_generic(struct e1000_hw *hw)
 					E1000_I2C_THERMAL_SENSOR_ADDR,
 					&data->sensor[i].temp);
 	}
-	return status;
+	return E1000_SUCCESS;
 }
 
 /**
@@ -2767,7 +2762,6 @@ static s32 igb_get_thermal_sensor_data_generic(struct e1000_hw *hw)
  **/
 static s32 igb_init_thermal_sensor_thresh_generic(struct e1000_hw *hw)
 {
-	s32 status = E1000_SUCCESS;
 	u16 ets_offset;
 	u16 ets_cfg;
 	u16 ets_sensor;
@@ -2793,7 +2787,7 @@ static s32 igb_init_thermal_sensor_thresh_generic(struct e1000_hw *hw)
 	/* Return the internal sensor only if ETS is unsupported */
 	hw->nvm.ops.read(hw, NVM_ETS_CFG, 1, &ets_offset);
 	if ((ets_offset == 0x0000) || (ets_offset == 0xFFFF))
-		return status;
+		return E1000_SUCCESS;
 
 	hw->nvm.ops.read(hw, ets_offset, 1, &ets_cfg);
 	if (((ets_cfg & NVM_ETS_TYPE_MASK) >> NVM_ETS_TYPE_SHIFT)
@@ -2824,7 +2818,7 @@ static s32 igb_init_thermal_sensor_thresh_generic(struct e1000_hw *hw)
 							low_thresh_delta;
 		}
 	}
-	return status;
+	return E1000_SUCCESS;
 }
 
 #endif


------------------------------------------------------------------------------
Time is money. Stop wasting it! Get your web API in 5 minutes.
www.restlet.com/download
http://p.sf.net/sfu/restlet
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
