From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v3 1/6] cgroup: Move cls function definition to cls_cgroup.h
Date: Tue, 14 Aug 2012 15:02:17 +0200
Message-ID: <1344949343-26090-2-git-send-email-wagi@monom.org>
References: <1344949343-26090-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S. Miller" <davem@davemloft.net>,
	Li Zefan <lizefan@huawei.com>, Tejun Heo <tj@kernel.org>
To: netdev@vger.kernel.org, cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:54811 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753268Ab2HNNC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 09:02:26 -0400
In-Reply-To: <1344949343-26090-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

sock_update_classid() is used by net/socket.c which includes
cls_cgroup.h directly.

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: cgroups@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 include/net/cls_cgroup.h | 7 +++++++
 include/net/sock.h       | 8 --------
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index a4dc5b0..5f49b69 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -24,6 +24,8 @@ struct cgroup_cls_state
 	u32 classid;
 };
 
+extern void sock_update_classid(struct sock *sk);
+
 #ifdef CONFIG_NET_CLS_CGROUP
 static inline u32 task_cls_classid(struct task_struct *p)
 {
@@ -62,9 +64,14 @@ static inline u32 task_cls_classid(struct task_struct *p)
 }
 #endif
 #else
+static inline void sock_update_classid(struct sock *sk)
+{
+}
+
 static inline u32 task_cls_classid(struct task_struct *p)
 {
 	return 0;
 }
 #endif
+
 #endif  /* _NET_CLS_CGROUP_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index 72132ae..160a680 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1486,14 +1486,6 @@ extern void *sock_kmalloc(struct sock *sk, int size,
 extern void sock_kfree_s(struct sock *sk, void *mem, int size);
 extern void sk_send_sigurg(struct sock *sk);
 
-#ifdef CONFIG_CGROUPS
-extern void sock_update_classid(struct sock *sk);
-#else
-static inline void sock_update_classid(struct sock *sk)
-{
-}
-#endif
-
 /*
  * Functions to fill in entries in struct proto_ops when a protocol
  * does not implement a particular function.
-- 
1.7.12.rc1.16.g05a20c8
