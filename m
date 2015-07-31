From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net 1/3] gianfar: Fix warning when CONFIG_PM off
Date: Fri, 31 Jul 2015 18:38:31 +0300
Message-ID: <1438357113-8312-2-git-send-email-claudiu.manoil@freescale.com>
References: <1438357113-8312-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0111.outbound.protection.outlook.com ([157.56.110.111]:20439
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753958AbbGaPj0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Jul 2015 11:39:26 -0400
In-Reply-To: <1438357113-8312-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  CC      drivers/net/ethernet/freescale/gianfar.o
drivers/net/ethernet/freescale/gianfar.c:568:13: warning: 'lock_tx_qs'
defined but not used [-Wunused-function]
 static void lock_tx_qs(struct gfar_private *priv)
             ^
drivers/net/ethernet/freescale/gianfar.c:576:13: warning: 'unlock_tx_qs'
defined but not used [-Wunused-function]
 static void unlock_tx_qs(struct gfar_private *priv)
             ^

Reported-by: Scott Wood <scottwood@freescale.com>
Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index ff87502..caad327 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -565,6 +565,7 @@ static void gfar_ints_enable(struct gfar_private *priv)
 	}
 }
 
+#ifdef CONFIG_PM
 static void lock_tx_qs(struct gfar_private *priv)
 {
 	int i;
@@ -580,6 +581,7 @@ static void unlock_tx_qs(struct gfar_private *priv)
 	for (i = 0; i < priv->num_tx_queues; i++)
 		spin_unlock(&priv->tx_queue[i]->txlock);
 }
+#endif
 
 static int gfar_alloc_tx_queues(struct gfar_private *priv)
 {
-- 
1.7.11.7
