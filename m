From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v2 08/10] cgroup: net_cls: Merge builtin and module version of task_cls_classid()
Date: Fri, 24 Aug 2012 16:01:42 +0200
Message-ID: <1345816904-21745-9-git-send-email-wagi@monom.org>
References: <1345816904-21745-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S. Miller" <davem@davemloft.net>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Li Zefan <lizefan@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>, Tejun Heo <tj@kernel.org>
To: netdev@vger.kernel.org, cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:40405 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932567Ab2HXOBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 10:01:53 -0400
In-Reply-To: <1345816904-21745-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: netdev@vger.kernel.org
Cc: cgroups@vger.kernel.org
---
 include/net/cls_cgroup.h | 19 +++----------------
 1 file changed, 3 insertions(+), 16 deletions(-)

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index 5906a25..d96dc59 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -29,26 +29,15 @@ extern void sock_update_classid(struct sock *sk);
 
 #if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
 
-static inline u32 task_cls_classid(struct task_struct *p)
-{
-	int classid;
-
-	if (in_interrupt())
-		return 0;
-
-	rcu_read_lock();
-	classid = container_of(task_subsys_state(p, net_cls_subsys_id),
-			       struct cgroup_cls_state, css)->classid;
-	rcu_read_unlock();
-
-	return classid;
-}
+#define clscg_enabled 1
 
 #elif IS_MODULE(CONFIG_NET_CLS_CGROUP)
 
 extern struct static_key cgroup_cls_enabled;
 #define clscg_enabled static_key_false(&cgroup_cls_enabled)
 
+#endif
+
 static inline u32 task_cls_classid(struct task_struct *p)
 {
 	u32 classid;
@@ -64,8 +53,6 @@ static inline u32 task_cls_classid(struct task_struct *p)
 	return classid;
 }
 
-#endif
-
 #else /* !CONFIG_NET_CLS_CGROUP */
 
 static inline u32 task_cls_classid(struct task_struct *p)
-- 
1.7.12.rc1.16.g05a20c8
