From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCH 6/6] X25: Use identifiers for hdlc x25 device to x25
 interface
Date: Sun, 18 Apr 2010 19:53:49 +1000
Message-ID: <1271584429.6280.435.camel@ibex>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:47339 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756503Ab0DRJxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Apr 2010 05:53:54 -0400
Received: by pva18 with SMTP id 18so2510920pva.19
        for <netdev@vger.kernel.org>; Sun, 18 Apr 2010 02:53:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Change magic numbers to identifiers for X25 interface.
Note, x25_connect_disconnect 'reason' appears unimplemented?
Have left that part as is for the moment.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 drivers/net/wan/hdlc_x25.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wan/hdlc_x25.c b/drivers/net/wan/hdlc_x25.c
index c7adbb7..70527e5 100644
--- a/drivers/net/wan/hdlc_x25.c
+++ b/drivers/net/wan/hdlc_x25.c
@@ -49,14 +49,14 @@ static void x25_connect_disconnect(struct net_device *dev, int reason, int code)
 
 static void x25_connected(struct net_device *dev, int reason)
 {
-	x25_connect_disconnect(dev, reason, 1);
+	x25_connect_disconnect(dev, reason, X25_IFACE_CONNECT);
 }
 
 
 
 static void x25_disconnected(struct net_device *dev, int reason)
 {
-	x25_connect_disconnect(dev, reason, 2);
+	x25_connect_disconnect(dev, reason, X25_IFACE_DISCONNECT);
 }
 
 
@@ -71,7 +71,7 @@ static int x25_data_indication(struct net_device *dev, struct sk_buff *skb)
 		return NET_RX_DROP;
 
 	ptr  = skb->data;
-	*ptr = 0;
+	*ptr = X25_IFACE_DATA;
 
 	skb->protocol = x25_type_trans(skb, dev);
 	return netif_rx(skb);
@@ -94,13 +94,13 @@ static netdev_tx_t x25_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* X.25 to LAPB */
 	switch (skb->data[0]) {
-	case 0:		/* Data to be transmitted */
+	case X25_IFACE_DATA:	/* Data to be transmitted */
 		skb_pull(skb, 1);
 		if ((result = lapb_data_request(dev, skb)) != LAPB_OK)
 			dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
 
-	case 1:
+	case X25_IFACE_CONNECT:
 		if ((result = lapb_connect_request(dev))!= LAPB_OK) {
 			if (result == LAPB_CONNECTED)
 				/* Send connect confirm. msg to level 3 */
@@ -112,7 +112,7 @@ static netdev_tx_t x25_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 		break;
 
-	case 2:
+	case X25_IFACE_DISCONNECT:
 		if ((result = lapb_disconnect_request(dev)) != LAPB_OK) {
 			if (result == LAPB_NOTCONNECTED)
 				/* Send disconnect confirm. msg to level 3 */
-- 
1.5.6.5


