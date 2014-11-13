From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/7] net/mlx4_core: Use correct variable type for mlx4_slave_cap
Date: Thu, 13 Nov 2014 14:45:28 +0200
Message-ID: <1415882733-3084-3-git-send-email-ogerlitz@mellanox.com>
References: <1415882733-3084-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:39846 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932713AbaKMMpm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Nov 2014 07:45:42 -0500
In-Reply-To: <1415882733-3084-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

We've used an incorrect type for the loop counter and the
mlx4_QUERY_FUNC_CAP function. The current input modifier
is either a port or a boolean.
Since the number of ports is always a positive value < 255,
we should use u8 instead of an integer with casting.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c   |    2 +-
 drivers/net/ethernet/mellanox/mlx4/fw.h   |    2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c |    4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 9051b36..f1a6718 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -335,7 +335,7 @@ int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 	return err;
 }
 
-int mlx4_QUERY_FUNC_CAP(struct mlx4_dev *dev, u32 gen_or_port,
+int mlx4_QUERY_FUNC_CAP(struct mlx4_dev *dev, u8 gen_or_port,
 			struct mlx4_func_cap *func_cap)
 {
 	struct mlx4_cmd_mailbox *mailbox;
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
index 9b835ae..694557e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.h
@@ -204,7 +204,7 @@ struct mlx4_set_ib_param {
 };
 
 int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap);
-int mlx4_QUERY_FUNC_CAP(struct mlx4_dev *dev, u32 gen_or_port,
+int mlx4_QUERY_FUNC_CAP(struct mlx4_dev *dev, u8 gen_or_port,
 			struct mlx4_func_cap *func_cap);
 int mlx4_QUERY_FUNC_CAP_wrapper(struct mlx4_dev *dev, int slave,
 				struct mlx4_vhcr *vhcr,
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 2f6ba42..71f1f3b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -631,7 +631,7 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 	struct mlx4_dev_cap	   dev_cap;
 	struct mlx4_func_cap	   func_cap;
 	struct mlx4_init_hca_param hca_param;
-	int			   i;
+	u8			   i;
 
 	memset(&hca_param, 0, sizeof(hca_param));
 	err = mlx4_QUERY_HCA(dev, &hca_param);
@@ -732,7 +732,7 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 	}
 
 	for (i = 1; i <= dev->caps.num_ports; ++i) {
-		err = mlx4_QUERY_FUNC_CAP(dev, (u32) i, &func_cap);
+		err = mlx4_QUERY_FUNC_CAP(dev, i, &func_cap);
 		if (err) {
 			mlx4_err(dev, "QUERY_FUNC_CAP port command failed for port %d, aborting (%d)\n",
 				 i, err);
-- 
1.7.1
