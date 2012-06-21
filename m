From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 2/4] net/mlx4: Use single completion vector after NOP failure
Date: Thu, 21 Jun 2012 12:19:15 +0300
Message-ID: <1340270358-19504-3-git-send-email-yevgenyp@mellanox.co.il>
References: <1340270358-19504-1-git-send-email-yevgenyp@mellanox.co.il>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:40851 "HELO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932366Ab2FUJTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 05:19:41 -0400
In-Reply-To: <1340270358-19504-1-git-send-email-yevgenyp@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a crash at the error flow of NOP command which caused the driver to try and use
a completion vector which wasn't allocated.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 18c8deb..c91a2b8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -1978,6 +1978,8 @@ slave_start:
 	if (err == -EBUSY && (dev->flags & MLX4_FLAG_MSI_X) &&
 	    !mlx4_is_mfunc(dev)) {
 		dev->flags &= ~MLX4_FLAG_MSI_X;
+		dev->caps.num_comp_vectors = 1;
+		dev->caps.comp_pool	   = 0;
 		pci_disable_msix(pdev);
 		err = mlx4_setup_hca(dev);
 	}
-- 
1.7.1
