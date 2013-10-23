From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] Fix: Dereference pointer-value of sk_prot->memory_pressure
Date: Wed, 23 Oct 2013 12:55:18 -0700
Message-ID: <87r4bbiwyh.fsf_-_@xmission.com>
References: <20131022214129.GB2715@localhost>
	<20131022.180023.1141845387743361648.davem@davemloft.net>
	<87k3h461ql.fsf@tw-ebiederman.twitter.com>
	<20131023122543.GH5132@cpaasch-mac>
	<1382533364.7572.15.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Christoph Paasch <christoph.paasch@uclouvain.be>,
	fengguang.wu@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382533364.7572.15.camel@edumazet-glaptop.roam.corp.google.com>
	(Eric Dumazet's message of "Wed, 23 Oct 2013 06:02:44 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Wed, 23 Oct 2013 12:49:21 -0700

2e685cad57 (tcp_memcontrol: Kill struct tcp_memcontrol) falsly modified
the access to memory_pressure of sk->sk_prot->memory_pressure. The patch
did modify the memory_pressure-field of struct cg_proto, but not the one
of struct proto.

So, the access to sk_prot->memory_pressure should not be changed.

Acked-by: Eric Dumazet <edumazet@google.com>
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/sock.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index c93542f92420..e3a18ff0c38b 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1137,7 +1137,7 @@ static inline bool sk_under_memory_pressure(const struct sock *sk)
 	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
 		return !!sk->sk_cgrp->memory_pressure;
 
-	return !!sk->sk_prot->memory_pressure;
+	return !!*sk->sk_prot->memory_pressure;
 }
 
 static inline void sk_leave_memory_pressure(struct sock *sk)
-- 
1.7.5.4
