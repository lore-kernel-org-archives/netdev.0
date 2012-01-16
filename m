From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH] move sock_update_memcg outside of CONFIG_INET
Date: Mon, 16 Jan 2012 12:04:39 +0400
Message-ID: <1326701079-10331-1-git-send-email-glommer@parallels.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Although only used currently for tcp sockets, this function
is now used in common sock code (for sock_clone())

Commit 475f1b52645a29936b9df1d8fcd45f7e56bd4a9f moved the
declaration of sock_update_clone() to inside sock.c, but
this only fixes the problem when CONFIG_CGROUP_MEM_RES_CTLR_KMEM
is also not defined.

This patch here is verified to fix both problems, although
reverting the previous one is not necessary.

Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
CC: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
CC: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
---
 mm/memcontrol.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 602207b..3dbff4d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -373,7 +373,6 @@ static void mem_cgroup_put(struct mem_cgroup *memcg);
 
 /* Writing them here to avoid exposing memcg's inner layout */
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
-#ifdef CONFIG_INET
 #include <net/sock.h>
 #include <net/ip.h>
 
@@ -420,6 +419,7 @@ void sock_release_memcg(struct sock *sk)
 	}
 }
 
+#ifdef CONFIG_INET
 struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg)
 {
 	if (!memcg || mem_cgroup_is_root(memcg))
-- 
1.7.7.4
