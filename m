From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH 06/19] mlx4: remove unnecessary read of PCI_CAP_ID_EXP
Date: Mon, 27 Jun 2011 12:42:17 -0500
Message-ID: <1309196537-15879-1-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:38395 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751115Ab1F0RmW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 13:42:22 -0400
Received: by pzk9 with SMTP id 9so3102676pzk.19
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2011 10:42:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PCIE capability offset is saved during PCI bus walking.  It will
remove an unnecessary search in the PCI configuration space if this
value is referenced instead of reacquiring it.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/mlx4/reset.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mlx4/reset.c b/drivers/net/mlx4/reset.c
index e5741da..11e7c1c 100644
--- a/drivers/net/mlx4/reset.c
+++ b/drivers/net/mlx4/reset.c
@@ -77,7 +77,7 @@ int mlx4_reset(struct mlx4_dev *dev)
 		goto out;
 	}
 
-	pcie_cap = pci_find_capability(dev->pdev, PCI_CAP_ID_EXP);
+	pcie_cap = pci_pcie_cap(dev->pdev);
 
 	for (i = 0; i < 64; ++i) {
 		if (i == 22 || i == 23)
-- 
1.7.5.4

