From: Himanshu Jha <himanshujha199640@gmail.com>
Subject: [PATCH] net: bcm63xx_enet: Use setup_timer and mod_timer
Date: Sun, 24 Sep 2017 17:41:24 +0530
Message-ID: <1506255084-10943-1-git-send-email-himanshujha199640@gmail.com>
Cc: bcm-kernel-feedback-list@broadcom.com, davem@davemloft.net,
        arnd@arndb.de, yamada.masahiro@socionext.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org,
        Himanshu Jha <himanshujha199640@gmail.com>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use setup_timer and mod_timer API instead of structure assignments.

This is done using Coccinelle and semantic patch used
for this as follows:

@@
expression x,y,z,a,b;
@@

-init_timer (&x);
+setup_timer (&x, y, z);
+mod_timer (&a, b);
-x.function = y;
-x.data = z;
-x.expires = b;
-add_timer(&a);

Signed-off-by: Himanshu Jha <himanshujha199640@gmail.com>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index f8bbbbf..c6221f0 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -2331,11 +2331,8 @@ static int bcm_enetsw_open(struct net_device *dev)
 	}
 
 	/* start phy polling timer */
-	init_timer(&priv->swphy_poll);
-	priv->swphy_poll.function = swphy_poll_timer;
-	priv->swphy_poll.data = (unsigned long)priv;
-	priv->swphy_poll.expires = jiffies;
-	add_timer(&priv->swphy_poll);
+	setup_timer(&priv->swphy_poll, swphy_poll_timer, (unsigned long)priv);
+	mod_timer(&priv->swphy_poll, jiffies);
 	return 0;
 
 out:
-- 
2.7.4
