From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 04/13] net/mlx5_core: Check the return bitmask when querying ISSI
Date: Thu,  4 Jun 2015 19:30:39 +0300
Message-ID: <1433435448-4937-5-git-send-email-ogerlitz@mellanox.com>
References: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Majd Dibbiny <majd@mellanox.com>,
	Haggai Abramonvsky <hagaya@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:47748 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932210AbbFDQbd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2015 12:31:33 -0400
In-Reply-To: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haggai Abramonvsky <hagaya@mellanox.com>

The determination of the supported ISSI versions should be conditioned
on the returned mask, and not only on the return status of the query
ISSI command, fix that.

Signed-off-by: Haggai Abramovsky <hagaya@mellanox.com>
Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 2510fed..11c7216 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -654,7 +654,7 @@ static int mlx5_core_set_issi(struct mlx5_core_dev *dev)
 		dev->issi = 1;
 
 		return 0;
-	} else if (sup_issi & (1 << 0)) {
+	} else if (sup_issi & (1 << 0) || !sup_issi) {
 		return 0;
 	}
 
-- 
1.7.1
