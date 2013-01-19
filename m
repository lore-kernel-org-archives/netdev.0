From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] rtlwifi: Fix build warning introduced by commit a290593
Date: Sat, 19 Jan 2013 12:36:49 -0600
Message-ID: <1358620609-9794-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, kbuild test robot <fengguang.wu@intel.com>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:44320 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138Ab3ASShH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2013 13:37:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kbuild test robot reports the following warning with x86_64-randconfig-x955:

warning: (RTL8192CE && RTL8192SE && RTL8192DE && RTL8723AE && RTL8192CU) selects
 RTLWIFI which has unmet direct dependencies (NETDEVICES && WLAN &&
 (RTL8192CE || RTL8192CU || RTL8192SE || RTL8192DE))

This warning was introduced in commit a290593, "rtlwifi: Modify files for addition
of rtl8723ae", and is d ue to a missing dependence of RTLWIFI on RTL8723AE.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: kbuild test robot <fengguang.wu@intel.com>
Reported-by: kbuild test robot <fengguang.wu@intel.com>
---
 drivers/net/wireless/rtlwifi/Kconfig |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/Kconfig b/drivers/net/wireless/rtlwifi/Kconfig
index 21b1bbb..b80bc46 100644
--- a/drivers/net/wireless/rtlwifi/Kconfig
+++ b/drivers/net/wireless/rtlwifi/Kconfig
@@ -57,12 +57,12 @@ config RTL8192CU
 
 config RTLWIFI
 	tristate
-	depends on RTL8192CE || RTL8192CU || RTL8192SE || RTL8192DE
+	depends on RTL8192CE || RTL8192CU || RTL8192SE || RTL8192DE || RTL8723AE
 	default m
 
 config RTLWIFI_DEBUG
 	bool "Additional debugging output"
-	depends on RTL8192CE || RTL8192CU || RTL8192SE || RTL8192DE
+	depends on RTL8192CE || RTL8192CU || RTL8192SE || RTL8192DE || RTL8723AE
 	default y
 
 config RTL8192C_COMMON
-- 
1.7.10.4
