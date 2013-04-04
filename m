From: Wang YanQing <udknight@gmail.com>
Subject: [PATCH] lib80211: make lib80211 can be enabled independently
Date: Fri, 5 Apr 2013 00:01:30 +0800
Message-ID: <20130404160130.GA2577@udknight>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Current we can only enable lib80211 by enable a driver
in tree use it which will select it, but some out tree's
drivers also use it, so I think it has sense to make lib80211
can be enabled independently.

A example of the out tree's drivers use lib80211 is:
hybird driver(wl) for Broadcom Corporation BCM43225 802.11b/g/n

Signed-off-by: Wang YanQing <udknight@gmail.com>
---
 net/wireless/Kconfig | 22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/net/wireless/Kconfig b/net/wireless/Kconfig
index 16d08b3..6e83f0a 100644
--- a/net/wireless/Kconfig
+++ b/net/wireless/Kconfig
@@ -140,22 +140,34 @@ config CFG80211_WEXT
 	  extensions with cfg80211-based drivers.
 
 config LIB80211
-	tristate
+	tristate "common routines used by IEEE802.11 wireless LAN drivers"
 	default n
 	help
 	  This options enables a library of common routines used
 	  by IEEE802.11 wireless LAN drivers.
 
-	  Drivers should select this themselves if needed.
+	  Drivers could select this themselves if needed.
 
 config LIB80211_CRYPT_WEP
-	tristate
+	tristate "host-based WEP encryption implementation for lib80211"
+	depends on LIB80211
+	default n
+	---help---
+	   host-based WEP encryption implementation for lib80211
 
 config LIB80211_CRYPT_CCMP
-	tristate
+	tristate "host-based CCMP encryption implementation for lib80211"
+	depends on LIB80211
+	default n
+	---help---
+	   host-based CCMP encryption implementation for lib80211
 
 config LIB80211_CRYPT_TKIP
-	tristate
+	tristate "host-based TKIP encryption implementation for lib80211"
+	depends on LIB80211
+	default n
+	---help---
+	    host-based TKIP encryption implementation for lib80211
 
 config LIB80211_DEBUG
 	bool "lib80211 debugging messages"
-- 
1.7.12.4.dirty
