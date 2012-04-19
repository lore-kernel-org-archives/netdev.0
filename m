From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH 0/3] Fix problem with static_key decrement
Date: Thu, 19 Apr 2012 19:49:15 -0300
Message-ID: <1334875758-20939-1-git-send-email-glommer@parallels.com>
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

This is my proposed fix for the sock memcg static_key
problem raised by Kamezawa. It works for me, but I would
Kame, please confirm.

For that to work, I am dependent on two cgroup patches
that goes attached. The rationale behind it, is that we
can't do static_key updates with the cgroup_mutex held,
or we risk deadlocking.

Looking closely, there seem to be no particular reason
to hold the cgroup_mutex during destruction. Subsystems
that really need it, can hold it themselves.

Tejun, let me know if this is acceptable from your PoV.

Glauber Costa (3):
  don't attach a task to a dead cgroup
  don't take cgroup_mutex in destroy()
  decrement static keys on real destroy time

 block/blk-cgroup.c        |    2 +
 include/net/sock.h        |    9 +++++++
 kernel/cgroup.c           |   12 ++++++----
 kernel/cpuset.c           |    2 +
 mm/memcontrol.c           |   20 +++++++++++++++-
 net/ipv4/tcp_memcontrol.c |   52 ++++++++++++++++++++++++++++++++++++++------
 6 files changed, 83 insertions(+), 14 deletions(-)

-- 
1.7.7.6
