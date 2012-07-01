From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 02/11] mlx4: set maximal number of default RSS
 queues
Date: Sun, 1 Jul 2012 16:18:51 +0300
Message-ID: <1341148740-7375-3-git-send-email-yuvalmin@broadcom.com>
References: <1341148740-7375-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Or Gerlitz" <ogerlitz@mellanox.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3426 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932329Ab2GANUh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jul 2012 09:20:37 -0400
In-Reply-To: <1341148740-7375-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Cc: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index a0313de..14d9c76 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -41,6 +41,7 @@
 #include <linux/slab.h>
 #include <linux/io-mapping.h>
 #include <linux/delay.h>
+#include <linux/netdevice.h>
 
 #include <linux/mlx4/device.h>
 #include <linux/mlx4/doorbell.h>
@@ -1539,8 +1540,8 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct msix_entry *entries;
 	int nreq = min_t(int, dev->caps.num_ports *
-			 min_t(int, num_online_cpus() + 1, MAX_MSIX_P_PORT)
-				+ MSIX_LEGACY_SZ, MAX_MSIX);
+			 min_t(int, netif_get_num_default_rss_queues() + 1,
+			       MAX_MSIX_P_PORT) + MSIX_LEGACY_SZ, MAX_MSIX);
 	int err;
 	int i;
 
-- 
1.7.9.rc2
