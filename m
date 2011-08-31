From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 02/14] jme: convert to SKB paged frag API.
Date: Wed, 31 Aug 2011 11:46:54 +0100
Message-ID: <1314787626-12273-2-git-send-email-ian.campbell@citrix.com>
References: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Guo-Fu Tseng <cooldavid@cooldavid.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:55267 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753427Ab1HaKrL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 06:47:11 -0400
In-Reply-To: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/jme.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index a869ee4..48a0a23 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -1928,8 +1928,9 @@ jme_map_tx_skb(struct jme_adapter *jme, struct sk_buff *skb, int idx)
 		ctxdesc = txdesc + ((idx + i + 2) & (mask));
 		ctxbi = txbi + ((idx + i + 2) & (mask));
 
-		jme_fill_tx_map(jme->pdev, ctxdesc, ctxbi, frag->page,
-				 frag->page_offset, frag->size, hidma);
+		jme_fill_tx_map(jme->pdev, ctxdesc, ctxbi,
+				skb_frag_page(frag),
+				frag->page_offset, frag->size, hidma);
 	}
 
 	len = skb_is_nonlinear(skb) ? skb_headlen(skb) : skb->len;
-- 
1.7.2.5
