From: <Woojung.Huh@microchip.com>
Subject: [PATCH net-next 2/2] lan78xx: Remove BUG_ON()
Date: Tue, 11 Aug 2015 15:23:33 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D53FB03@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <dan.carpenter@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:63804 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965139AbbHKPXe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 11:23:34 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removing BUG_ON()

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/usb/lan78xx.c | 31 -------------------------------
 1 file changed, 31 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 3a6a4c1..39364a4 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -291,8 +291,6 @@ static int lan78xx_read_reg(struct lan78xx_net *dev, u32 index, u32 *data)
 	u32 *buf = kmalloc(sizeof(u32), GFP_KERNEL);
 	int ret;
 
-	BUG_ON(!dev);
-
 	if (!buf)
 		return -ENOMEM;
 
@@ -319,8 +317,6 @@ static int lan78xx_write_reg(struct lan78xx_net *dev, u32 index, u32 data)
 	u32 *buf = kmalloc(sizeof(u32), GFP_KERNEL);
 	int ret;
 
-	BUG_ON(!dev);
-
 	if (!buf)
 		return -ENOMEM;
 
@@ -351,10 +347,6 @@ static int lan78xx_read_stats(struct lan78xx_net *dev,
 	u32 *src;
 	u32 *dst;
 
-	BUG_ON(!dev);
-	BUG_ON(!data);
-	BUG_ON(sizeof(struct lan78xx_statstage) != 0xBC);
-
 	stats = kmalloc(sizeof(*stats), GFP_KERNEL);
 	if (!stats)
 		return -ENOMEM;
@@ -687,9 +679,6 @@ static int lan78xx_read_raw_eeprom(struct lan78xx_net *dev, u32 offset,
 	u32 val;
 	int i, ret;
 
-	BUG_ON(!dev);
-	BUG_ON(!data);
-
 	ret = lan78xx_eeprom_confirm_not_busy(dev);
 	if (ret)
 		return ret;
@@ -737,9 +726,6 @@ static int lan78xx_write_raw_eeprom(struct lan78xx_net *dev, u32 offset,
 	u32 val;
 	int i, ret;
 
-	BUG_ON(!dev);
-	BUG_ON(!data);
-
 	ret = lan78xx_eeprom_confirm_not_busy(dev);
 	if (ret)
 		return ret;
@@ -2220,20 +2206,10 @@ static enum skb_state defer_bh(struct lan78xx_net *dev, struct sk_buff *skb,
 	spin_lock_irqsave(&list->lock, flags);
 	old_state = entry->state;
 	entry->state = state;
-	if (!list->prev)
-		BUG_ON(!list->prev);
-	if (!list->next)
-		BUG_ON(!list->next);
-	if (!skb->prev || !skb->next)
-		BUG_ON(true);
 
 	__skb_unlink(skb, list);
 	spin_unlock(&list->lock);
 	spin_lock(&dev->done.lock);
-	if (!dev->done.prev)
-		BUG_ON(!dev->done.prev);
-	if (!dev->done.next)
-		BUG_ON(!dev->done.next);
 
 	__skb_queue_tail(&dev->done, skb);
 	if (skb_queue_len(&dev->done) == 1)
@@ -2749,8 +2725,6 @@ static void lan78xx_tx_bh(struct lan78xx_net *dev)
 			memcpy(skb->data + pos, skb2->data, skb2->len);
 			pos += roundup(skb2->len, sizeof(u32));
 			dev_kfree_skb(skb2);
-		} else {
-			BUG_ON(true);
 		}
 	}
 
@@ -2859,11 +2833,6 @@ static void lan78xx_bh(unsigned long param)
 	struct sk_buff *skb;
 	struct skb_data *entry;
 
-	if (!dev->done.prev)
-		BUG_ON(!dev->done.prev);
-	if (!dev->done.next)
-		BUG_ON(!dev->done.next);
-
 	while ((skb = skb_dequeue(&dev->done))) {
 		entry = (struct skb_data *)(skb->cb);
 		switch (entry->state) {
-- 
2.1.4
