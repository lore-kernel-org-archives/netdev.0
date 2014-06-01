From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] net/mlx4_core: Fix Oops on reboot when SRIOV VFs are probed into the Host
Date: Sun,  1 Jun 2014 13:49:43 +0300
Message-ID: <1401619783-23659-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	weiyang@linux.vnet.ibm.com,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:58940 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751929AbaFAKuE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jun 2014 06:50:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

Commit befdf89 did not take into account the case where the Host
driver is being unloaded. In this case, pci_get_drvdata for the VF
remove_one call may return NULL, so that dereferencing the priv
struct results in a kernel oops.

The fix is to also test that the dev pointer returned by
pci_get_drvdata is non-NULL.

Fixes: befdf89 ("preserve pcd_dev_data after __mlx4_remove_one()")
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index c187d74..a6ae089 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2629,7 +2629,7 @@ static void __mlx4_remove_one(struct pci_dev *pdev)
 	int               pci_dev_data;
 	int p;
 
-	if (priv->removed)
+	if (!dev || priv->removed)
 		return;
 
 	pci_dev_data = priv->pci_dev_data;
-- 
1.7.1
