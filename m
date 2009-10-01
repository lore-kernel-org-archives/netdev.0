From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 2/7] mlx4: Query for loopback support
Date: Thu, 01 Oct 2009 16:33:27 +0200
Message-ID: <4AC4BDB7.2040306@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:60193 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756405AbZJALfN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 07:35:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fw reports whether loopback capabilities are enabled

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/fw.c       |    3 +++
 drivers/net/mlx4/fw.h       |    1 +
 drivers/net/mlx4/main.c     |    1 +
 include/linux/mlx4/device.h |    1 +
 4 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/fw.c b/drivers/net/mlx4/fw.c
index cee199c..50f1ee8 100644
--- a/drivers/net/mlx4/fw.c
+++ b/drivers/net/mlx4/fw.c
@@ -176,6 +176,7 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 #define QUERY_DEV_CAP_MAX_GID_OFFSET		0x3b
 #define QUERY_DEV_CAP_RATE_SUPPORT_OFFSET	0x3c
 #define QUERY_DEV_CAP_MAX_PKEY_OFFSET		0x3f
+#define QUERY_DEV_CAP_ETH_UC_LOOPBACK_OFFSET	0x43
 #define QUERY_DEV_CAP_FLAGS_OFFSET		0x44
 #define QUERY_DEV_CAP_RSVD_UAR_OFFSET		0x48
 #define QUERY_DEV_CAP_UAR_SZ_OFFSET		0x49
@@ -266,6 +267,8 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev_cap->max_msg_sz = 1 << (field & 0x1f);
 	MLX4_GET(stat_rate, outbox, QUERY_DEV_CAP_RATE_SUPPORT_OFFSET);
 	dev_cap->stat_rate_support = stat_rate;
+	MLX4_GET(field, outbox, QUERY_DEV_CAP_ETH_UC_LOOPBACK_OFFSET);
+	dev_cap->loopback_support = field & 0x1;
 	MLX4_GET(dev_cap->flags, outbox, QUERY_DEV_CAP_FLAGS_OFFSET);
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_RSVD_UAR_OFFSET);
 	dev_cap->reserved_uars = field >> 4;
diff --git a/drivers/net/mlx4/fw.h b/drivers/net/mlx4/fw.h
index 526d7f3..2cc1ba5 100644
--- a/drivers/net/mlx4/fw.h
+++ b/drivers/net/mlx4/fw.h
@@ -74,6 +74,7 @@ struct mlx4_dev_cap {
 	u64 def_mac[MLX4_MAX_PORTS + 1];
 	u16 eth_mtu[MLX4_MAX_PORTS + 1];
 	u16 stat_rate_support;
+	int loopback_support;
 	u32 flags;
 	int reserved_uars;
 	int uar_size;
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 348b09b..e291a5c 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -220,6 +220,7 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev->caps.bmme_flags	     = dev_cap->bmme_flags;
 	dev->caps.reserved_lkey	     = dev_cap->reserved_lkey;
 	dev->caps.stat_rate_support  = dev_cap->stat_rate_support;
+	dev->caps.loopback_support   = dev_cap->loopback_support;
 	dev->caps.max_gso_sz	     = dev_cap->max_gso_sz;
 
 	dev->caps.log_num_macs  = log_num_mac;
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index e27a68d..7a423e7 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -228,6 +228,7 @@ struct mlx4_caps {
 	u32			bmme_flags;
 	u32			reserved_lkey;
 	u16			stat_rate_support;
+	int			loopback_support;
 	u8			port_width_cap[MLX4_MAX_PORTS + 1];
 	int			max_gso_sz;
 	int                     reserved_qps_cnt[MLX4_NUM_QP_REGION];
-- 
1.6.1.3

