From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: [PATCH v2 07/10] cgroup: net_cls: Simplify ifdef logic
Date: Fri, 24 Aug 2012 16:01:41 +0200
Message-ID: <1345816904-21745-8-git-send-email-wagi@monom.org>
References: <1345816904-21745-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1345816904-21745-1-git-send-email-wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
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
 include/net/cls_cgroup.h | 12 +++++-------
 net/core/sock.c          |  2 ++
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index 43fae13..5906a25 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -18,7 +18,7 @@
 #include <linux/rcupdate.h>
 #include <linux/jump_label.h>
 
-#ifdef CONFIG_CGROUPS
+#if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
 struct cgroup_cls_state
 {
 	struct cgroup_subsys_state css;
@@ -64,21 +64,19 @@ static inline u32 task_cls_classid(struct task_struct *p)
 	return classid;
 }
 
-#else
+#endif
+
+#else /* !CONFIG_NET_CLS_CGROUP */
 
 static inline u32 task_cls_classid(struct task_struct *p)
 {
 	return 0;
 }
 
-#endif /* CONFIG_NET_CLS_CGROUP */
-
-#else /* !CONFIG_CGROUPS */
-
 static inline void sock_update_classid(struct sock *sk)
 {
 }
 
-#endif /* CONFIG_CGROURPS */
+#endif /* CONFIG_NET_CLS_CGROUP */
 
 #endif  /* _NET_CLS_CGROUP_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index aa762d9..b1fadfd 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1223,6 +1223,7 @@ static void sk_prot_free(struct proto *prot, struct sock *sk)
 }
 
 #ifdef CONFIG_CGROUPS
+#if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
 void sock_update_classid(struct sock *sk)
 {
 	u32 classid;
@@ -1234,6 +1235,7 @@ void sock_update_classid(struct sock *sk)
 		sk->sk_classid = classid;
 }
 EXPORT_SYMBOL(sock_update_classid);
+#endif
 
 void sock_update_netprioidx(struct sock *sk, struct task_struct *task)
 {
-- 
1.7.12.rc1.16.g05a20c8
