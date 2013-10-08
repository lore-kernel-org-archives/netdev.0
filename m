From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 1/2] cgroup: netprio: remove unnecessary task_netprioidx
Date: Tue, 8 Oct 2013 11:05:19 +0800
Message-ID: <1381201520-25938-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Since the tasks have been migrated to the cgroup,
there is no need to call task_netprioidx to get
task's cgroup id.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 net/core/netprio_cgroup.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index d9cd627..9b7cf6c 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -222,11 +222,10 @@ static void net_prio_attach(struct cgroup_subsys_state *css,
 			    struct cgroup_taskset *tset)
 {
 	struct task_struct *p;
-	void *v;
+	void *v = (void *)(unsigned long)css->cgroup->id;
 
 	cgroup_taskset_for_each(p, css, tset) {
 		task_lock(p);
-		v = (void *)(unsigned long)task_netprioidx(p);
 		iterate_fd(p->files, 0, update_netprio, v);
 		task_unlock(p);
 	}
-- 
1.8.3.1
