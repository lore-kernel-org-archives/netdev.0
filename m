From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/4] net: bcmgenet: remove unused spinlock member
Date: Thu, 20 Mar 2014 10:53:20 -0700
Message-ID: <1395338003-17982-2-git-send-email-f.fainelli@gmail.com>
References: <1395338003-17982-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:53455 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759376AbaCTRxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 13:53:34 -0400
Received: by mail-pa0-f51.google.com with SMTP id kq14so1279037pab.10
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 10:53:34 -0700 (PDT)
In-Reply-To: <1395338003-17982-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The spinlock cookie in bcmgenet_priv is never used, get rid of it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 1 -
 drivers/net/ethernet/broadcom/genet/bcmgenet.h | 1 -
 2 files changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 72ce6e8115fa..e836c4c35399 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2498,7 +2498,6 @@ static int bcmgenet_probe(struct platform_device *pdev)
 
 	bcmgenet_set_hw_params(priv);
 
-	spin_lock_init(&priv->lock);
 	/* Mii wait queue */
 	init_waitqueue_head(&priv->wq);
 	/* Always use RX_BUF_LENGTH (2KB) buffer for all chips */
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index a6758adefaab..0f117105fed1 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -523,7 +523,6 @@ struct bcmgenet_priv {
 	void __iomem *base;
 	enum bcmgenet_version version;
 	struct net_device *dev;
-	spinlock_t lock;
 	u32 int0_mask;
 	u32 int1_mask;
 
-- 
1.8.3.2
