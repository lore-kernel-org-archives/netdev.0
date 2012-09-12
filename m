From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: [PATCH v4 1/8] cgroup: net_cls: Move sock_update_classid() declaration to cls_cgroup.h
Date: Wed, 12 Sep 2012 16:12:01 +0200
Message-ID: <1347459128-32236-2-git-send-email-wagi@monom.org>
References: <1347459128-32236-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1347459128-32236-1-git-send-email-wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>

The only user of sock_update_classid() is net/socket.c which happens
to include cls_cgroup.h directly.

Signed-off-by: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
Acked-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Cc: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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
1.7.12.315.g682ce8b
