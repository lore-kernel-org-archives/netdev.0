From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next-2.6] mlx4: make functions local and remove dead
 code.
Date: Thu, 21 Oct 2010 09:59:20 -0700
Message-ID: <20101021095920.17bd21f1@nehalam>
References: <20101018083059.164fc8d8@nehalam>
	<E113D394D7C5DB4F8FF691FA7EE9DB443CC3716F65@MTLMAIL.mtl.com>
	<20101021.031356.115939257.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yevgenyp@mellanox.co.il, netdev@vger.kernel.org, eli@mellanox.co.il
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56748 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753368Ab0JUQ7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Oct 2010 12:59:32 -0400
In-Reply-To: <20101021.031356.115939257.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the following function static: mlx4_UNMAP_ICM
Remove the following unused function:  mlx4_MAP_ICM_page

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Leave the vlan functions alone, since patch using them is pending.

 drivers/net/mlx4/icm.c |   28 +---------------------------
 drivers/net/mlx4/icm.h |    2 --
 2 files changed, 1 insertion(+), 29 deletions(-)

--- a/drivers/net/mlx4/icm.c	2010-10-21 08:59:30.921914839 -0700
+++ b/drivers/net/mlx4/icm.c	2010-10-21 09:03:31.034200443 -0700
@@ -210,38 +210,12 @@ static int mlx4_MAP_ICM(struct mlx4_dev
 	return mlx4_map_cmd(dev, MLX4_CMD_MAP_ICM, icm, virt);
 }
 
-int mlx4_UNMAP_ICM(struct mlx4_dev *dev, u64 virt, u32 page_count)
+static int mlx4_UNMAP_ICM(struct mlx4_dev *dev, u64 virt, u32 page_count)
 {
 	return mlx4_cmd(dev, virt, page_count, 0, MLX4_CMD_UNMAP_ICM,
 			MLX4_CMD_TIME_CLASS_B);
 }
 
-int mlx4_MAP_ICM_page(struct mlx4_dev *dev, u64 dma_addr, u64 virt)
-{
-	struct mlx4_cmd_mailbox *mailbox;
-	__be64 *inbox;
-	int err;
-
-	mailbox = mlx4_alloc_cmd_mailbox(dev);
-	if (IS_ERR(mailbox))
-		return PTR_ERR(mailbox);
-	inbox = mailbox->buf;
-
-	inbox[0] = cpu_to_be64(virt);
-	inbox[1] = cpu_to_be64(dma_addr);
-
-	err = mlx4_cmd(dev, mailbox->dma, 1, 0, MLX4_CMD_MAP_ICM,
-		       MLX4_CMD_TIME_CLASS_B);
-
-	mlx4_free_cmd_mailbox(dev, mailbox);
-
-	if (!err)
-		mlx4_dbg(dev, "Mapped page at %llx to %llx for ICM.\n",
-			  (unsigned long long) dma_addr, (unsigned long long) virt);
-
-	return err;
-}
-
 int mlx4_MAP_ICM_AUX(struct mlx4_dev *dev, struct mlx4_icm *icm)
 {
 	return mlx4_map_cmd(dev, MLX4_CMD_MAP_ICM_AUX, icm, -1);
--- a/drivers/net/mlx4/icm.h	2010-10-21 08:59:30.937916493 -0700
+++ b/drivers/net/mlx4/icm.h	2010-10-21 09:03:31.034200443 -0700
@@ -128,8 +128,6 @@ static inline unsigned long mlx4_icm_siz
 	return sg_dma_len(&iter->chunk->mem[iter->page_idx]);
 }
 
-int mlx4_UNMAP_ICM(struct mlx4_dev *dev, u64 virt, u32 page_count);
-int mlx4_MAP_ICM_page(struct mlx4_dev *dev, u64 dma_addr, u64 virt);
 int mlx4_MAP_ICM_AUX(struct mlx4_dev *dev, struct mlx4_icm *icm);
 int mlx4_UNMAP_ICM_AUX(struct mlx4_dev *dev);
 
