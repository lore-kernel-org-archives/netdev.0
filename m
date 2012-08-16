From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v0 2/5] cgroup: Move sock_update_classid() decleration to cls_cgroup.h
Date: Thu, 16 Aug 2012 16:12:13 +0200
Message-ID: <1345126336-20755-3-git-send-email-wagi@monom.org>
References: <1345126336-20755-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Li Zefan <lizefan@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>, Tejun Heo <tj@kernel.org>
To: netdev@vger.kernel.org, cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:32919 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752862Ab2HPOMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 10:12:20 -0400
In-Reply-To: <1345126336-20755-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

The only user of sock_update_classid() is net/socket.c which
happens to include cls_cgroup.h direclty.

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
 include/net/cls_cgroup.h | 8 ++++++++
 include/net/sock.h       | 8 --------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index e2fe2b9..401672c 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -24,6 +24,8 @@ struct cgroup_cls_state
 	u32 classid;
 };
 
+extern void sock_update_classid(struct sock *sk);
+
 #if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
 
 static inline u32 task_cls_classid(struct task_struct *p)
@@ -73,6 +75,12 @@ static inline u32 task_cls_classid(struct task_struct *p)
 
 #endif /* CONFIG_NET_CLS_CGROUP */
 
+#else /* !CONFIG_CGROUPS */
+
+static inline void sock_update_classid(struct sock *sk)
+{
+}
+
 #endif /* CONFIG_CGROURPS */
 
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
