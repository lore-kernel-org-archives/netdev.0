From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 1/7] net/mlx4_core: Fix wrong reading of reserved_eqs
Date: Thu, 13 Nov 2014 14:45:27 +0200
Message-ID: <1415882733-3084-2-git-send-email-ogerlitz@mellanox.com>
References: <1415882733-3084-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46572 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932705AbaKMMpm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Nov 2014 07:45:42 -0500
In-Reply-To: <1415882733-3084-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

We mistakenly read the reserved_eqs field as a standard
numeric value rather than a log2 value.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index d6dba77..9051b36 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -611,7 +611,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_MAX_MPT_OFFSET);
 	dev_cap->max_mpts = 1 << (field & 0x3f);
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_RSVD_EQ_OFFSET);
-	dev_cap->reserved_eqs = field & 0xf;
+	dev_cap->reserved_eqs = 1 << (field & 0xf);
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_MAX_EQ_OFFSET);
 	dev_cap->max_eqs = 1 << (field & 0xf);
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_RSVD_MTT_OFFSET);
-- 
1.7.1
