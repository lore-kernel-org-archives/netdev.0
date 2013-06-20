From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 11/11] net/mlx4_core: Fail device init if num_vfs is negative
Date: Thu, 20 Jun 2013 22:40:22 +0300
Message-ID: <1371757222-21412-12-git-send-email-amirv@mellanox.com>
References: <1371757222-21412-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.com>,
	Vladimir Sokolovsky <vlad@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:38525 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030297Ab3FTTkn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 15:40:43 -0400
In-Reply-To: <1371757222-21412-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.com>

Should not allow negative num_vfs

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.com>
Signed-off-by: Vladimir Sokolovsky <vlad@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 81e4529..56160a2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2077,6 +2077,11 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data)
 		       num_vfs, MLX4_MAX_NUM_VF);
 		return -EINVAL;
 	}
+
+	if (num_vfs < 0) {
+		pr_err("num_vfs module parameter cannot be negative\n");
+		return -EINVAL;
+	}
 	/*
 	 * Check for BARs.
 	 */
-- 
1.8.3.251.g1462b67
