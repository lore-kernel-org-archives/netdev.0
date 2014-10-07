From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net_sched: fix unused variables in __gnet_stats_copy_basic_cpu()
Date: Mon,  6 Oct 2014 17:01:33 -0700
Message-ID: <1412640093-11388-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.fastabend@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:39922 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbaJGABm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 20:01:42 -0400
Received: by mail-pd0-f172.google.com with SMTP id ft15so4073857pdb.31
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 17:01:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Probably not a big deal, but we'd better just use the
one we get in retry loop.

Fixes: commit 22e0f8b9322cb1a48b1357e8 ("net: sched: make bstats per cpu and estimator RCU safe")
Reported-by: Joe Perches <joe@perches.com>
Cc: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/core/gen_stats.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index 14681b9..0c08062 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -106,8 +106,8 @@ __gnet_stats_copy_basic_cpu(struct gnet_stats_basic_packed *bstats,
 	for_each_possible_cpu(i) {
 		struct gnet_stats_basic_cpu *bcpu = per_cpu_ptr(cpu, i);
 		unsigned int start;
-		__u64 bytes;
-		__u32 packets;
+		u64 bytes;
+		u32 packets;
 
 		do {
 			start = u64_stats_fetch_begin_irq(&bcpu->syncp);
@@ -115,8 +115,8 @@ __gnet_stats_copy_basic_cpu(struct gnet_stats_basic_packed *bstats,
 			packets = bcpu->bstats.packets;
 		} while (u64_stats_fetch_retry_irq(&bcpu->syncp, start));
 
-		bstats->bytes += bcpu->bstats.bytes;
-		bstats->packets += bcpu->bstats.packets;
+		bstats->bytes += bytes;
+		bstats->packets += packets;
 	}
 }
 
-- 
1.8.3.1
