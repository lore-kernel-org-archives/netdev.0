From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v3 1/8] cgroup: net_cls: Move sock_update_classid() declaration to cls_cgroup.h
Date: Tue, 11 Sep 2012 18:26:07 +0200
Message-ID: <1347380774-9546-2-git-send-email-wagi@monom.org>
References: <1347380774-9546-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Li Zefan <lizefan@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>, Tejun Heo <tj@kernel.org>
To: netdev@vger.kernel.org, cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:60251 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756550Ab2IKQ0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 12:26:19 -0400
In-Reply-To: <1347380774-9546-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

The only user of sock_update_classid() is net/socket.c which happens
to include cls_cgroup.h directly.

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: netdev@vger.kernel.org
Cc: cgroups@vger.kernel.org
---
 include/net/cls_cgroup.h | 6 ++++++
 include/net/sock.h       | 8 --------
 2 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index a4dc5b0..e88527a 100644
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
@@ -62,6 +64,10 @@ static inline u32 task_cls_classid(struct task_struct *p)
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
diff --git a/include/net/sock.h b/include/net/sock.h
index 84bdaec..868ca7d 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1495,14 +1495,6 @@ extern void *sock_kmalloc(struct sock *sk, int size,
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
1.7.12.315.g682ce8b
