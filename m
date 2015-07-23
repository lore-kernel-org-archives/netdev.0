From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] niu: don't count tx error twice in case of headroom realloc fails
Date: Thu, 23 Jul 2015 12:20:37 +0200
Message-ID: <1437646837-5631-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:34549 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751874AbbGWKUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 06:20:41 -0400
Received: by wibud3 with SMTP id ud3so17230477wib.1
        for <netdev@vger.kernel.org>; Thu, 23 Jul 2015 03:20:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: a3138df9 ("[NIU]: Add Sun Neptune ethernet driver.")
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/sun/niu.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 0c5842a..ab6051a 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -6658,10 +6658,8 @@ static netdev_tx_t niu_start_xmit(struct sk_buff *skb,
 		struct sk_buff *skb_new;
 
 		skb_new = skb_realloc_headroom(skb, len);
-		if (!skb_new) {
-			rp->tx_errors++;
+		if (!skb_new)
 			goto out_drop;
-		}
 		kfree_skb(skb);
 		skb = skb_new;
 	} else
-- 
1.9.3
