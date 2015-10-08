From: Yaowei Bai <bywxiaobai@163.com>
Subject: [PATCH 1/9] net/netlink: lockdep_genl_is_held can be boolean
Date: Thu,  8 Oct 2015 21:28:54 +0800
Message-ID: <1444310942-4428-2-git-send-email-bywxiaobai@163.com>
References: <1444310942-4428-1-git-send-email-bywxiaobai@163.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, tgraf@suug.ch, herbert@gondor.apana.org.au,
	johannes.berg@intel.com, daniel@iogearbox.net,
	gerrit@erg.abdn.ac.uk, socketcan@hartkopp.net, mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-14.163.com ([220.181.12.14]:37582 "EHLO m12-14.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757341AbbJHNdV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 09:33:21 -0400
In-Reply-To: <1444310942-4428-1-git-send-email-bywxiaobai@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes lockdep_genl_is_held return bool to improve
readability due to this particular function only using either
one or zero as its return value.

No functional change.

Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
---
 include/linux/genetlink.h | 2 +-
 net/netlink/genetlink.c   | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/genetlink.h b/include/linux/genetlink.h
index 09460d6..a4c61cb 100644
--- a/include/linux/genetlink.h
+++ b/include/linux/genetlink.h
@@ -8,7 +8,7 @@
 extern void genl_lock(void);
 extern void genl_unlock(void);
 #ifdef CONFIG_LOCKDEP
-extern int lockdep_genl_is_held(void);
+extern bool lockdep_genl_is_held(void);
 #endif
 
 /* for synchronisation between af_netlink and genetlink */
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 2ed5f96..d5d713d 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -39,7 +39,7 @@ void genl_unlock(void)
 EXPORT_SYMBOL(genl_unlock);
 
 #ifdef CONFIG_LOCKDEP
-int lockdep_genl_is_held(void)
+bool lockdep_genl_is_held(void)
 {
 	return lockdep_is_held(&genl_mutex);
 }
-- 
1.9.1
