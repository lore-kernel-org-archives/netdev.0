From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] isdn: remove some pointless conditionals before kfree_skb()
Date: Wed, 25 Feb 2009 18:12:09 +0800
Message-ID: <49A51979.80409@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Karsten Keil <kkeil@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50342 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753988AbZBYKMm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 05:12:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove some pointless conditionals before kfree_skb().

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 drivers/isdn/capi/capi.c    |    2 +-
 drivers/isdn/pcbit/layer2.c |    6 ++----
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 1b5bf87..3e468d2 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -277,7 +277,7 @@ static void capiminor_free(struct capiminor *mp)
 	list_del(&mp->list);
 	write_unlock_irqrestore(&capiminor_list_lock, flags);
 
-	if (mp->ttyskb) kfree_skb(mp->ttyskb);
+	kfree_skb(mp->ttyskb);
 	mp->ttyskb = NULL;
 	skb_queue_purge(&mp->inqueue);
 	skb_queue_purge(&mp->outqueue);
diff --git a/drivers/isdn/pcbit/layer2.c b/drivers/isdn/pcbit/layer2.c
index 5ba2a87..e075e8d 100644
--- a/drivers/isdn/pcbit/layer2.c
+++ b/drivers/isdn/pcbit/layer2.c
@@ -347,8 +347,7 @@ pcbit_receive(struct pcbit_dev *dev)
 		if (dev->read_frame) {
 			printk(KERN_DEBUG "pcbit_receive: Type 0 frame and read_frame != NULL\n");
 			/* discard previous queued frame */
-			if (dev->read_frame->skb)
-				kfree_skb(dev->read_frame->skb);
+			kfree_skb(dev->read_frame->skb);
 			kfree(dev->read_frame);
 			dev->read_frame = NULL;
 		}
@@ -601,8 +600,7 @@ pcbit_l2_err_recover(unsigned long data)
 	dev->w_busy = dev->r_busy = 1;
 
 	if (dev->read_frame) {
-		if (dev->read_frame->skb)
-			kfree_skb(dev->read_frame->skb);
+		kfree_skb(dev->read_frame->skb);
 		kfree(dev->read_frame);
 		dev->read_frame = NULL;
 	}
-- 
1.5.3.8




