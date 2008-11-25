From: Arjan van de Ven <arjan@infradead.org>
Subject: [PATCH] net: make skb_truesize_bug() call WARN()
Date: Tue, 25 Nov 2008 08:32:50 -0800
Message-ID: <20081125083250.2ad7d75d@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:58438 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917AbYKYQbu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 11:31:50 -0500
Received: from c-71-193-193-226.hsd1.or.comcast.net ([71.193.193.226] helo=localhost.localdomain)
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1L50pI-0007Lu-He
	for netdev@vger.kernel.org; Tue, 25 Nov 2008 16:31:49 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 97a8ab520c378568e172c555a156b469137a3828 Mon Sep 17 00:00:00 2001
From: Arjan van de Ven <arjan@linux.intel.com>
Date: Tue, 25 Nov 2008 08:30:04 -0800
Subject: [PATCH] net: make skb_truesize_bug() call WARN()

The truesize message check is important enough to make it print "BUG" to the
user console... lets also make it important enough to spit a backtrace/module list
etc so that kerneloops.org can track them.

Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---
 net/core/skbuff.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 391be91..1a1f4d1 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -149,7 +149,7 @@ void skb_under_panic(struct sk_buff *skb, int sz, void *here)
 
 void skb_truesize_bug(struct sk_buff *skb)
 {
-	printk(KERN_ERR "SKB BUG: Invalid truesize (%u) "
+	WARN(1, KERN_ERR "SKB BUG: Invalid truesize (%u) "
 	       "len=%u, sizeof(sk_buff)=%Zd\n",
 	       skb->truesize, skb->len, sizeof(struct sk_buff));
 }
-- 
1.6.0.3



-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
