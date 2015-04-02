From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 01/16] net/mlx5_core: Allocate firmware pages from device's NUMA node
Date: Thu,  2 Apr 2015 17:07:19 +0300
Message-ID: <1427983654-971-2-git-send-email-eli@mellanox.com>
References: <1427983654-971-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, idos@mellaox.com, amirv@mellanox.com,
	Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:33848 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093AbbDBOHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 10:07:42 -0400
Received: by wgbdm7 with SMTP id dm7so86706029wgb.1
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 07:07:41 -0700 (PDT)
In-Reply-To: <1427983654-971-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocate firmware pages from the NUMA node which is close to the device.

Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
index 4fdaae9b54d9..cf8591a0c48d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
@@ -243,8 +243,9 @@ static int alloc_system_page(struct mlx5_core_dev *dev, u16 func_id)
 	struct page *page;
 	u64 addr;
 	int err;
+	int nid = dev_to_node(&dev->pdev->dev);
 
-	page = alloc_page(GFP_HIGHUSER);
+	page = alloc_pages_node(nid, GFP_HIGHUSER, 0);
 	if (!page) {
 		mlx5_core_warn(dev, "failed to allocate page\n");
 		return -ENOMEM;
-- 
2.3.1
