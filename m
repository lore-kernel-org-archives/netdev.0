From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 4/5] sky2: kfree_skb_any needed
Date: Fri, 01 Dec 2006 14:29:36 -0800
Message-ID: <20061201223219.873577984@osdl.org>
References: <20061201222931.730523290@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:16313 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1162128AbWLAWen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 17:34:43 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-napi-free.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is possible for the sky2 driver NAPI poll routine to be called with
IRQ's disabled if netpoll is trying to make space in the tx queue. This
is an obscure path, but if it happens, the kfree_skb needs to happen
via softirq. Calling kfree_skb with IRQ's disabled is a not allowed.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/sky2.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- netdev-2.6.orig/drivers/net/sky2.c	2006-12-01 14:23:30.000000000 -0800
+++ netdev-2.6/drivers/net/sky2.c	2006-12-01 14:23:33.000000000 -0800
@@ -1453,7 +1453,7 @@
 			if (unlikely(netif_msg_tx_done(sky2)))
 				printk(KERN_DEBUG "%s: tx done %u\n",
 				       dev->name, idx);
-			dev_kfree_skb(re->skb);
+			dev_kfree_skb_any(re->skb);
 		}
 
 		le->opcode = 0;	/* paranoia */

--
Stephen Hemminger <shemminger@osdl.org>

