From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH] ethernet :mellanox :mlx5: Replace pci_pool_alloc by
 pci_pool_zalloc
Date: Mon, 28 Nov 2016 19:07:40 +0530
Message-ID: <20161128133740.GA688@gnr743-HP-ZBook-15>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        sahu.rameshwar73@gmail.com
To: saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35188 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932765AbcK1Nho (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 08:37:44 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In alloc_cmd_box(), pci_pool_alloc() followed by memset will be
replaced by pci_pool_zalloc()

Signed-off-by: Souptick joarder <jrdr.linux@gmail.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 1e639f8..d96ebd4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -1063,14 +1063,13 @@ static struct mlx5_cmd_mailbox *alloc_cmd_box(struct mlx5_core_dev *dev,
 	if (!mailbox)
 		return ERR_PTR(-ENOMEM);
 
-	mailbox->buf = pci_pool_alloc(dev->cmd.pool, flags,
+	mailbox->buf = pci_pool_zalloc(dev->cmd.pool, flags,
 				      &mailbox->dma);
 	if (!mailbox->buf) {
 		mlx5_core_dbg(dev, "failed allocation\n");
 		kfree(mailbox);
 		return ERR_PTR(-ENOMEM);
 	}
-	memset(mailbox->buf, 0, sizeof(struct mlx5_cmd_prot_block));
 	mailbox->next = NULL;
 
 	return mailbox;
-- 
1.9.1
