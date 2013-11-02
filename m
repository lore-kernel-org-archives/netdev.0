From: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Subject: [PATCH net-next 12/13] driver: net: fix space before '(' and remove extra variable
Date: Sat,  2 Nov 2013 19:17:53 +0530
Message-ID: <1383400074-30555-13-git-send-email-govindarajulu90@gmail.com>
References: <1383400074-30555-1-git-send-email-govindarajulu90@gmail.com>
Cc: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
To: davem@davemloft.net, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	schwidefsky@de.ibm.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	IvDoorn@gmail.com, sbhatewara@vmware.com, samuel@sortiz.org,
	chas@cmf.nrl.navy.mil, roland@kernel.org, isdn@linux-pingi.de,
	jcliburn@gmail.com, benve@cisco.com, ssujith@cisco.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shahed.shaikh@qlogic.com, joe@perches.com, apw@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:51240 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754076Ab3KBNt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 09:49:29 -0400
In-Reply-To: <1383400074-30555-1-git-send-email-govindarajulu90@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
---
 drivers/net/ethernet/sgi/ioc3-eth.c | 4 +---
 drivers/net/usb/usbnet.c            | 2 +-
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sgi/ioc3-eth.c b/drivers/net/ethernet/sgi/ioc3-eth.c
index 6bd90f2..80dcfd9 100644
--- a/drivers/net/ethernet/sgi/ioc3-eth.c
+++ b/drivers/net/ethernet/sgi/ioc3-eth.c
@@ -851,13 +851,11 @@ static inline void ioc3_clean_rx_ring(struct ioc3_private *ip)
 
 static inline void ioc3_clean_tx_ring(struct ioc3_private *ip)
 {
-	struct sk_buff *skb;
 	int i;
 
 	for (i=0; i < 128; i++) {
-		skb = ip->tx_skbs[i];
+		dev_kfree_skb_any(ip->tx_skbs[i]);
 		ip->tx_skbs[i] = NULL;
-		dev_kfree_skb_any(skb);
 		ip->txr[i].cmd = 0;
 	}
 	ip->tx_pi = 0;
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index b37f812..bd18155 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1377,7 +1377,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 drop:
 		dev->net->stats.tx_dropped++;
 not_drop:
-		dev_kfree_skb_any (skb);
+		dev_kfree_skb_any(skb);
 		if (urb) {
 			kfree(urb->sg);
 			usb_free_urb(urb);
-- 
1.8.4.2
