From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 1/1] net: remove open-coded skb_cow_head.
Date: Tue, 15 Jul 2014 23:55:35 +0200
Message-ID: <20140715215535.GB19363@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:36818 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759703AbaGOVzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 17:55:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 net/core/dev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6e2a2cd..9b91ebb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2407,8 +2407,8 @@ struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 
 		skb_warn_bad_offload(skb);
 
-		if (skb_header_cloned(skb) &&
-		    (err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
+		err = skb_cow_head(skb, 0);
+		if (err < 0)
 			return ERR_PTR(err);
 	}
 
-- 
1.9.3
