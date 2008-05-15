From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/5] sky2: don't warn if page allocation fails
Date: Wed, 14 May 2008 17:04:14 -0700
Message-ID: <20080515000432.989061538@vyatta.com>
References: <20080515000412.984337700@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:49973 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760306AbYEOAI2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 20:08:28 -0400
Content-Disposition: inline; filename=sky2-nowarn-alloc-page.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since driver handles page allocation failure, no need for extra
warnings. 

Note: it only allocates single pages so if the system is
so tight it can't one page it is probably hosed anyway.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Please apply to 2.6.26
--- a/drivers/net/sky2.c	2008-05-14 16:29:39.000000000 -0700
+++ b/drivers/net/sky2.c	2008-05-14 16:29:44.000000000 -0700
@@ -1223,7 +1223,7 @@ static struct sk_buff *sky2_rx_alloc(str
 	}
 
 	for (i = 0; i < sky2->rx_nfrags; i++) {
-		struct page *page = alloc_page(GFP_ATOMIC);
+		struct page *page = alloc_page(GFP_ATOMIC | __GFP_NOWARN);
 
 		if (!page)
 			goto free_partial;

-- 

