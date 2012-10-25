From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: [PATCH v1 0/5] Rework net_cls update socket logic
Date: Thu, 25 Oct 2012 16:16:54 +0200
Message-ID: <1351174619-5096-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>

Hi,

I updated this series according the feedback I got. I am not sure
if I did the 'revert' patch correctly (patch #3). 

cheers,
daniel

orignal cover letter:

This series updates net_cls to use the same socket update logic as
net_prio. With this change sock_update_classid() is not called from
recvmsg, sendmsg and friends anymore. This seems to be a good idea.

Credit goes to John Fastabend for this work.

The patches are against net-next.

Daniel Wagner (5):
  cgroup: net_prio: Mark local used function static
  cgroup: net_cls: Fix local variable type decleration
  cgroup: net_cls: Remove rcu_read_lock/unlock
  cgroup: net_cls: Pass in task to sock_update_classid()
  cgroup: net_cls: Rework update socket logic

 drivers/net/tun.c         |  3 ---
 include/net/cls_cgroup.h  |  4 ++--
 net/core/netprio_cgroup.c |  2 +-
 net/core/sock.c           |  8 +++-----
 net/sched/cls_cgroup.c    | 24 ++++++++++++++++++++++++
 net/socket.c              |  8 --------
 6 files changed, 30 insertions(+), 19 deletions(-)

-- 
1.8.0.rc0
