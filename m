From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: [PATCH v3 0/6]  cgroup cls & netprio 'cleanups'
Date: Tue, 14 Aug 2012 15:02:16 +0200
Message-ID: <1344949343-26090-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Tim Chen <tim.c.chen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>

Hi,

Sorry for the delay on updating this series. The usual
excuse apply here.

I saw that John is busy improving net_prio so I took the
liberty to port his changes to net_cls (#1-3). Patch #3 will
collide with John's unapplied patches. I am happy
to rebase this series if needed. 

Patch #4 and #5 improve the readability with using
IS_MODULE/BUILTIN macros. This patches prepare the last
patch.

Patch #6 removes support for assigning subsystem IDs during
runtime. As it turns out this is not really needed. By doing
so we are able to free some unused memory.

The patches are against net-next.

cheers,
daniel

Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Cc: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Tim Chen <tim.c.chen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

Daniel Wagner (6):
  cgroup: Move cls function definition to cls_cgroup.h
  cgroup: net_cls rework update socket logic
  cgroup: Update classid for fd pass in SCM_RIGHTS datagramm
  cgroup: Use IS_MODULE/BUITLIN for net_cls
  cgroup: Use IS_MODULE/BUITLIN for net_prio
  cgroup: Assign subsystem IDs during compile time

 include/linux/cgroup.h        | 20 ++++++++++------
 include/linux/cgroup_subsys.h | 24 +++++++++----------
 include/net/cls_cgroup.h      | 36 +++++++++++-----------------
 include/net/netprio_cgroup.h  | 38 +++++++----------------------
 include/net/sock.h            |  8 -------
 kernel/cgroup.c               | 31 +++++++-----------------
 net/core/netprio_cgroup.c     | 19 ++++++---------
 net/core/scm.c                |  7 +++++-
 net/core/sock.c               | 29 ++++++++++++----------
 net/sched/cls_cgroup.c        | 56 +++++++++++++++++++++++++++++++++----------
 net/socket.c                  |  8 -------
 11 files changed, 129 insertions(+), 147 deletions(-)

-- 
1.7.12.rc1.16.g05a20c8
