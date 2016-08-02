From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0803/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:48:03 +0800
Message-ID: <20160802114803.3500-1-baolex.ni@intel.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com
To: pizza@shaftnet.org, kvalo@codeaurora.org, linuxwifi@intel.com,
	m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20357 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933972AbcHBM0j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:26:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/net/wireless/st/cw1200/main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/st/cw1200/main.c b/drivers/net/wireless/st/cw1200/main.c
index dc478ce..c664c21 100644
--- a/drivers/net/wireless/st/cw1200/main.c
+++ b/drivers/net/wireless/st/cw1200/main.c
@@ -50,14 +50,14 @@ module_param_array_named(macaddr, cw1200_mac_template, byte, NULL, S_IRUGO);
 MODULE_PARM_DESC(macaddr, "Override platform_data MAC address");
 
 static char *cw1200_sdd_path;
-module_param(cw1200_sdd_path, charp, 0644);
+module_param(cw1200_sdd_path, charp, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(cw1200_sdd_path, "Override platform_data SDD file");
 static int cw1200_refclk;
-module_param(cw1200_refclk, int, 0644);
+module_param(cw1200_refclk, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(cw1200_refclk, "Override platform_data reference clock");
 
 int cw1200_power_mode = wsm_power_mode_quiescent;
-module_param(cw1200_power_mode, int, 0644);
+module_param(cw1200_power_mode, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(cw1200_power_mode, "WSM power mode.  0 == active, 1 == doze, 2 == quiescent (default)");
 
 #define RATETAB_ENT(_rate, _rateid, _flags)		\
@@ -239,8 +239,8 @@ static const struct ieee80211_ops cw1200_ops = {
 
 static int cw1200_ba_rx_tids = -1;
 static int cw1200_ba_tx_tids = -1;
-module_param(cw1200_ba_rx_tids, int, 0644);
-module_param(cw1200_ba_tx_tids, int, 0644);
+module_param(cw1200_ba_rx_tids, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
+module_param(cw1200_ba_tx_tids, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(cw1200_ba_rx_tids, "Block ACK RX TIDs");
 MODULE_PARM_DESC(cw1200_ba_tx_tids, "Block ACK TX TIDs");
 
-- 
2.9.2
