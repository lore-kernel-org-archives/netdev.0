From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] ath: Make ath_dbg void not int
Date: Fri, 26 Aug 2011 01:56:38 -0700
Message-ID: <3f6f6f785962c600b12bc6362d0932f13a5cbff9.1314347556.git.joe@perches.com>
References: <cover.1314347556.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wondertoys-mx.wondertoys.net ([206.117.179.246]:59546 "EHLO
	labridge.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750941Ab1HZI4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 04:56:54 -0400
In-Reply-To: <cover.1314347556.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The return value is never used so make it void.

Reduces object size a tiny bit.

$ size drivers/net/wireless/ath/built-in.o*
   text	   data	    bss	    dec	    hex	filename
1164175	  16235	 212032	1392442	 153f3a	drivers/net/wireless/ath/built-in.o.new
1164819	  16235	 212032	1393086	 1541be	drivers/net/wireless/ath/built-in.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/ath.h |   29 ++++++++++++-----------------
 1 files changed, 12 insertions(+), 17 deletions(-)

diff --git a/drivers/net/wireless/ath/ath.h b/drivers/net/wireless/ath/ath.h
index 17c4b56..a3f8505 100644
--- a/drivers/net/wireless/ath/ath.h
+++ b/drivers/net/wireless/ath/ath.h
@@ -178,8 +178,9 @@ bool ath_hw_keyreset(struct ath_common *common, u16 entry);
 void ath_hw_cycle_counters_update(struct ath_common *common);
 int32_t ath_hw_get_listen_time(struct ath_common *common);
 
-extern __attribute__ ((format (printf, 3, 4))) int
-ath_printk(const char *level, struct ath_common *common, const char *fmt, ...);
+extern __attribute__((format (printf, 3, 4)))
+int ath_printk(const char *level, struct ath_common *common,
+	       const char *fmt, ...);
 
 #define ath_emerg(common, fmt, ...)				\
 	ath_printk(KERN_EMERG, common, fmt, ##__VA_ARGS__)
@@ -246,27 +247,21 @@ enum ATH_DEBUG {
 
 #ifdef CONFIG_ATH_DEBUG
 
-#define ath_dbg(common, dbg_mask, fmt, ...)			\
-({								\
-	int rtn;						\
-	if ((common)->debug_mask & dbg_mask)			\
-		rtn = ath_printk(KERN_DEBUG, common, fmt,	\
-				 ##__VA_ARGS__);		\
-	else							\
-		rtn = 0;					\
-								\
-	rtn;							\
-})
+#define ath_dbg(common, dbg_mask, fmt, ...)				\
+do {									\
+	if ((common)->debug_mask & dbg_mask)				\
+		ath_printk(KERN_DEBUG, common, fmt, ##__VA_ARGS__);	\
+} while (0)
+
 #define ATH_DBG_WARN(foo, arg...) WARN(foo, arg)
 #define ATH_DBG_WARN_ON_ONCE(foo) WARN_ON_ONCE(foo)
 
 #else
 
-static inline  __attribute__ ((format (printf, 3, 4))) int
-ath_dbg(struct ath_common *common, enum ATH_DEBUG dbg_mask,
-	const char *fmt, ...)
+static inline  __attribute__((format (printf, 3, 4)))
+void ath_dbg(struct ath_common *common, enum ATH_DEBUG dbg_mask,
+	     const char *fmt, ...)
 {
-	return 0;
 }
 #define ATH_DBG_WARN(foo, arg...) do {} while (0)
 #define ATH_DBG_WARN_ON_ONCE(foo) ({				\
-- 
1.7.6.405.gc1be0
