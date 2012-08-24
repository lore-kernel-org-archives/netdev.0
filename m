From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: [PATCH v2 09/10] cgroup: net_prio: Simplify ifdef logic
Date: Fri, 24 Aug 2012 16:01:43 +0200
Message-ID: <1345816904-21745-10-git-send-email-wagi@monom.org>
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
 include/net/netprio_cgroup.h | 14 +++++++-------
 net/core/sock.c              |  2 ++
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
index 66241c6..ab22019 100644
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@ -18,14 +18,14 @@
 #include <linux/rcupdate.h>
 #include <linux/jump_label.h>
 
+#if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
+
 struct netprio_map {
 	struct rcu_head rcu;
 	u32 priomap_len;
 	u32 priomap[];
 };
 
-#ifdef CONFIG_CGROUPS
-
 struct cgroup_netprio_state {
 	struct cgroup_subsys_state css;
 	u32 prioidx;
@@ -69,17 +69,17 @@ static inline u32 task_netprioidx(struct task_struct *p)
 	return idx;
 }
 
-#else
+#endif
+
+#else  /* !CONFIG_NETPRIO_CGROUP */
 
 static inline u32 task_netprioidx(struct task_struct *p)
 {
 	return 0;
 }
 
-#endif /* CONFIG_NETPRIO_CGROUP */
-
-#else
 #define sock_update_netprioidx(sk, task)
-#endif
+
+#endif  /* CONFIG_NETPRIO_CGROUP */
 
 #endif  /* _NET_CLS_CGROUP_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index b1fadfd..115cd59 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1237,6 +1237,7 @@ void sock_update_classid(struct sock *sk)
 EXPORT_SYMBOL(sock_update_classid);
 #endif
 
+#if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
 void sock_update_netprioidx(struct sock *sk, struct task_struct *task)
 {
 	if (in_interrupt())
@@ -1246,6 +1247,7 @@ void sock_update_netprioidx(struct sock *sk, struct task_struct *task)
 }
 EXPORT_SYMBOL_GPL(sock_update_netprioidx);
 #endif
+#endif
 
 /**
  *	sk_alloc - All socket objects are allocated here
-- 
1.7.12.rc1.16.g05a20c8
