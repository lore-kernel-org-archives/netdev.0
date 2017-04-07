From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 5/7] net/mlx5e: Show board id in ethtool driver information
Date: Fri,  7 Apr 2017 21:26:54 +0300
Message-ID: <20170407182656.6734-6-saeedm@mellanox.com>
References: <20170407182656.6734-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Inbar Karmy <inbark@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47253 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756042AbdDGS1T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 14:27:19 -0400
In-Reply-To: <20170407182656.6734-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Inbar Karmy <inbark@mellanox.com>

Add the board id (PSID) to the firmware-version field
in the ethtool -i (driver information).
The PSID is shown in parentheses, next to the fw-version.

$ ethtool -i ens6
firmware-version: 12.14.1101 (MT_2190110032)

Signed-off-by: Inbar Karmy <inbark@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 167a8379156e..ce7b09d72ff6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -42,8 +42,9 @@ static void mlx5e_get_drvinfo(struct net_device *dev,
 	strlcpy(drvinfo->version, DRIVER_VERSION " (" DRIVER_RELDATE ")",
 		sizeof(drvinfo->version));
 	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
-		 "%d.%d.%04d",
-		 fw_rev_maj(mdev), fw_rev_min(mdev), fw_rev_sub(mdev));
+		 "%d.%d.%04d (%.16s)",
+		 fw_rev_maj(mdev), fw_rev_min(mdev), fw_rev_sub(mdev),
+		 mdev->board_id);
 	strlcpy(drvinfo->bus_info, pci_name(mdev->pdev),
 		sizeof(drvinfo->bus_info));
 }
-- 
2.11.0
