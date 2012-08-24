From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v2 01/10] cgroup: net_cls: Use empty task_cls_classid() when !CONFIG_NET_CLS(_MODULE)
Date: Fri, 24 Aug 2012 16:01:35 +0200
Message-ID: <1345816904-21745-2-git-send-email-wagi@monom.org>
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
Received: from hotel311.server4you.de ([85.25.146.15]:40387 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932403Ab2HXOBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 10:01:46 -0400
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
 include/net/cls_cgroup.h | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index a4dc5b0..e2fe2b9 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -24,7 +24,8 @@ struct cgroup_cls_state
 	u32 classid;
 };
 
-#ifdef CONFIG_NET_CLS_CGROUP
+#if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
+
 static inline u32 task_cls_classid(struct task_struct *p)
 {
 	int classid;
@@ -39,7 +40,9 @@ static inline u32 task_cls_classid(struct task_struct *p)
 
 	return classid;
 }
-#else
+
+#elif IS_MODULE(CONFIG_NET_CLS_CGROUP)
+
 extern int net_cls_subsys_id;
 
 static inline u32 task_cls_classid(struct task_struct *p)
@@ -60,11 +63,16 @@ static inline u32 task_cls_classid(struct task_struct *p)
 
 	return classid;
 }
-#endif
+
 #else
+
 static inline u32 task_cls_classid(struct task_struct *p)
 {
 	return 0;
 }
-#endif
+
+#endif /* CONFIG_NET_CLS_CGROUP */
+
+#endif /* CONFIG_CGROURPS */
+
 #endif  /* _NET_CLS_CGROUP_H */
-- 
1.7.12.rc1.16.g05a20c8
