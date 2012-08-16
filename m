From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: [PATCH v0 1/5] cgroup: Use empty task_cls_classid() when !CONFIG_NET_CLS(_MODULE)
Date: Thu, 16 Aug 2012 16:12:12 +0200
Message-ID: <1345126336-20755-2-git-send-email-wagi@monom.org>
References: <1345126336-20755-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1345126336-20755-1-git-send-email-wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>

Signed-off-by: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Cc: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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
