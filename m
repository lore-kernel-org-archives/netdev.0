From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH] net: codel: fix build errors
Date: Mon, 14 May 2012 19:14:47 +0200
Message-ID: <1337015687-17693-1-git-send-email-levinsasha928@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Sasha Levin <levinsasha928@gmail.com>
To: edumazet@google.com, dave.taht@bufferbloat.net, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:56972 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901Ab2ENRNs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 13:13:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the following build error:

net/sched/sch_fq_codel.c: In function 'fq_codel_dump_stats':
net/sched/sch_fq_codel.c:464:3: error: unknown field 'qdisc_stats' specified in initializer
net/sched/sch_fq_codel.c:464:3: warning: missing braces around initializer
net/sched/sch_fq_codel.c:464:3: warning: (near initialization for 'st.<anonymous>')
net/sched/sch_fq_codel.c:465:3: error: unknown field 'qdisc_stats' specified in initializer
net/sched/sch_fq_codel.c:465:3: warning: excess elements in struct initializer
net/sched/sch_fq_codel.c:465:3: warning: (near initialization for 'st')
net/sched/sch_fq_codel.c:466:3: error: unknown field 'qdisc_stats' specified in initializer
net/sched/sch_fq_codel.c:466:3: warning: excess elements in struct initializer
net/sched/sch_fq_codel.c:466:3: warning: (near initialization for 'st')
net/sched/sch_fq_codel.c:467:3: error: unknown field 'qdisc_stats' specified in initializer
net/sched/sch_fq_codel.c:467:3: warning: excess elements in struct initializer
net/sched/sch_fq_codel.c:467:3: warning: (near initialization for 'st')
make[1]: *** [net/sched/sch_fq_codel.o] Error 1

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 include/linux/pkt_sched.h |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 32aef0a..c304eda 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -732,7 +732,9 @@ struct tc_fq_codel_xstats {
 	union {
 		struct tc_fq_codel_qd_stats qdisc_stats;
 		struct tc_fq_codel_cl_stats class_stats;
-	};
+	} u;
+#define qdisc_stats u.qdisc_stats
+#define class_stats u.class_stats
 };
 
 #endif
-- 
1.7.8.6
