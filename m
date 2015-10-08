From: Yaowei Bai <bywxiaobai@163.com>
Subject: [PATCH 9/9] net/core: lockdep_rtnl_is_held can be boolean
Date: Thu,  8 Oct 2015 21:29:02 +0800
Message-ID: <1444310942-4428-10-git-send-email-bywxiaobai@163.com>
References: <1444310942-4428-1-git-send-email-bywxiaobai@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, tgraf@suug.ch, herbert@gondor.apana.org.au,
	johannes.berg@intel.com, daniel@iogearbox.net,
	gerrit@erg.abdn.ac.uk, socketcan@hartkopp.net, mkl@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444310942-4428-1-git-send-email-bywxiaobai@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes lockdep_rtnl_is_held return bool due to this
particular function only using either one or zero as its return
value.

In another patch lockdep_is_held is also made return bool.

No functional change.

Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
---
 include/linux/rtnetlink.h | 6 +++---
 net/core/rtnetlink.c      | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 39adaa9..4be5048 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -33,11 +33,11 @@ extern wait_queue_head_t netdev_unregistering_wq;
 extern struct mutex net_mutex;
 
 #ifdef CONFIG_PROVE_LOCKING
-extern int lockdep_rtnl_is_held(void);
+extern bool lockdep_rtnl_is_held(void);
 #else
-static inline int lockdep_rtnl_is_held(void)
+static inline bool lockdep_rtnl_is_held(void)
 {
-	return 1;
+	return true;
 }
 #endif /* #ifdef CONFIG_PROVE_LOCKING */
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 0ec4840..435da82 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -96,7 +96,7 @@ int rtnl_is_locked(void)
 EXPORT_SYMBOL(rtnl_is_locked);
 
 #ifdef CONFIG_PROVE_LOCKING
-int lockdep_rtnl_is_held(void)
+bool lockdep_rtnl_is_held(void)
 {
 	return lockdep_is_held(&rtnl_mutex);
 }
-- 
1.9.1
