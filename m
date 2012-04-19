From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH 1/3] don't attach a task to a dead cgroup
Date: Thu, 19 Apr 2012 19:49:16 -0300
Message-ID: <1334875758-20939-2-git-send-email-glommer@parallels.com>
References: <1334875758-20939-1-git-send-email-glommer@parallels.com>
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
	Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1334875758-20939-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Not all external callers of cgroup_attach_task() test to
see if the cgroup is still live - the internal callers at
cgroup.c does.

With this test in cgroup_attach_task, we can assure that
no tasks are ever moved to a cgroup that is past its
destruction point and was already marked as dead.

Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
CC: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
CC: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index b61b938..932c318 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1927,6 +1927,9 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 	struct cgroup_taskset tset = { };
 	struct css_set *newcg;
 
+	if (cgroup_is_removed(cgrp))
+		return -ENODEV;
+
 	/* @tsk either already exited or can't exit until the end */
 	if (tsk->flags & PF_EXITING)
 		return -ESRCH;
-- 
1.7.7.6
