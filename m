From: akpm@linux-foundation.org
Subject: [patch 3/8] net: em_cmp.c use unaligned access helpers
Date: Mon, 22 Sep 2008 14:50:37 -0700
Message-ID: <200809222150.m8MLocjD031863@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	harvey.harrison@gmail.com, tgraf@suug.ch
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60098 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753884AbYIVV5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 17:57:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
Cc: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/sched/em_cmp.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff -puN net/sched/em_cmp.c~net-em_cmpc-use-unaligned-access-helpers net/sched/em_cmp.c
--- a/net/sched/em_cmp.c~net-em_cmpc-use-unaligned-access-helpers
+++ a/net/sched/em_cmp.c
@@ -14,6 +14,7 @@
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
 #include <linux/tc_ematch/tc_em_cmp.h>
+#include <asm/unaligned.h>
 #include <net/pkt_cls.h>
 
 static inline int cmp_needs_transformation(struct tcf_em_cmp *cmp)
@@ -37,8 +38,7 @@ static int em_cmp_match(struct sk_buff *
 			break;
 
 		case TCF_EM_ALIGN_U16:
-			val = *ptr << 8;
-			val |= *(ptr+1);
+			val = get_unaligned_be16(ptr);
 
 			if (cmp_needs_transformation(cmp))
 				val = be16_to_cpu(val);
@@ -47,10 +47,7 @@ static int em_cmp_match(struct sk_buff *
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
_
