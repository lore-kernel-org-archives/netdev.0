From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net 4/4] net/mlx4_core: Don't issue PCIe speed/width checks for VFs
Date: Sun,  4 May 2014 17:07:25 +0300
Message-ID: <1399212445-5070-5-git-send-email-ogerlitz@mellanox.com>
References: <1399212445-5070-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, roland@kernel.org,
	jackm@dev.mellanox.co.il, matanb@mellanox.com, amirv@mellanox.com,
	Eyal Perry <eyalpe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:41804 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753259AbaEDOHo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 May 2014 10:07:44 -0400
In-Reply-To: <1399212445-5070-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Perry <eyalpe@mellanox.com>

Carrying out PCI speed/width checks through pcie_get_minimum_link()
on VFs yield wrong results, so remove them.

Fixes: b912b2f ('net/mlx4_core: Warn if device doesn't have enough PCI bandwidth')
Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index e98c15a..7cf9dad 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2440,7 +2440,8 @@ slave_start:
 	 * No return code for this call, just warn the user in case of PCI
 	 * express device capabilities are under-satisfied by the bus.
 	 */
-	mlx4_check_pcie_caps(dev);
+	if (!mlx4_is_slave(dev))
+		mlx4_check_pcie_caps(dev);
 
 	/* In master functions, the communication channel must be initialized
 	 * after obtaining its address from fw */
-- 
1.7.1
