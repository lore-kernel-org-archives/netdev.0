From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH 0/2] Proposed fixes for tcp memory pressure
Date: Thu, 15 Dec 2011 13:34:30 +0400
Message-ID: <1323941672-14324-1-git-send-email-glommer@parallels.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

I propose the following two fixes for the issues we're having in
linux-next.

The first one just moves the definition out of the CONFIG_INET,
and should fix the compile problems with allnoconfig.

The second one is a bit bigger, and takes away the socket
registration functions. As I've explained in the Changelog,
I believe this to be the saner way to do it. We need to do allocations
in both create and init time. 

This was compile tested with 4 different randconfigs, CGROUPS off,
KMEM cgroup off, INET off, all them on, and boot tested with
everything on.

Thanks.

Glauber Costa (2):
  Move limit definitions outside CONFIG_INET
  Explicitly call tcp creation and init from memcontrol.c

 include/linux/memcontrol.h   |    2 +-
 include/net/sock.h           |    2 --
 include/net/tcp_memcontrol.h |   19 ++++++++++++++++++-
 mm/memcontrol.c              |   13 ++++---------
 net/core/sock.c              |   37 -------------------------------------
 net/ipv4/tcp_memcontrol.c    |   11 ++++++-----
 6 files changed, 29 insertions(+), 55 deletions(-)

-- 
1.7.6.4

--
To unsubscribe from this list: send the line "unsubscribe cgroups" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
