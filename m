From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 01/13] net/mlx5_en: Add missing check for memory allocation failure
Date: Thu,  4 Jun 2015 19:30:36 +0300
Message-ID: <1433435448-4937-2-git-send-email-ogerlitz@mellanox.com>
References: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Majd Dibbiny <majd@mellanox.com>,
	Haggai Abramonvsky <hagaya@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:47642 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932147AbbFDQbS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2015 12:31:18 -0400
In-Reply-To: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>

The patch afb736e9330a: "net/mlx5: Ethernet resource handling files"
from May 28, 2015, leads to the following static checker warning:

drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c:726 mlx5e_create_main_flow_table()
error: potential null dereference 'g'.  (kcalloc returns null)

Fixes: afb736e9330a ("net/mlx5: Ethernet resource handling files")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 .../ethernet/mellanox/mlx5/core/en_flow_table.c    |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c b/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
index 6feebda..120db80 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
@@ -722,6 +722,8 @@ static int mlx5e_create_main_flow_table(struct mlx5e_priv *priv)
 	u8 *dmac;
 
 	g = kcalloc(9, sizeof(*g), GFP_KERNEL);
+	if (!g)
+		return -ENOMEM;
 
 	g[0].log_sz = 2;
 	g[0].match_criteria_enable = MLX5_MATCH_OUTER_HEADERS;
-- 
1.7.1
