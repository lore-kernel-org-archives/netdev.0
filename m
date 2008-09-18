From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] net: em_cmp.c use unaligned access helpers
Date: Wed, 17 Sep 2008 17:00:42 -0700
Message-ID: <1221696043.7298.8.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:11931 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbYIRAAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2008 20:00:46 -0400
Received: by py-out-1112.google.com with SMTP id p76so2600140pyb.10
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2008 17:00:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 net/sched/em_cmp.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/sched/em_cmp.c b/net/sched/em_cmp.c
index cc49c93..bc45039 100644
--- a/net/sched/em_cmp.c
+++ b/net/sched/em_cmp.c
@@ -14,6 +14,7 @@
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
 #include <linux/tc_ematch/tc_em_cmp.h>
+#include <asm/unaligned.h>
 #include <net/pkt_cls.h>
 
 static inline int cmp_needs_transformation(struct tcf_em_cmp *cmp)
@@ -37,8 +38,7 @@ static int em_cmp_match(struct sk_buff *skb, struct tcf_ematch *em,
 			break;
 
 		case TCF_EM_ALIGN_U16:
-			val = *ptr << 8;
-			val |= *(ptr+1);
+			val = get_unaligned_be16(ptr);
 
 			if (cmp_needs_transformation(cmp))
 				val = be16_to_cpu(val);
@@ -47,10 +47,7 @@ static int em_cmp_match(struct sk_buff *skb, struct tcf_ematch *em,
 		case TCF_EM_ALIGN_U32:
 			/* Worth checking boundries? The branching seems
 			 * to get worse. Visit again. */
-			val = *ptr << 24;
-			val |= *(ptr+1) << 16;
-			val |= *(ptr+2) << 8;
-			val |= *(ptr+3);
+			val = get_unaligned_be32(ptr);
 
 			if (cmp_needs_transformation(cmp))
 				val = be32_to_cpu(val);
-- 
1.6.0.2.405.g3cc38



