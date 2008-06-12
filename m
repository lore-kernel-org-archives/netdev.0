From: Vegard Nossum <vegard.nossum@gmail.com>
Subject: [PATCH] net: remove initialization of static per-cpu variables
Date: Thu, 12 Jun 2008 23:23:10 +0200
Message-ID: <20080612212310.GF3283@damson.getinternet.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.237]:34972 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752682AbYFLVXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 17:23:16 -0400
Received: by hu-out-0506.google.com with SMTP id 28so5111965hub.21
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2008 14:23:14 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vegard Nossum <vegard.nossum@gmail.com>
Date: Thu, 12 Jun 2008 22:15:58 +0200
Subject: [PATCH] net: remove initialization of static per-cpu variables

Cc: netdev@vger.kernel.org
Signed-off-by: Vegard Nossum <vegard.nossum@gmail.com>
---
 net/core/flow.c |    6 +++---
 net/socket.c    |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/flow.c b/net/core/flow.c
index 1999117..9375bb9 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -39,7 +39,7 @@ atomic_t flow_cache_genid = ATOMIC_INIT(0);
 
 static u32 flow_hash_shift;
 #define flow_hash_size	(1 << flow_hash_shift)
-static DEFINE_PER_CPU(struct flow_cache_entry **, flow_tables) = { NULL };
+static DEFINE_PER_CPU(struct flow_cache_entry **, flow_tables);
 
 #define flow_table(cpu) (per_cpu(flow_tables, cpu))
 
@@ -52,7 +52,7 @@ struct flow_percpu_info {
 	u32 hash_rnd;
 	int count;
 };
-static DEFINE_PER_CPU(struct flow_percpu_info, flow_hash_info) = { 0 };
+static DEFINE_PER_CPU(struct flow_percpu_info, flow_hash_info);
 
 #define flow_hash_rnd_recalc(cpu) \
 	(per_cpu(flow_hash_info, cpu).hash_rnd_recalc)
@@ -69,7 +69,7 @@ struct flow_flush_info {
 	atomic_t cpuleft;
 	struct completion completion;
 };
-static DEFINE_PER_CPU(struct tasklet_struct, flow_flush_tasklets) = { NULL };
+static DEFINE_PER_CPU(struct tasklet_struct, flow_flush_tasklets);
 
 #define flow_flush_tasklet(cpu) (&per_cpu(flow_flush_tasklets, cpu))
 
diff --git a/net/socket.c b/net/socket.c
index 66c4a8c..c8375ec 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -151,7 +151,7 @@ static const struct net_proto_family *net_families[NPROTO] __read_mostly;
  *	Statistics counters of the socket lists
  */
 
-static DEFINE_PER_CPU(int, sockets_in_use) = 0;
+static DEFINE_PER_CPU(int, sockets_in_use);
 
 /*
  * Support routines.
-- 
1.5.4.1

