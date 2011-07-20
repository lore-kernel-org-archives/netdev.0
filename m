From: Dan Carpenter <error27@gmail.com>
Subject: [patch] skbuff: use kfree_skb() instead of kfree()
Date: Wed, 20 Jul 2011 10:23:43 +0300
Message-ID: <20110720072343.GF6445@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Shirley Ma <xma@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39743 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981Ab1GTHZi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 03:25:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"n" was allocated with alloc_skb() so we should free it with
kfree_skb() instead of regular kfree().

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d220119..cc0c6f0 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -799,7 +799,7 @@ struct sk_buff *pskb_copy(struct sk_buff *skb, gfp_t gfp_mask)
 
 		if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
 			if (skb_copy_ubufs(skb, gfp_mask)) {
-				kfree(n);
+				kfree_skb(n);
 				goto out;
 			}
 			skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
