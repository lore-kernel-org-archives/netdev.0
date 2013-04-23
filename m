From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: remove redundant code in dev_hard_start_xmit()
Date: Mon, 22 Apr 2013 17:31:34 -0700
Message-ID: <1366677094.16391.97.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Krishna Kumar <krkumar2@in.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:47510 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752221Ab3DWAbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 20:31:36 -0400
Received: by mail-ie0-f177.google.com with SMTP id 9so73573iec.22
        for <netdev@vger.kernel.org>; Mon, 22 Apr 2013 17:31:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

This reverts commit 068a2de57ddf4f4 (net: release dst entry while
cache-hot for GSO case too)

Before GSO packet segmentation, we already take care of skb->dst if it
can be released.

There is no point adding extra test for every segment in the gso loop.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Krishna Kumar <krkumar2@in.ibm.com>
---
 net/core/dev.c |    7 -------
 1 file changed, 7 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 8a3cb2c..6a82eed 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2543,13 +2543,6 @@ gso:
 		skb->next = nskb->next;
 		nskb->next = NULL;
 
-		/*
-		 * If device doesn't need nskb->dst, release it right now while
-		 * its hot in this cpu cache
-		 */
-		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
-			skb_dst_drop(nskb);
-
 		if (!list_empty(&ptype_all))
 			dev_queue_xmit_nit(nskb, dev);
 
