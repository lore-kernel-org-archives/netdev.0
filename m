From: Patrick McHardy <kaber@trash.net>
Subject: net: fix network drivers ndo_start_xmit() return values (part 6)
Date: Fri, 12 Jun 2009 17:20:01 +0200
Message-ID: <4A327221.5040306@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050409060001010900080801"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47329 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751918AbZFLPUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 11:20:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050409060001010900080801
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

A single hamradio driver that appears to be unmaintained.


--------------050409060001010900080801
Content-Type: text/x-patch;
 name="06.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="06.diff"

commit 2a3f9e1eb41a809168916bd70d3c24707d89a34b
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Jun 12 17:19:15 2009 +0200

    net: fix network drivers ndo_start_xmit() return values (part 6)
    
    Fix up hamradio drivers that return an errno value to dev_queue_xmit(), causing
    it to print a warning an free the skb.
    
    - bpqether: skb is freed: use after free
    
    Compile tested only.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index d509b37..5105548 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -274,7 +274,7 @@ static int bpq_xmit(struct sk_buff *skb, struct net_device *dev)
 		if ((newskb = skb_realloc_headroom(skb, AX25_BPQ_HEADER_LEN)) == NULL) {
 			printk(KERN_WARNING "bpqether: out of memory\n");
 			kfree_skb(skb);
-			return -ENOMEM;
+			return NETDEV_TX_OK;
 		}
 
 		if (skb->sk != NULL)
@@ -294,7 +294,7 @@ static int bpq_xmit(struct sk_buff *skb, struct net_device *dev)
 	if ((dev = bpq_get_ether_dev(dev)) == NULL) {
 		dev->stats.tx_dropped++;
 		kfree_skb(skb);
-		return -ENODEV;
+		return NETDEV_TX_OK;
 	}
 
 	skb->protocol = ax25_type_trans(skb, dev);

--------------050409060001010900080801--
