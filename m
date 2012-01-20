From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH 0/3] fixes for tcp memcg
Date: Fri, 20 Jan 2012 18:57:13 +0400
Message-ID: <1327071436-20763-1-git-send-email-glommer@parallels.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Please consider adding the following fixes to 
your tree.

The first is a remaining build bug, that managed to survive
the bunch of randconfigs I tested with from my last fix (It
still breaks without CONFIG_NET, which is likely selected
by a bunch of other options).

The other two patches are a fix for a bug I verified in
my followup testings in the controller itself, that causes
a charge/uncharge mismatch under certain circumnstances.

Thanks

Glauber Costa (3):
  net: fix socket memcg build with !CONFIG_NET
  cgroup: make sure memcg margin is 0 when over limit
  net: introduce res_counter_charge_nofail() for socket allocations

 include/linux/res_counter.h |   11 ++++++++++-
 include/net/sock.h          |   12 +++++-------
 kernel/res_counter.c        |   25 +++++++++++++++++++++++++
 mm/memcontrol.c             |    4 ++--
 net/core/sock.c             |    4 ++--
 5 files changed, 44 insertions(+), 12 deletions(-)

-- 
1.7.7.4
