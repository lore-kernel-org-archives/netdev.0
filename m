From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: [PATCH v1 0/5] cgroup: Assign subsystem IDs during compile time
Date: Fri, 17 Aug 2012 16:58:09 +0200
Message-ID: <1345215494-9181-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>

Hi,

I was able to 'fix' CGROUP_BUILTIN_SUBSYS_COUNT defition. With this
version there is no unused subsys_id. 

The number of builtin subsystem are counted with gcc's predefined
__COUNTER__ macro. This is a bit fragile, because __COUNTER__
is only reset to 0 per compile unit. There is a workaround for this.
When starting to enumate we need to store the current value of
__COUNTER__ and then subtract that from all enums we define. 

Not sure if that is okay or not.

cheers,
daniel


Original cover letter:

The patch #1 and #2 are there to be able to introduce (#3, #4) the 
jump labels in task_cls_classid() and task_netprioidx(). The jump
labels are needed to know when it is safe to access the controller. 
For example not safe means the module is not yet loaded.

All those patches are just preparation for the center piece (#5) 
of these series. This one will remove the dynamic subsystem ID
generation and falls back to compile time generated IDs. 

This is the first result from the discussion around on the
"cgroup cls & netprio 'cleanups'" patches.

This patches are against net-next


v1: - only use jump labels when built as module (#3, #4)
    - get rid of the additional 'pointer' (#5)
v0: - initial version


Daniel Wagner (5):
  cgroup: Use empty task_cls_classid() when !CONFIG_NET_CLS(_MODULE)
  cgroup: Move sock_update_classid() decleration to cls_cgroup.h
  cgroup: Protect access to task_cls_classid() when built as module
  cgroup: Protect access to task_netprioidx() when built as module
  cgroup: Assign subsystem IDs during compile time

 include/linux/cgroup.h        | 27 ++++++++++++++++++---------
 include/linux/cgroup_subsys.h | 24 ++++++++++++------------
 include/net/cls_cgroup.h      | 39 ++++++++++++++++++++++++++-------------
 include/net/netprio_cgroup.h  | 25 +++++++++++--------------
 include/net/sock.h            |  8 --------
 kernel/cgroup.c               | 25 ++++++-------------------
 net/core/netprio_cgroup.c     | 21 ++++++++++-----------
 net/core/sock.c               | 12 ++++++------
 net/sched/cls_cgroup.c        | 22 +++++++++-------------
 9 files changed, 98 insertions(+), 105 deletions(-)

-- 
1.7.12.rc1.16.g05a20c8
