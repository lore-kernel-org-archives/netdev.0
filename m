From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: ns83820: use dev_kfree_skb_irq instead of kfree_skb
Date: Sat, 22 Oct 2016 14:34:55 +0000
Message-ID: <1477146895-32591-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Javier Martinez Canillas <javier@osg.samsung.com>,
        Jarod Wilson <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36660 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936000AbcJVOfH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2016 10:35:07 -0400
Received: by mail-pf0-f193.google.com with SMTP id r16so11483609pfg.3
        for <netdev@vger.kernel.org>; Sat, 22 Oct 2016 07:35:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

It is not allowed to call kfree_skb() from hardware interrupt
context or with interrupts being disabled, spin_lock_irqsave()
make sure always in irq disable context. So the kfree_skb()
should be replaced with dev_kfree_skb_irq().

This is detected by Coccinelle semantic patch.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/natsemi/ns83820.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
index a34631e..93c4bdc 100644
--- a/drivers/net/ethernet/natsemi/ns83820.c
+++ b/drivers/net/ethernet/natsemi/ns83820.c
@@ -919,7 +919,7 @@ static void rx_irq(struct net_device *ndev)
 				ndev->stats.rx_dropped++;
 			}
 		} else {
-			kfree_skb(skb);
+			dev_kfree_skb_irq(skb);
 		}
 
 		nr++;
