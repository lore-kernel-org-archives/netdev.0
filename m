From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 6/9] ehea: convert to SKB paged frag API
Date: Mon, 10 Oct 2011 12:11:38 +0100
Message-ID: <1318245101-16890-6-git-send-email-ian.campbell@citrix.com>
References: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Breno Leitao <leitao@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:47504 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753720Ab1JJLLw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Oct 2011 07:11:52 -0400
In-Reply-To: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Breno Leitao <leitao@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index c821cb6..dfefe80 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -1817,8 +1817,7 @@ static inline void write_swqe2_data(struct sk_buff *skb, struct net_device *dev,
 			sg1entry->l_key = lkey;
 			sg1entry->len = frag->size;
 			sg1entry->vaddr =
-				ehea_map_vaddr(page_address(frag->page)
-					       + frag->page_offset);
+				ehea_map_vaddr(skb_frag_address(frag));
 			swqe->descriptors++;
 			sg1entry_contains_frag_data = 1;
 		}
@@ -1830,9 +1829,7 @@ static inline void write_swqe2_data(struct sk_buff *skb, struct net_device *dev,
 
 			sgentry->l_key = lkey;
 			sgentry->len = frag->size;
-			sgentry->vaddr =
-				ehea_map_vaddr(page_address(frag->page)
-					       + frag->page_offset);
+			sgentry->vaddr = ehea_map_vaddr(skb_frag_address(frag));
 			swqe->descriptors++;
 		}
 	}
@@ -2222,9 +2219,7 @@ static void ehea_xmit3(struct sk_buff *skb, struct net_device *dev,
 		/* ... then copy data from the fragments */
 		for (i = 0; i < nfrags; i++) {
 			frag = &skb_shinfo(skb)->frags[i];
-			memcpy(imm_data,
-			       page_address(frag->page) + frag->page_offset,
-			       frag->size);
+			memcpy(imm_data, skb_frag_address(frag), frag->size);
 			imm_data += frag->size;
 		}
 	}
-- 
1.7.2.5
