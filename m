From: Michael Riesch <michael@riesch.at>
Subject: [patch] usbnet: add timestamping support
Date: Thu, 29 Sep 2011 16:06:26 +0200
Message-ID: <1317305186-32700-1-git-send-email-michael@riesch.at>
Cc: oneukum@suse.de, davem@davemloft.net,
	Michael Riesch <michael@riesch.at>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay02.ispgateway.de ([80.67.31.40]:45822 "EHLO
	smtprelay02.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014Ab1I2OGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 10:06:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to make USB-to-Ethernet-adapters (depending on usbnet) support
timestamping, the "skb_defer_rx_timestamp" and "skb_tx_timestamp" function
calls are added.

Signed-off-by: Michael Riesch <michael@riesch.at>
---
 drivers/net/usb/usbnet.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 2ab9b98..b57b57b 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -239,6 +239,10 @@ void usbnet_skb_return (struct usbnet *dev, struct sk_buff *skb)
 	netif_dbg(dev, rx_status, dev->net, "< rx, len %zu, type 0x%x\n",
 		  skb->len + sizeof (struct ethhdr), skb->protocol);
 	memset (skb->cb, 0, sizeof (struct skb_data));
+
+	if (skb_defer_rx_timestamp(skb))
+		return;
+
 	status = netif_rx (skb);
 	if (status != NET_RX_SUCCESS)
 		netif_dbg(dev, rx_err, dev->net,
@@ -1071,6 +1075,8 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 	unsigned long		flags;
 	int retval;
 
+	skb_tx_timestamp(skb);
+
 	// some devices want funky USB-level framing, for
 	// win32 driver (usually) and/or hardware quirks
 	if (info->tx_fixup) {
-- 
1.6.3.3
