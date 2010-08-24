From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 06/14] mlx4_en: Reporting link state with KERN_INFO
Date: Tue, 24 Aug 2010 16:46:01 +0300
Message-ID: <4C73CD19.5040601@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:50090 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755262Ab0HXNqE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Aug 2010 09:46:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |    4 ++--
 drivers/net/mlx4/mlx4_en.h   |    2 ++
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 068e572..92fd1ff 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -528,10 +528,10 @@ static void mlx4_en_linkstate(struct work_struct *work)
 	 * report to system log */
 	if (priv->last_link_state != linkstate) {
 		if (linkstate == MLX4_DEV_EVENT_PORT_DOWN) {
-			en_dbg(LINK, priv, "Link Down\n");
+			en_info(priv, "Link Down\n");
 			netif_carrier_off(priv->dev);
 		} else {
-			en_dbg(LINK, priv, "Link Up\n");
+			en_info(priv, "Link Up\n");
 			netif_carrier_on(priv->dev);
 		}
 	}
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index f8f3ad3..747f04a 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -555,6 +555,8 @@ do {								\
 	en_print(KERN_WARNING, priv, format, ##arg)
 #define en_err(priv, format, arg...)			\
 	en_print(KERN_ERR, priv, format, ##arg)
+#define en_info(priv, format, arg...)			\
+	en_print(KERN_INFO, priv, format, ## arg)
 
 #define mlx4_err(mdev, format, arg...)			\
 	pr_err("%s %s: " format, DRV_NAME,		\
-- 
1.6.1.3


