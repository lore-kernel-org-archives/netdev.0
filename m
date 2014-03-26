From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next 1/6] at86rf230: use dev_* print functions
Date: Wed, 26 Mar 2014 15:11:52 +0100
Message-ID: <1395843117-16494-2-git-send-email-alex.aring@gmail.com>
References: <1395843117-16494-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f43.google.com ([209.85.214.43]:59680 "EHLO
	mail-bk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803AbaCZOMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 10:12:34 -0400
In-Reply-To: <1395843117-16494-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the pr_* functions and replace it with the dev_*
print functions.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 drivers/net/ieee802154/at86rf230.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index e8004ef..df290a5 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -557,11 +557,12 @@ at86rf230_state(struct ieee802154_dev *dev, int state)
 	    (desired_status == STATE_RX_AACK_ON && val == STATE_BUSY_RX_AACK))
 		return 0;
 
-	pr_err("unexpected state change: %d, asked for %d\n", val, state);
+	dev_err(&lp->spi->dev, "unexpected state change: %d, asked for %d\n",
+		val, state);
 	return -EBUSY;
 
 err:
-	pr_err("error: %d\n", rc);
+	dev_err(&lp->spi->dev, "error: %d\n", rc);
 	return rc;
 }
 
@@ -699,7 +700,7 @@ at86rf230_xmit(struct ieee802154_dev *dev, struct sk_buff *skb)
 err_rx:
 	at86rf230_start(dev);
 err:
-	pr_err("error: %d\n", rc);
+	dev_err(&lp->spi->dev, "error: %d\n", rc);
 
 	spin_lock_irqsave(&lp->lock, flags);
 	lp->is_tx = 0;
@@ -732,7 +733,7 @@ static int at86rf230_rx(struct at86rf230_local *lp)
 
 	return 0;
 err:
-	pr_debug("received frame is too small\n");
+	dev_dbg(&lp->spi->dev, "received frame is too small\n");
 
 	kfree_skb(skb);
 	return -EINVAL;
-- 
1.9.1
