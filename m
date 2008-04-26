From: Jason Riedy <jason@acm.org>
Subject: [PATCH] Allow building iwl3945 without iwl4965.
Date: Sat, 26 Apr 2008 15:27:43 -0700
Message-ID: <87zlrgl09s.fsf@sparse.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Zhu Yi <yi.zhu@intel.com>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from b.mail.sonic.net ([64.142.19.5]:34138 "EHLO b.mail.sonic.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755466AbYDZW1u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Apr 2008 18:27:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If IWL3945 ever depends on IWLCORE, the silent, user-invisible
IWLWIFI option can go away.

Signed-off-by: Jason Riedy <jason@acm.org>
---
   The breakage made it to Linus's tree but isn't in the wireless forest
   (as far as I can see).  Commit 49186b4a083655 is a "part 2" without
   a "part 1", so perhaps that "part 1" avoided the problem?

 drivers/net/wireless/Makefile        |    2 +-
 drivers/net/wireless/iwlwifi/Kconfig |    6 ++++++
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/Makefile b/drivers/net/wireless/Makefile
index c2642bc..2c343aa 100644
--- a/drivers/net/wireless/Makefile
+++ b/drivers/net/wireless/Makefile
@@ -56,7 +56,7 @@ obj-$(CONFIG_RTL8187)	+= rtl8187.o
 
 obj-$(CONFIG_ADM8211)	+= adm8211.o
 
-obj-$(CONFIG_IWLCORE)	+= iwlwifi/
+obj-$(CONFIG_IWLWIFI)	+= iwlwifi/
 obj-$(CONFIG_RT2X00)	+= rt2x00/
 
 obj-$(CONFIG_P54_COMMON)	+= p54/
diff --git a/drivers/net/wireless/iwlwifi/Kconfig b/drivers/net/wireless/iwlwifi/Kconfig
index c4e631d..9a25f55 100644
--- a/drivers/net/wireless/iwlwifi/Kconfig
+++ b/drivers/net/wireless/iwlwifi/Kconfig
@@ -1,6 +1,11 @@
+config IWLWIFI
+	bool
+	default n
+
 config IWLCORE
 	tristate "Intel Wireless Wifi Core"
 	depends on PCI && MAC80211 && WLAN_80211 && EXPERIMENTAL
+	select IWLWIFI
 
 config IWLWIFI_LEDS
 	bool
@@ -106,6 +111,7 @@ config IWL3945
 	tristate "Intel PRO/Wireless 3945ABG/BG Network Connection"
 	depends on PCI && MAC80211 && WLAN_80211 && EXPERIMENTAL
 	select FW_LOADER
+	select IWLWIFI
 	---help---
 	  Select to build the driver supporting the:
 
-- 
1.5.5.rc1.121.g1594

