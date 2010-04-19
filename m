From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCHv2 5/7] X25: Use identifiers for cyclades device to x25
 interface
Date: Tue, 20 Apr 2010 09:30:13 +1000
Message-ID: <1271719813.2802.86.camel@ibex>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:60119 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752884Ab0DSXfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 19:35:55 -0400
Received: by pwj9 with SMTP id 9so3835701pwj.19
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 16:35:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change magic numbers to identifiers for X25 interface.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 drivers/net/wan/cycx_x25.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wan/cycx_x25.c b/drivers/net/wan/cycx_x25.c
index cd8cb95..cf9e15f 100644
--- a/drivers/net/wan/cycx_x25.c
+++ b/drivers/net/wan/cycx_x25.c
@@ -634,11 +634,12 @@ static netdev_tx_t cycx_netdevice_hard_start_xmit(struct sk_buff *skb,
 	}
 	} else { /* chan->protocol == ETH_P_X25 */
 		switch (skb->data[0]) {
-		case 0: break;
-		case 1: /* Connect request */
+		case X25_IFACE_DATA:
+			break;
+		case X25_IFACE_CONNECT:
 			cycx_x25_chan_connect(dev);
 			goto free_packet;
-		case 2: /* Disconnect request */
+		case X25_IFACE_DISCONNECT:
 			cycx_x25_chan_disconnect(dev);
 			goto free_packet;
 	        default:
@@ -1406,7 +1407,8 @@ static void cycx_x25_set_chan_state(struct net_device *dev, u8 state)
 			reset_timer(dev);
 
 			if (chan->protocol == ETH_P_X25)
-				cycx_x25_chan_send_event(dev, 1);
+				cycx_x25_chan_send_event(dev,
+					X25_IFACE_CONNECT);
 
 			break;
 		case WAN_CONNECTING:
@@ -1424,7 +1426,8 @@ static void cycx_x25_set_chan_state(struct net_device *dev, u8 state)
 			}
 
 			if (chan->protocol == ETH_P_X25)
-				cycx_x25_chan_send_event(dev, 2);
+				cycx_x25_chan_send_event(dev,
+					X25_IFACE_DISCONNECT);
 
 			netif_wake_queue(dev);
 			break;
-- 
1.5.6.5



