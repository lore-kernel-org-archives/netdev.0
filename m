From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 1/8] net/mlx4_core: Disable HW timestamping for VFs
Date: Thu, 25 Apr 2013 18:22:23 +0300
Message-ID: <1366903350-9096-2-git-send-email-ogerlitz@mellanox.com>
References: <1366903350-9096-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog121.obsmtp.com ([207.126.144.151]:50299 "EHLO
	eu1sys200aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758809Ab3DYPWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 11:22:44 -0400
In-Reply-To: <1366903350-9096-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>

Disable timestamp capability on virtual functions.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 6776c25..1f6c3e9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -784,6 +784,11 @@ int mlx4_QUERY_DEV_CAP_wrapper(struct mlx4_dev *dev, int slave,
 	flags &= ~MLX4_DEV_CAP_FLAG_MEM_WINDOW;
 	MLX4_PUT(outbox->buf, flags, QUERY_DEV_CAP_EXT_FLAGS_OFFSET);
 
+	/* For guests, disable timestamp */
+	MLX4_GET(field, outbox->buf, QUERY_DEV_CAP_CQ_TS_SUPPORT_OFFSET);
+	field &= 0x7f;
+	MLX4_PUT(outbox->buf, field, QUERY_DEV_CAP_CQ_TS_SUPPORT_OFFSET);
+
 	/* For guests, report Blueflame disabled */
 	MLX4_GET(field, outbox->buf, QUERY_DEV_CAP_BF_OFFSET);
 	field &= 0x7f;
-- 
1.7.1
