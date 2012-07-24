From: Cong Wang <amwang@redhat.com>
Subject: [Patch] genetlink: define lockdep_genl_is_held() when CONFIG_LOCKDEP
Date: Tue, 24 Jul 2012 13:44:01 +0800
Message-ID: <1343108641-8439-1-git-send-email-amwang@redhat.com>
Cc: WANG Cong <xiyou.wangcong@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1681 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751942Ab2GXFoL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2012 01:44:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: WANG Cong <xiyou.wangcong@gmail.com>

lockdep_is_held() is defined when CONFIG_LOCKDEP, not CONFIG_PROVE_LOCKING.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jesse Gross <jesse@nicira.com>
Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>

---
diff --git a/include/linux/genetlink.h b/include/linux/genetlink.h
index 7a11401..5ab61c1 100644
--- a/include/linux/genetlink.h
+++ b/include/linux/genetlink.h
@@ -85,7 +85,7 @@ enum {
 /* All generic netlink requests are serialized by a global lock.  */
 extern void genl_lock(void);
 extern void genl_unlock(void);
-#ifdef CONFIG_PROVE_LOCKING
+#ifdef CONFIG_LOCKDEP
 extern int lockdep_genl_is_held(void);
 #endif
 
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 62ebe3c..fda4974 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -33,7 +33,7 @@ void genl_unlock(void)
 }
 EXPORT_SYMBOL(genl_unlock);
 
-#ifdef CONFIG_PROVE_LOCKING
+#ifdef CONFIG_LOCKDEP
 int lockdep_genl_is_held(void)
 {
 	return lockdep_is_held(&genl_mutex);
