From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 10/10] net/mlx4_core: Fail device init if num_vfs is negative
Date: Tue, 25 Jun 2013 12:09:38 +0300
Message-ID: <1372151378-21468-11-git-send-email-ogerlitz@mellanox.com>
References: <1372151378-21468-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Jack Morgenstein <jackm@dev.mellanox.com>,
	Vladimir Sokolovsky <vlad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40737 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751904Ab3FYJKZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 05:10:25 -0400
In-Reply-To: <1372151378-21468-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.com>

Should not allow negative num_vfs

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.com>
Signed-off-by: Vladimir Sokolovsky <vlad@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

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
1.7.1
