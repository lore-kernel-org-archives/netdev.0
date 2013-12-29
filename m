From: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH nf-next v5 0/3] xtables socket classid matching
Date: Sun, 29 Dec 2013 18:27:09 +0100
Message-ID: <1388338032-14713-1-git-send-email-dborkman@redhat.com>
Cc: netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The main patch is patch 3, please refer to the detailled description
there. Patch 1 has been requested by cgroups people to have as a
cleanup. While at it, I've also added a minor, trivial cleanup in
patch 2 for consistency reasons.

Changelog:

* v4->v5:
  - Fixed typo in patch 1, sorry for that, rest unchanged.
* v3->v4:
  - Patch 3 is unchanged from previous version (only minor Kconfig update)
  - Added patch 1 upon request, and while at it also patch 2
* v2->v3:
  - After discussions w/ Tejun, let's not add any cgroups code here,
    thus we _only_ add code in netfilter area, nowhere else, that's
    even more simple and cleaner than proposed.
* v1->v2:
  - Updated commit message, rebased
  - Applied Gao Feng's feedback

Previous discussions, design considerations etc can be found in:

  - v1: http://patchwork.ozlabs.org/patch/280687/
  - v1/alt: http://patchwork.ozlabs.org/patch/282477/
  - v2: http://patchwork.ozlabs.org/patch/284582/
  - v3: http://patchwork.ozlabs.org/patch/304825/

Pablo, please find the unchanged user space part in [1].

Thanks !

 [1] http://patchwork.ozlabs.org/patch/304826/

Daniel Borkmann (3):
  net: net_cls: move cgroupfs classid handling into core
  net: netprio: rename config to be more consistent with cgroup configs
  netfilter: xtables: lightweight process control group matching

 Documentation/cgroups/net_cls.txt        |   5 ++
 include/linux/cgroup_subsys.h            |   4 +-
 include/linux/netdevice.h                |   2 +-
 include/net/cls_cgroup.h                 |  40 ++++-------
 include/net/netprio_cgroup.h             |  18 ++---
 include/net/sock.h                       |   2 +-
 include/uapi/linux/netfilter/Kbuild      |   1 +
 include/uapi/linux/netfilter/xt_cgroup.h |  11 +++
 net/Kconfig                              |  11 ++-
 net/core/Makefile                        |   3 +-
 net/core/dev.c                           |   2 +-
 net/core/netclassid_cgroup.c             | 120 +++++++++++++++++++++++++++++++
 net/core/sock.c                          |  14 +---
 net/netfilter/Kconfig                    |  10 +++
 net/netfilter/Makefile                   |   1 +
 net/netfilter/xt_cgroup.c                |  71 ++++++++++++++++++
 net/sched/Kconfig                        |   1 +
 net/sched/cls_cgroup.c                   | 111 +---------------------------
 18 files changed, 256 insertions(+), 171 deletions(-)
 create mode 100644 include/uapi/linux/netfilter/xt_cgroup.h
 create mode 100644 net/core/netclassid_cgroup.c
 create mode 100644 net/netfilter/xt_cgroup.c

-- 
1.8.3.1
