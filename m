From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH 2/2] smsc95xx: strip ethernet fcs (crc) on receive path
Date: Wed, 13 May 2009 22:10:41 +0200
Message-ID: <1242245441-15027-1-git-send-email-jacmet@sunsite.dk>
Cc: Peter Korsgaard <jacmet@sunsite.dk>
To: netdev@vger.kernel.org, steve.glendinning@smsc.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:61988 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756914AbZEMUKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 16:10:42 -0400
Received: by ewy24 with SMTP id 24so1079086ewy.37
        for <netdev@vger.kernel.org>; Wed, 13 May 2009 13:10:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The smsc95xx driver was forwarding the trailing fcs on received frames
up the stack leading to confusion in tcpdump.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 drivers/net/usb/smsc95xx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 5a72833..89a91f8 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1134,7 +1134,7 @@ static int smsc95xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 			if (skb->len == size) {
 				if (pdata->use_rx_csum)
 					smsc95xx_rx_csum_offload(skb);
-
+				skb_trim(skb, skb->len - 4); /* remove fcs */
 				skb->truesize = size + sizeof(struct sk_buff);
 
 				return 1;
@@ -1152,7 +1152,7 @@ static int smsc95xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 
 			if (pdata->use_rx_csum)
 				smsc95xx_rx_csum_offload(ax_skb);
-
+			skb_trim(ax_skb, ax_skb->len - 4); /* remove fcs */
 			ax_skb->truesize = size + sizeof(struct sk_buff);
 
 			usbnet_skb_return(dev, ax_skb);
-- 
1.6.2

