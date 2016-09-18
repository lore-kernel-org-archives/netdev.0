From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/3] net/mlx5: E-Switch, Fix error flow in the SRIOV e-switch init code
Date: Sun, 18 Sep 2016 18:20:28 +0300
Message-ID: <1474212029-1052-3-git-send-email-ogerlitz@mellanox.com>
References: <1474212029-1052-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:56225 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932796AbcIRPUl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 11:20:41 -0400
In-Reply-To: <1474212029-1052-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When enablement of the SRIOV e-switch in certain mode (switchdev or legacy)
fails, we must set the mode to none. Otherwise, we'll run into double free
based crashes when further attempting to deal with the e-switch (such
as when disabling sriov or unloading the driver).

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 8b78f15..b247949 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -1554,6 +1554,7 @@ int mlx5_eswitch_enable_sriov(struct mlx5_eswitch *esw, int nvfs, int mode)
 
 abort:
 	esw_enable_vport(esw, 0, UC_ADDR_CHANGE);
+	esw->mode = SRIOV_NONE;
 	return err;
 }
 
-- 
2.3.7
