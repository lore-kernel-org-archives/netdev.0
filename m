From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 10/19] i40e: Add FEC for 25g
Date: Wed,  7 Dec 2016 14:19:09 -0800
Message-ID: <20161207221918.57932-11-jeffrey.t.kirsher@intel.com>
References: <20161207221918.57932-1-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Mitch Williams <mitch.a.williams@intel.com>,
        Jacek Naczyk <jacek.naczyk@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:28873 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933438AbcLGWUS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 17:20:18 -0500
In-Reply-To: <20161207221918.57932-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch adds adminq support for Forward Error
Correction ("FEC")for 25g products.

Change-ID: Iaff4910737c239d2c730e5c22a313ce9c37d3964
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jacek Naczyk <jacek.naczyk@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  | 25 ++++++++++++++++++++--
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  2 ++
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    | 25 ++++++++++++++++++++--
 3 files changed, 48 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
index c9d1f91..b2101a5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
@@ -1686,6 +1686,8 @@ struct i40e_aq_get_phy_abilities_resp {
 #define I40E_AQ_PHY_LINK_ENABLED	0x08
 #define I40E_AQ_PHY_AN_ENABLED		0x10
 #define I40E_AQ_PHY_FLAG_MODULE_QUAL	0x20
+#define I40E_AQ_PHY_FEC_ABILITY_KR	0x40
+#define I40E_AQ_PHY_FEC_ABILITY_RS	0x80
 	__le16	eee_capability;
 #define I40E_AQ_EEE_100BASE_TX		0x0002
 #define I40E_AQ_EEE_1000BASE_T		0x0004
@@ -1701,7 +1703,16 @@ struct i40e_aq_get_phy_abilities_resp {
 #define I40E_AQ_PHY_TYPE_EXT_25G_CR	0X02
 #define I40E_AQ_PHY_TYPE_EXT_25G_SR	0x04
 #define I40E_AQ_PHY_TYPE_EXT_25G_LR	0x08
-	u8	mod_type_ext;
+	u8	fec_cfg_curr_mod_ext_info;
+#define I40E_AQ_ENABLE_FEC_KR		0x01
+#define I40E_AQ_ENABLE_FEC_RS		0x02
+#define I40E_AQ_REQUEST_FEC_KR		0x04
+#define I40E_AQ_REQUEST_FEC_RS		0x08
+#define I40E_AQ_ENABLE_FEC_AUTO		0x10
+#define I40E_AQ_FEC
+#define I40E_AQ_MODULE_TYPE_EXT_MASK	0xE0
+#define I40E_AQ_MODULE_TYPE_EXT_SHIFT	5
+
 	u8	ext_comp_code;
 	u8	phy_id[4];
 	u8	module_type[3];
@@ -1729,7 +1740,15 @@ struct i40e_aq_set_phy_config { /* same bits as above in all */
 #define I40E_AQ_PHY_TYPE_EXT_25G_CR	0X02
 #define I40E_AQ_PHY_TYPE_EXT_25G_SR	0x04
 #define I40E_AQ_PHY_TYPE_EXT_25G_LR	0x08
-	u8	reserved[2];
+	u8	fec_config;
+#define I40E_AQ_SET_FEC_ABILITY_KR	BIT(0)
+#define I40E_AQ_SET_FEC_ABILITY_RS	BIT(1)
+#define I40E_AQ_SET_FEC_REQUEST_KR	BIT(2)
+#define I40E_AQ_SET_FEC_REQUEST_RS	BIT(3)
+#define I40E_AQ_SET_FEC_AUTO		BIT(4)
+#define I40E_AQ_PHY_FEC_CONFIG_SHIFT	0x0
+#define I40E_AQ_PHY_FEC_CONFIG_MASK	(0x1F << I40E_AQ_PHY_FEC_CONFIG_SHIFT)
+	u8	reserved;
 };
 
 I40E_CHECK_CMD_LENGTH(i40e_aq_set_phy_config);
@@ -1819,6 +1838,8 @@ struct i40e_aqc_get_link_status {
 	u8	loopback; /* use defines from i40e_aqc_set_lb_mode */
 	__le16	max_frame_size;
 	u8	config;
+#define I40E_AQ_CONFIG_FEC_KR_ENA	0x01
+#define I40E_AQ_CONFIG_FEC_RS_ENA	0x02
 #define I40E_AQ_CONFIG_CRC_ENA		0x04
 #define I40E_AQ_CONFIG_PACING_MASK	0x78
 	u8	external_power_ability;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 1318c7d..f8c4c14 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1714,6 +1714,8 @@ enum i40e_status_code i40e_set_fc(struct i40e_hw *hw, u8 *aq_failures,
 		config.eee_capability = abilities.eee_capability;
 		config.eeer = abilities.eeer_val;
 		config.low_power_ctrl = abilities.d3_lpan;
+		config.fec_config = abilities.fec_cfg_curr_mod_ext_info &
+				    I40E_AQ_PHY_FEC_CONFIG_MASK;
 		status = i40e_aq_set_phy_config(hw, &config, NULL);
 
 		if (status)
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
index f8d7d95..eeb9864 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq_cmd.h
@@ -1683,6 +1683,8 @@ struct i40e_aq_get_phy_abilities_resp {
 #define I40E_AQ_PHY_LINK_ENABLED	0x08
 #define I40E_AQ_PHY_AN_ENABLED		0x10
 #define I40E_AQ_PHY_FLAG_MODULE_QUAL	0x20
+#define I40E_AQ_PHY_FEC_ABILITY_KR	0x40
+#define I40E_AQ_PHY_FEC_ABILITY_RS	0x80
 	__le16	eee_capability;
 #define I40E_AQ_EEE_100BASE_TX		0x0002
 #define I40E_AQ_EEE_1000BASE_T		0x0004
@@ -1698,7 +1700,16 @@ struct i40e_aq_get_phy_abilities_resp {
 #define I40E_AQ_PHY_TYPE_EXT_25G_CR	0X02
 #define I40E_AQ_PHY_TYPE_EXT_25G_SR	0x04
 #define I40E_AQ_PHY_TYPE_EXT_25G_LR	0x08
-	u8	mod_type_ext;
+	u8	fec_cfg_curr_mod_ext_info;
+#define I40E_AQ_ENABLE_FEC_KR		0x01
+#define I40E_AQ_ENABLE_FEC_RS		0x02
+#define I40E_AQ_REQUEST_FEC_KR		0x04
+#define I40E_AQ_REQUEST_FEC_RS		0x08
+#define I40E_AQ_ENABLE_FEC_AUTO		0x10
+#define I40E_AQ_FEC
+#define I40E_AQ_MODULE_TYPE_EXT_MASK	0xE0
+#define I40E_AQ_MODULE_TYPE_EXT_SHIFT	5
+
 	u8	ext_comp_code;
 	u8	phy_id[4];
 	u8	module_type[3];
@@ -1726,7 +1737,15 @@ struct i40e_aq_set_phy_config { /* same bits as above in all */
 #define I40E_AQ_PHY_TYPE_EXT_25G_CR	0X02
 #define I40E_AQ_PHY_TYPE_EXT_25G_SR	0x04
 #define I40E_AQ_PHY_TYPE_EXT_25G_LR	0x08
-	u8	reserved[2];
+	u8	fec_config;
+#define I40E_AQ_SET_FEC_ABILITY_KR	BIT(0)
+#define I40E_AQ_SET_FEC_ABILITY_RS	BIT(1)
+#define I40E_AQ_SET_FEC_REQUEST_KR	BIT(2)
+#define I40E_AQ_SET_FEC_REQUEST_RS	BIT(3)
+#define I40E_AQ_SET_FEC_AUTO		BIT(4)
+#define I40E_AQ_PHY_FEC_CONFIG_SHIFT	0x0
+#define I40E_AQ_PHY_FEC_CONFIG_MASK	(0x1F << I40E_AQ_PHY_FEC_CONFIG_SHIFT)
+	u8	reserved;
 };
 
 I40E_CHECK_CMD_LENGTH(i40e_aq_set_phy_config);
@@ -1816,6 +1835,8 @@ struct i40e_aqc_get_link_status {
 	u8	loopback; /* use defines from i40e_aqc_set_lb_mode */
 	__le16	max_frame_size;
 	u8	config;
+#define I40E_AQ_CONFIG_FEC_KR_ENA	0x01
+#define I40E_AQ_CONFIG_FEC_RS_ENA	0x02
 #define I40E_AQ_CONFIG_CRC_ENA		0x04
 #define I40E_AQ_CONFIG_PACING_MASK	0x78
 	u8	external_power_ability;
-- 
2.9.3
