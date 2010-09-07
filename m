From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: introduce
 rcu_dereference_read_lock_or_rtnl
Date: Tue, 07 Sep 2010 22:11:31 +0200
Message-ID: <1283890291.2634.143.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:48313 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758232Ab0IGULg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 16:11:36 -0400
Received: by fxm16 with SMTP id 16so275383fxm.19
        for <netdev@vger.kernel.org>; Tue, 07 Sep 2010 13:11:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We use rcu_dereference_check(p, rcu_read_lock_held() ||
lockdep_rtnl_is_held()) several times in network stack.

More usages to come too, so its time to create a helper.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
include/linux/rtnetlink.h |   12 ++++++++++++

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 58d4449..5ba48bb 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -745,10 +745,22 @@ extern void rtnl_lock(void);
 extern void rtnl_unlock(void);
 extern int rtnl_trylock(void);
 extern int rtnl_is_locked(void);
+
 #ifdef CONFIG_PROVE_LOCKING
 extern int lockdep_rtnl_is_held(void);
 #endif /* #ifdef CONFIG_PROVE_LOCKING */
 
+/**
+ * rcu_dereference_read_lock_or_rtnl - rcu_dereference with debug checking
+ * @p: The pointer to read, prior to dereferencing
+ *
+ * Do an rcu_dereference(p), but check caller either holds rcu_read_lock()
+ * or RTNL
+ */
+#define rcu_dereference_read_lock_or_rtnl(p)				\
+		rcu_dereference_check(p, rcu_read_lock_held() ||	\
+					 lockdep_rtnl_is_held());
+
 extern void rtnetlink_init(void);
 extern void __rtnl_unlock(void);
 


