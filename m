From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH v3 0/2] get rid of populate for memcg
Date: Mon,  9 Apr 2012 19:36:32 -0300
Message-ID: <1334010994-23301-1-git-send-email-glommer@parallels.com>
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[ v3: fix bug with failed initialization, seen by Tejun ]

Hi Tejun,

Let me know if the following is acceptable. Turns out the only
operation with a side effect we do after the last failure spot,
is a get on the parent memcg, and the setup of our very own refcnt.

Both of them can be dealt with a mem_cgroup_put in the beginning
of the failure path. So I felt no need for any code reordering.

People from the memcg side, please verify if this is indeed
okay.

I actually tested it with some test code to force memcg_kmem_init()
to fail, and it seems to go all right.

I'll be happy to address any other problems you spot.

Glauber Costa (2):
  cgroup: pass struct mem_cgroup instead of struct cgroup to socket
    memcg
  cgroup: get rid of populate for memcg

 include/net/sock.h           |   12 ++++++------
 include/net/tcp_memcontrol.h |    4 ++--
 mm/memcontrol.c              |   39 ++++++++++++++++++---------------------
 net/core/sock.c              |   10 +++++-----
 net/ipv4/tcp_memcontrol.c    |    6 ++----
 5 files changed, 33 insertions(+), 38 deletions(-)

-- 
1.7.7.6
