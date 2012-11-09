From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next] virtio_net: use net_*_ratelimited() helpers
Date: Fri,  9 Nov 2012 11:47:28 +0800
Message-ID: <1352432848-16747-1-git-send-email-amwang@redhat.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	David Miller <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39906 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752084Ab2KIDrr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2012 22:47:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These can be converted to net_*_ratelimited().

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index cbf8b06..26c502e 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -212,8 +212,7 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 	 * the case of a broken device.
 	 */
 	if (unlikely(len > MAX_SKB_FRAGS * PAGE_SIZE)) {
-		if (net_ratelimit())
-			pr_debug("%s: too much data\n", skb->dev->name);
+		net_dbg_ratelimited("%s: too much data\n", skb->dev->name);
 		dev_kfree_skb(skb);
 		return NULL;
 	}
@@ -333,9 +332,8 @@ static void receive_buf(struct net_device *dev, void *buf, unsigned int len)
 			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
 			break;
 		default:
-			if (net_ratelimit())
-				printk(KERN_WARNING "%s: bad gso type %u.\n",
-				       dev->name, hdr->hdr.gso_type);
+			net_warn_ratelimited("%s: bad gso type %u.\n",
+					     dev->name, hdr->hdr.gso_type);
 			goto frame_err;
 		}
 
@@ -344,9 +342,7 @@ static void receive_buf(struct net_device *dev, void *buf, unsigned int len)
 
 		skb_shinfo(skb)->gso_size = hdr->hdr.gso_size;
 		if (skb_shinfo(skb)->gso_size == 0) {
-			if (net_ratelimit())
-				printk(KERN_WARNING "%s: zero gso size.\n",
-				       dev->name);
+			net_warn_ratelimited("%s: zero gso size.\n", dev->name);
 			goto frame_err;
 		}
 
