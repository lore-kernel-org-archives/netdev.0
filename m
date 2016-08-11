From: Wolfram Sang <wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>
Subject: [PATCH 04/16] net: can: usb: kvaser_usb: don't print error when allocating urb fails
Date: Thu, 11 Aug 2016 23:05:23 +0200
Message-ID: <1470949539-25392-5-git-send-email-wsa-dev@sang-engineering.com>
References: <1470949539-25392-1-git-send-email-wsa-dev@sang-engineering.com>
Cc: Wolfram Sang <wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1470949539-25392-1-git-send-email-wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

kmalloc will print enough information in case of failure.

Signed-off-by: Wolfram Sang <wsa-dev-jBu1N2QxHDJrcw3mvpCnnVaTQe2KTcn/@public.gmane.org>
---
 drivers/net/can/usb/kvaser_usb.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index 6f1f3b675ff553..d51e0c401b483c 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -787,10 +787,8 @@ static int kvaser_usb_simple_msg_async(struct kvaser_usb_net_priv *priv,
 	int err;
 
 	urb = usb_alloc_urb(0, GFP_ATOMIC);
-	if (!urb) {
-		netdev_err(netdev, "No memory left for URBs\n");
+	if (!urb)
 		return -ENOMEM;
-	}
 
 	buf = kmalloc(sizeof(struct kvaser_msg), GFP_ATOMIC);
 	if (!buf) {
@@ -1393,8 +1391,6 @@ static int kvaser_usb_setup_rx_urbs(struct kvaser_usb *dev)
 
 		urb = usb_alloc_urb(0, GFP_KERNEL);
 		if (!urb) {
-			dev_warn(dev->udev->dev.parent,
-				 "No memory left for URBs\n");
 			err = -ENOMEM;
 			break;
 		}
@@ -1670,7 +1666,6 @@ static netdev_tx_t kvaser_usb_start_xmit(struct sk_buff *skb,
 
 	urb = usb_alloc_urb(0, GFP_ATOMIC);
 	if (!urb) {
-		netdev_err(netdev, "No memory left for URBs\n");
 		stats->tx_dropped++;
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
-- 
2.8.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
