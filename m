From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] kcm: mark helper functions inline
Date: Thu, 10 Mar 2016 19:31:12 +0100
Message-ID: <1457634674-3373509-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.73]:52154 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753947AbcCJSbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 13:31:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The stub helper functions for the newly added kcm_proc_init/exit interfaces
are defined as 'static' in a header file, which leads to build warnings for
each file that includes them without calling them:

include/net/kcm.h:183:12: error: 'kcm_proc_init' defined but not used [-Werror=unused-function]
include/net/kcm.h:184:13: error: 'kcm_proc_exit' defined but not used [-Werror=unused-function]

This marks the two functions as 'static inline' instead, which avoids the
warnings and is obviously what was meant here.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: cd6e111bf5be ("kcm: Add statistics and proc interfaces")
---
 include/net/kcm.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/kcm.h b/include/net/kcm.h
index 95c425ca97b6..2840b5825dcc 100644
--- a/include/net/kcm.h
+++ b/include/net/kcm.h
@@ -180,8 +180,8 @@ struct kcm_mux {
 int kcm_proc_init(void);
 void kcm_proc_exit(void);
 #else
-static int kcm_proc_init(void) { return 0; }
-static void kcm_proc_exit(void) { }
+static inline int kcm_proc_init(void) { return 0; }
+static inline void kcm_proc_exit(void) { }
 #endif
 
 static inline void aggregate_psock_stats(struct kcm_psock_stats *stats,
-- 
2.7.0
