From: shakya.das@samsung.com
Subject: [PATCH] net: ipv4: tcp_offload: check segs for NULL
Date: Thu, 15 Dec 2016 14:17:41 +0530
Message-ID: <1481791661-21670-1-git-send-email-shakya.das@samsung.com>
Cc: netdev@vger.kernel.org, shakya89.das@gmail.com,
        vidushi.koul@samsung.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:54621 "EHLO
        mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757769AbcLOI6N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 03:58:13 -0500
Received: from epcpsbgm2new.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0OI701EREXRZC8E0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Thu, 15 Dec 2016 17:47:59 +0900 (KST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shakya Sundar Das <shakya.das@samsung.com>

This patch will check segs for being NULL in tcp_gso_segment()
before calling skb_shinfo(segs) from skb_is_gso(segs), otherwise
kernel can run into a NULL-pointer dereference.

Signed-off-by: Shakya Sundar Das <shakya.das@samsung.com>
---
 net/ipv4/tcp_offload.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index bc68da3..93feefd 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -96,7 +96,7 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 	skb->ooo_okay = 0;
 
 	segs = skb_segment(skb, features);
-	if (IS_ERR(segs))
+	if (IS_ERR_OR_NULL(segs))
 		goto out;
 
 	/* Only first segment might have ooo_okay set */
-- 
1.7.9.5
