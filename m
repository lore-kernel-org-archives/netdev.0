From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net/wireless: CFG80211_WEXT_EXPORT requires wireless extensions
Date: Sat, 11 Apr 2015 00:29:14 +0200
Message-ID: <2303996.H1mYPouv05@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CFG80211_WEXT_EXPORT symbol is selected by two drivers that
make direct use of compat handlers for the wireless ioctls.
However, this has no effect when the wireless extensions themselves
are disabled, and results in a link error:

ERROR: "cfg80211_wext_giwrts" [drivers/net/wireless/orinoco/orinoco.ko] undefined!
ERROR: "cfg80211_wext_siwfrag" [drivers/net/wireless/orinoco/orinoco.ko] undefined!
ERROR: "cfg80211_wext_giwname" [drivers/net/wireless/ipw2x00/ipw2200.ko] undefined!

This changes the Kconfig logic so that CFG80211_WEXT can not
be disabled when CFG80211_WEXT_EXPORT is set.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 2afe38d15cee01 ("cfg80211-wext: export symbols only when needed")

diff --git a/net/wireless/Kconfig b/net/wireless/Kconfig
index b13dfb4ff001..cb5eef396d5c 100644
--- a/net/wireless/Kconfig
+++ b/net/wireless/Kconfig
@@ -178,7 +178,6 @@ config CFG80211_WEXT
 	bool "cfg80211 wireless extensions compatibility"
 	depends on CFG80211
 	select WEXT_CORE
-	default y if CFG80211_WEXT_EXPORT
 	help
 	  Enable this option if you need old userspace for wireless
 	  extensions with cfg80211-based drivers.
@@ -186,6 +185,7 @@ config CFG80211_WEXT
 config CFG80211_WEXT_EXPORT
 	bool
 	depends on CFG80211
+	select CFG80211_WEXT
 	help
 	  Drivers should select this option if they require cfg80211's
 	  wext compatibility symbols to be exported.
