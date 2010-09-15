From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 1/3] net: add rtnl_dereference()
Date: Wed, 15 Sep 2010 23:07:15 +0200
Message-ID: <1284584835.2462.69.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49854 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755209Ab0IOVHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 17:07:21 -0400
Received: by wyf22 with SMTP id 22so681880wyf.19
        for <netdev@vger.kernel.org>; Wed, 15 Sep 2010 14:07:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We sometime want to dereference an rcu protected pointer while
holding RTNL. Use a macro to hide all lockdep details.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/rtnetlink.h |    9 +++++++++
 1 files changed, 9 insertions(+)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 263690d..68c436b 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -760,6 +760,15 @@ extern int lockdep_rtnl_is_held(void);
 	rcu_dereference_check(p, rcu_read_lock_held() ||	\
 				 lockdep_rtnl_is_held())
 
+/**
+ * rtnl_dereference - rcu_dereference with debug checking
+ * @p: The pointer to read, prior to dereferencing
+ *
+ * Do an rcu_dereference(p), but check caller holds RTNL
+ */
+#define rtnl_dereference(p)					\
+	rcu_dereference_check(p, lockdep_rtnl_is_held())
+
 extern void rtnetlink_init(void);
 extern void __rtnl_unlock(void);
 


