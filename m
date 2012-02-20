From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net] mlx4_core: Do not map BF area if capability is 0
Date: Mon, 20 Feb 2012 09:38:52 +0200
Message-ID: <4F41F88C.3070607@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<jackm@dev.mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:42758 "HELO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751501Ab2BTHi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2012 02:38:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

BF can be disabled in some cases, the capability field, bf_reg_size is set
to zero in this case. Don't map the BF area in this case, it would cause 
failures.  In addition, leaving the BF area unmapped
also alerts the ETH driver to not use BF.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 678558b..9c5fbad 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -986,6 +986,9 @@ static int map_bf_area(struct mlx4_dev *dev)
 	resource_size_t bf_len;
 	int err = 0;
 
+	if (!dev->caps.bf_reg_size)
+		return -ENXIO;
+
 	bf_start = pci_resource_start(dev->pdev, 2) +
 			(dev->caps.num_uars << PAGE_SHIFT);
 	bf_len = pci_resource_len(dev->pdev, 2) -
-- 
1.5.4.3
