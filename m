From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 02/15] net/mlx5: Fix version printout in case of health issue
Date: Fri, 20 Jan 2017 00:38:55 +0200
Message-ID: <20170119223908.15924-3-saeedm@mellanox.com>
References: <20170119223908.15924-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eli Cohen <eli@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59328 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751638AbdASWki (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 17:40:38 -0500
In-Reply-To: <20170119223908.15924-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

Firmware representation of the firmware version on the health buffer has
changed for newer device. The representation in the initialization
segment does not and will not change. In addition, we print the health
buffer firmware version as a raw hex number.

Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/health.c | 20 +++-----------------
 1 file changed, 3 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/health.c b/drivers/net/ethernet/mellanox/mlx5/core/health.c
index 5bcf93422ee0..d0515391d33b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/health.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/health.c
@@ -231,21 +231,6 @@ static const char *hsynd_str(u8 synd)
 	}
 }
 
-static u16 get_maj(u32 fw)
-{
-	return fw >> 28;
-}
-
-static u16 get_min(u32 fw)
-{
-	return fw >> 16 & 0xfff;
-}
-
-static u16 get_sub(u32 fw)
-{
-	return fw & 0xffff;
-}
-
 static void print_health_info(struct mlx5_core_dev *dev)
 {
 	struct mlx5_core_health *health = &dev->priv.health;
@@ -263,13 +248,14 @@ static void print_health_info(struct mlx5_core_dev *dev)
 
 	dev_err(&dev->pdev->dev, "assert_exit_ptr 0x%08x\n", ioread32be(&h->assert_exit_ptr));
 	dev_err(&dev->pdev->dev, "assert_callra 0x%08x\n", ioread32be(&h->assert_callra));
-	fw = ioread32be(&h->fw_ver);
-	sprintf(fw_str, "%d.%d.%d", get_maj(fw), get_min(fw), get_sub(fw));
+	sprintf(fw_str, "%d.%d.%d", fw_rev_maj(dev), fw_rev_min(dev), fw_rev_sub(dev));
 	dev_err(&dev->pdev->dev, "fw_ver %s\n", fw_str);
 	dev_err(&dev->pdev->dev, "hw_id 0x%08x\n", ioread32be(&h->hw_id));
 	dev_err(&dev->pdev->dev, "irisc_index %d\n", ioread8(&h->irisc_index));
 	dev_err(&dev->pdev->dev, "synd 0x%x: %s\n", ioread8(&h->synd), hsynd_str(ioread8(&h->synd)));
 	dev_err(&dev->pdev->dev, "ext_synd 0x%04x\n", ioread16be(&h->ext_synd));
+	fw = ioread32be(&h->fw_ver);
+	dev_err(&dev->pdev->dev, "raw fw_ver 0x%08x\n", fw);
 }
 
 static unsigned long get_next_poll_jiffies(void)
-- 
2.11.0
