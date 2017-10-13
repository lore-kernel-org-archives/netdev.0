From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 2/2] cfg80211: fix CFG80211_EXTRA_REGDB_KEYDIR typo
Date: Fri, 13 Oct 2017 14:04:31 +0200
Message-ID: <20171013120446.4079666-2-arnd@arndb.de>
References: <20171013120446.4079666-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171013120446.4079666-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The missing CONFIG_ prefix means this macro is never defined,
leading to a possible Kbuild warning:

net/wireless/reg.c:666:20: error: 'load_keys_from_buffer' defined but not used [-Werror=unused-function]
 static void __init load_keys_from_buffer(const u8 *p, unsigned int buflen)

When we use the correct symbol, the warning also goes away.

Fixes: 90a53e4432b1 ("cfg80211: implement regdb signature checking")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/wireless/reg.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 58319c82ecb3..3871998059de 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -723,7 +723,7 @@ static int __init load_builtin_regdb_keys(void)
 #ifdef CONFIG_CFG80211_USE_KERNEL_REGDB_KEYS
 	load_keys_from_buffer(shipped_regdb_certs, shipped_regdb_certs_len);
 #endif
-#ifdef CFG80211_EXTRA_REGDB_KEYDIR
+#ifdef CONFIG_CFG80211_EXTRA_REGDB_KEYDIR
 	if (CONFIG_CFG80211_EXTRA_REGDB_KEYDIR[0] != '\0')
 		load_keys_from_buffer(extra_regdb_certs, extra_regdb_certs_len);
 #endif
-- 
2.9.0
