From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 3/4] net/mlx4_core: Fix VF overwrite of module param which disables DMFS on new probed PFs
Date: Wed, 22 Feb 2017 14:33:26 +0200
Message-ID: <1487766807-13929-4-git-send-email-tariqt@mellanox.com>
References: <1487766807-13929-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>,
        Dexuan Cui <decui@microsoft.com>,
        Majd Dibbiny <majd@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54824 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752397AbdBVMeJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 07:34:09 -0500
In-Reply-To: <1487766807-13929-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Majd Dibbiny <majd@mellanox.com>

In the VF driver, module parameter mlx4_log_num_mgm_entry_size was
mistakenly overwritten -- and in a manner which overrode the
device-managed flow steering option encoded in the parameter.

log_num_mgm_entry_size is a global module parameter which
affects all ConnectX-3 PFs installed on that host.
If a VF changes log_num_mgm_entry_size, this will affect all PFs
which are probed subsequent to the change (by disabling DMFS for
those PFs).

Fixes: 3c439b5586e9 ("mlx4_core: Allow choosing flow steering mode")
Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Reviewed-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 55e4be51ee5a..7a030d10ff3e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -841,8 +841,6 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 		return -ENOSYS;
 	}
 
-	mlx4_log_num_mgm_entry_size = hca_param.log_mc_entry_sz;
-
 	dev->caps.hca_core_clock = hca_param.hca_core_clock;
 
 	memset(&dev_cap, 0, sizeof(dev_cap));
-- 
1.8.3.1
