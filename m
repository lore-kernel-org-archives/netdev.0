From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [RFC net-next 02/14] Fix mellanox/mlx4
Date: Tue, 19 Jun 2012 18:13:56 +0300
Message-ID: <1340118848-30978-3-git-send-email-yuvalmin@broadcom.com>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Or Gerlitz" <ogerlitz@mellanox.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3914 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751599Ab2FSPQS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:16:18 -0400
In-Reply-To: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Cc: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index ee6f4fe..57840ad 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -41,6 +41,7 @@
 #include <linux/slab.h>
 #include <linux/io-mapping.h>
 #include <linux/delay.h>
+#include <linux/etherdevice.h>
 
 #include <linux/mlx4/device.h>
 #include <linux/mlx4/doorbell.h>
@@ -1538,8 +1539,9 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct msix_entry *entries;
+	int ncpu = min_t(int, num_online_cpus(), DEFAULT_MAX_NUM_RSS_QUEUES);
 	int nreq = min_t(int, dev->caps.num_ports *
-			 min_t(int, num_online_cpus() + 1, MAX_MSIX_P_PORT)
+			 min_t(int, ncpu + 1, MAX_MSIX_P_PORT)
 				+ MSIX_LEGACY_SZ, MAX_MSIX);
 	int err;
 	int i;
-- 
1.7.9.rc2
