From: Tom Herbert <therbert@google.com>
Subject: [PATCH] bnx2x: Fix check to get RX hash
Date: Wed, 5 May 2010 20:57:16 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1005052054590.27018@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:42214 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639Ab0EFD5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 23:57:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flag used in check to get rxhash out of the descriptor is incorrect one.
Fix to use the proper features flag.


Signed-off-by: Tom Herbert <therbert@google.com>
---
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index f706ed1..2bc35c7 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1726,7 +1726,7 @@ reuse_rx:
 
 			skb->protocol = eth_type_trans(skb, bp->dev);
 
-			if ((bp->dev->features & ETH_FLAG_RXHASH) &&
+			if ((bp->dev->features & NETIF_F_RXHASH) &&
 			    (cqe_fp_status_flags &
 			     ETH_FAST_PATH_RX_CQE_RSS_HASH_FLG))
 				skb->rxhash = le32_to_cpu(
