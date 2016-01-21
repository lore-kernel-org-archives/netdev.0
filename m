From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] net: sock: remove dead cgroup methods from struct proto
Date: Thu, 21 Jan 2016 14:01:11 -0500
Message-ID: <1453402871-2548-1-git-send-email-hannes@cmpxchg.org>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The cgroup methods are no longer used after baac50b ("net:
tcp_memcontrol: simplify linkage between socket and page counter").
The hunk to delete them was included in the original patch but must
have gotten lost during conflict resolution on the way upstream.

Fixes: baac50b ("net: tcp_memcontrol: simplify linkage between socket and page counter")
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/net/sock.h | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index b9e7b3d..f5ea148 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1036,18 +1036,6 @@ struct proto {
 #ifdef SOCK_REFCNT_DEBUG
 	atomic_t		socks;
 #endif
-#ifdef CONFIG_MEMCG_KMEM
-	/*
-	 * cgroup specific init/deinit functions. Called once for all
-	 * protocols that implement it, from cgroups populate function.
-	 * This function has to setup any files the protocol want to
-	 * appear in the kmem cgroup filesystem.
-	 */
-	int			(*init_cgroup)(struct mem_cgroup *memcg,
-					       struct cgroup_subsys *ss);
-	void			(*destroy_cgroup)(struct mem_cgroup *memcg);
-	struct cg_proto		*(*proto_cgroup)(struct mem_cgroup *memcg);
-#endif
 	int			(*diag_destroy)(struct sock *sk, int err);
 };
 
-- 
2.7.0
