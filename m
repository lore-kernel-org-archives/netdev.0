From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED]: sch_hfsc: replace ASSERT macro by WARN_ON
Date: Tue, 13 Feb 2007 16:20:07 +0100
Message-ID: <45D1D727.8010401@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050002080602080700020800"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38547 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbXBMPUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 10:20:12 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050002080602080700020800
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------050002080602080700020800
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET_SCHED]: sch_hfsc: replace ASSERT macro by WARN_ON

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit ee0d5b5b1a2f81dabd5189c6ac960e7cab40d8ff
tree 6975f4ea578fb1e86f8d9c7607fa08ec3a8c841f
parent 6e1d9d04c4004361fb327abcbde74a20e8dca2ff
author Patrick McHardy <kaber@trash.net> Tue, 13 Feb 2007 16:15:12 +0100
committer Patrick McHardy <kaber@trash.net> Tue, 13 Feb 2007 16:15:12 +0100

 net/sched/sch_hfsc.c |   15 +--------------
 1 files changed, 1 insertions(+), 14 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 135087d..396deb7 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -71,8 +71,6 @@ #include <net/pkt_cls.h>
 #include <asm/system.h>
 #include <asm/div64.h>
 
-#define HFSC_DEBUG 1
-
 /*
  * kernel internal service curve representation:
  *   coordinates are given by 64 bit unsigned integers.
@@ -211,17 +209,6 @@ do {									\
 } while (0)
 #endif
 
-#if HFSC_DEBUG
-#define ASSERT(cond)							\
-do {									\
-	if (unlikely(!(cond)))						\
-		printk("assertion %s failed at %s:%i (%s)\n",		\
-		       #cond, __FILE__, __LINE__, __FUNCTION__);	\
-} while (0)
-#else
-#define ASSERT(cond)
-#endif /* HFSC_DEBUG */
-
 #define	HT_INFINITY	0xffffffffffffffffULL	/* infinite time value */
 
 
@@ -1492,7 +1479,7 @@ hfsc_schedule_watchdog(struct Qdisc *sch
 		if (next_time == 0 || next_time > q->root.cl_cfmin)
 			next_time = q->root.cl_cfmin;
 	}
-	ASSERT(next_time != 0);
+	WARN_ON(next_time == 0);
 	delay = next_time - cur_time;
 	delay = PSCHED_US2JIFFIE(delay);
 

--------------050002080602080700020800--
