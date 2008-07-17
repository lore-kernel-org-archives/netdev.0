From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next 1/2] iwlwifi: compilation error when CONFIG_IWLWIFI_DEBUG is not set
Date: Thu, 17 Jul 2008 13:19:24 +0400
Message-ID: <1216286365-11703-1-git-send-email-den@openvz.org>
Cc: yi.zhu@intel.com, reinette.chatre@intel.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:48514 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754137AbYGQJS1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 05:18:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC [M]  drivers/net/wireless/iwlwifi/iwl-rfkill.o
drivers/net/wireless/iwlwifi/iwl-led.c: In function 'iwl_led_brightness_set':
drivers/net/wireless/iwlwifi/iwl-led.c:198: error: 'led_type_str' undeclared (first use in this function)
drivers/net/wireless/iwlwifi/iwl-led.c:198: error: (Each undeclared identifier is reported only once
drivers/net/wireless/iwlwifi/iwl-led.c:198: error: for each function it appears in.)

The problem is that led_type_str is defined under CONFIG_IWLWIFI_DEBUG
while IWL_DEBUG is a static inline function in this case. Replace it
with macro.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 drivers/net/wireless/iwlwifi/iwl-debug.h |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-debug.h b/drivers/net/wireless/iwlwifi/iwl-debug.h
index 5838480..d6d729e 100644
--- a/drivers/net/wireless/iwlwifi/iwl-debug.h
+++ b/drivers/net/wireless/iwlwifi/iwl-debug.h
@@ -68,12 +68,8 @@ void iwl_dbgfs_unregister(struct iwl_priv *priv);
 #endif
 
 #else
-static inline void IWL_DEBUG(int level, const char *fmt, ...)
-{
-}
-static inline void IWL_DEBUG_LIMIT(int level, const char *fmt, ...)
-{
-}
+#define IWL_DEBUG(level, fmt, args...)
+#define IWL_DEBUG_LIMIT(level, fmt, args...)
 #endif				/* CONFIG_IWLWIFI_DEBUG */
 
 
-- 
1.5.4.5

