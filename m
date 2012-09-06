From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: [PATCH net 5/5] net/mlx4_core: Return the error value in case of command initialization failure
Date: Thu,  6 Sep 2012 11:50:52 +0300
Message-ID: <1346921452-2035-6-git-send-email-yevgenyp@mellanox.com>
References: <1346921452-2035-1-git-send-email-yevgenyp@mellanox.com>
Cc: netdev@vger.kernel.org, Eugenia Emantayev <eugenia@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:34005 "HELO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756759Ab2IFIvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 04:51:36 -0400
In-Reply-To: <1346921452-2035-1-git-send-email-yevgenyp@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

If mlx4_cmd_init() failed, the init_one function returned
success, although no resources were opened.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 0fadac5..2f816c6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -1997,7 +1997,8 @@ static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 	}
 
 slave_start:
-	if (mlx4_cmd_init(dev)) {
+	err = mlx4_cmd_init(dev);
+	if (err) {
 		mlx4_err(dev, "Failed to init command interface, aborting.\n");
 		goto err_sriov;
 	}
-- 
1.7.7
