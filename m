From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net 1/2] net/mlx4_core: Fix memory access error in mlx4_QUERY_DEV_CAP_wrapper()
Date: Thu,  6 Mar 2014 18:28:16 +0200
Message-ID: <1394123297-7878-2-git-send-email-amirv@mellanox.com>
References: <1394123297-7878-1-git-send-email-amirv@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>, Narendra_K@Dell.com,
	Sreekanth_Reddy@Dell.com, Amir Vadai <amirv@mellanox.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:56643 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751143AbaCFQ21 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2014 11:28:27 -0500
In-Reply-To: <1394123297-7878-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a regression introduced by [1]. outbox was accessed instead of
outbox->buf. Typo was copy-pasted to [2] and [3].

[1] - cc1ade9 mlx4_core: Disable memory windows for virtual functions
[2] - 4de6580 mlx4_core: Add support for steerable IB UD QPs
[3] - 7ffdf72 net/mlx4_core: Add basic support for TCP/IP offloads under
      tunneling

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 91b69ff..8726e34 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -859,7 +859,7 @@ int mlx4_QUERY_DEV_CAP_wrapper(struct mlx4_dev *dev, int slave,
 	MLX4_PUT(outbox->buf, field, QUERY_DEV_CAP_CQ_TS_SUPPORT_OFFSET);
 
 	/* For guests, disable vxlan tunneling */
-	MLX4_GET(field, outbox, QUERY_DEV_CAP_VXLAN);
+	MLX4_GET(field, outbox->buf, QUERY_DEV_CAP_VXLAN);
 	field &= 0xf7;
 	MLX4_PUT(outbox->buf, field, QUERY_DEV_CAP_VXLAN);
 
@@ -869,7 +869,7 @@ int mlx4_QUERY_DEV_CAP_wrapper(struct mlx4_dev *dev, int slave,
 	MLX4_PUT(outbox->buf, field, QUERY_DEV_CAP_BF_OFFSET);
 
 	/* For guests, disable mw type 2 */
-	MLX4_GET(bmme_flags, outbox, QUERY_DEV_CAP_BMME_FLAGS_OFFSET);
+	MLX4_GET(bmme_flags, outbox->buf, QUERY_DEV_CAP_BMME_FLAGS_OFFSET);
 	bmme_flags &= ~MLX4_BMME_FLAG_TYPE_2_WIN;
 	MLX4_PUT(outbox->buf, bmme_flags, QUERY_DEV_CAP_BMME_FLAGS_OFFSET);
 
@@ -883,7 +883,7 @@ int mlx4_QUERY_DEV_CAP_wrapper(struct mlx4_dev *dev, int slave,
 	}
 
 	/* turn off ipoib managed steering for guests */
-	MLX4_GET(field, outbox, QUERY_DEV_CAP_FLOW_STEERING_IPOIB_OFFSET);
+	MLX4_GET(field, outbox->buf, QUERY_DEV_CAP_FLOW_STEERING_IPOIB_OFFSET);
 	field &= ~0x80;
 	MLX4_PUT(outbox->buf, field, QUERY_DEV_CAP_FLOW_STEERING_IPOIB_OFFSET);
 
-- 
1.8.3.4
