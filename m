From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] batman-adv: clarify CFG80211 dependency
Date: Wed,  2 Mar 2016 14:54:35 +0100
Message-ID: <1456926882-2941809-1-git-send-email-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	"David S. Miller" <davem@davemloft.net>,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Antonio Quartulli <a@unstable.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver calls cfg80211_get_station, which may be part of a
module, so we must not enable BATMAN_ADV_BATMAN_V if
BATMAN_ADV=y and CFG80211=m:

net/built-in.o: In function `batadv_v_elp_get_throughput':
(text+0x5c62c): undefined reference to `cfg80211_get_station'

This clarifies the dependency to cover all combinations.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: c833484e5f38 ("batman-adv: ELP - compute the metric based on the estimated throughput")
---
 net/batman-adv/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/Kconfig b/net/batman-adv/Kconfig
index e651dc927bfd..f66930ee3c0b 100644
--- a/net/batman-adv/Kconfig
+++ b/net/batman-adv/Kconfig
@@ -17,7 +17,7 @@ config BATMAN_ADV
 
 config BATMAN_ADV_BATMAN_V
 	bool "B.A.T.M.A.N. V protocol (experimental)"
-	depends on BATMAN_ADV && CFG80211
+	depends on BATMAN_ADV && CFG80211=y || (CFG80211=m && BATMAN_ADV=m)
 	default n
 	help
 	  This option enables the B.A.T.M.A.N. V protocol, the successor
-- 
2.7.0
