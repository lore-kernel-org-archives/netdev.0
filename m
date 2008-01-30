From: Dzianis Kahanovich <mahatma@bspu.unibel.by>
Subject: [PATCH] cls_u32 u32_classify() ++
Date: Wed, 30 Jan 2008 11:38:53 -0200
Message-ID: <47A07DED.5000907@bspu.unibel.by>
Reply-To: mahatma@eu.by
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010709020704060408010605"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bspu.unibel.by ([195.50.2.21]:41482 "EHLO
	mail.bspu.unibel.by" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757056AbYA3Jix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 04:38:53 -0500
Received: from [10.200.200.1] ([10.200.200.1])
	by mail.bspu.unibel.by (8.14.1/8.14.0) with ESMTP id m0U9cqUB028002
	for <netdev@vger.kernel.org>; Wed, 30 Jan 2008 11:38:52 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010709020704060408010605
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit

Currently fine u32 "hashkey ... at ..." not work with relative offsets.
There are simpliest fix to use "eat".
(sorry, i'm idiot)

-- 
WBR,
Denis Kaganovich,  mahatma@eu.by  http://mahatma.bspu.unibel.by





--------------010709020704060408010605
Content-Type: text/plain;
 name="cls_u32.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="cls_u32.diff"

diff -pruN linux-2.6.orig/net/sched/cls_u32.c linux-2.6/net/sched/cls_u32.c
--- linux-2.6.orig/net/sched/cls_u32.c	2008-01-29 23:02:50.000000000 +0200
+++ linux-2.6/net/sched/cls_u32.c	2008-01-30 11:37:31.000000000 +0200
@@ -181,11 +181,13 @@ check_terminal:
 
 		ht = n->ht_down;
 		sel = 0;
-		if (ht->divisor)
-			sel = ht->divisor&u32_hash_fold(*(u32*)(ptr+n->sel.hoff), &n->sel,n->fshift);
 
-		if (!(n->sel.flags&(TC_U32_VAROFFSET|TC_U32_OFFSET|TC_U32_EAT)))
+		if (!(n->sel.flags&(TC_U32_VAROFFSET|TC_U32_OFFSET|TC_U32_EAT))) {
+			if (!ht->divisor)
+				goto next_ht;
+			sel = ht->divisor&u32_hash_fold(*(u32*)(ptr+n->sel.hoff), &n->sel,n->fshift);
 			goto next_ht;
+		}
 
 		if (n->sel.flags&(TC_U32_OFFSET|TC_U32_VAROFFSET)) {
 			off2 = n->sel.off + 3;
@@ -198,6 +200,9 @@ check_terminal:
 			off2 = 0;
 		}
 
+		if (ht->divisor && ptr+n->sel.hoff+4 < skb_tail_pointer(skb))
+			sel = ht->divisor&u32_hash_fold(*(u32*)(ptr+n->sel.hoff), &n->sel,n->fshift);
+
 		if (ptr < skb_tail_pointer(skb))
 			goto next_ht;
 	}


--------------010709020704060408010605--
