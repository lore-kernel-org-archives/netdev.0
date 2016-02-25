From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 04/15] e1000e: Clear ULP configuration register on ULP exit
Date: Wed, 24 Feb 2016 18:14:51 -0800
Message-ID: <1456366502-132841-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1456366502-132841-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Raanan Avargil <raanan.avargil@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:47083 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759139AbcBYC0I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 21:26:08 -0500
In-Reply-To: <1456366502-132841-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raanan Avargil <raanan.avargil@intel.com>

There have been bugs caused by HW ULP configuration settings not being
properly cleared after cable connect in V-Pro capable systems.
This caused HW to get out of sync occasionally.
The fix ensures that ULP settings are cleared in HW after
LAN cable re-connect.

Signed-off-by: Raanan Avargil <raanan.avargil@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 2 ++
 drivers/net/ethernet/intel/e1000e/ich8lan.h | 4 ++++
 2 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index e7ccf5f..c0f4887 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1328,6 +1328,8 @@ static s32 e1000_disable_ulp_lpt_lp(struct e1000_hw *hw, bool force)
 		     I218_ULP_CONFIG1_RESET_TO_SMBUS |
 		     I218_ULP_CONFIG1_WOL_HOST |
 		     I218_ULP_CONFIG1_INBAND_EXIT |
+		     I218_ULP_CONFIG1_EN_ULP_LANPHYPC |
+		     I218_ULP_CONFIG1_DIS_CLR_STICKY_ON_PERST |
 		     I218_ULP_CONFIG1_DISABLE_SMB_PERST);
 	e1000_write_phy_reg_hv_locked(hw, I218_ULP_CONFIG1, phy_reg);
 
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.h b/drivers/net/ethernet/intel/e1000e/ich8lan.h
index 7d85f00..2311f60 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.h
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.h
@@ -188,6 +188,10 @@
 #define I218_ULP_CONFIG1_INBAND_EXIT	0x0020	/* Inband on ULP exit */
 #define I218_ULP_CONFIG1_WOL_HOST	0x0040	/* WoL Host on ULP exit */
 #define I218_ULP_CONFIG1_RESET_TO_SMBUS	0x0100	/* Reset to SMBus mode */
+/* enable ULP even if when phy powered down via lanphypc */
+#define I218_ULP_CONFIG1_EN_ULP_LANPHYPC	0x0400
+/* disable clear of sticky ULP on PERST */
+#define I218_ULP_CONFIG1_DIS_CLR_STICKY_ON_PERST	0x0800
 #define I218_ULP_CONFIG1_DISABLE_SMB_PERST	0x1000	/* Disable on PERST# */
 
 /* SMBus Address Phy Register */
-- 
2.5.0
