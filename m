From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/5] net/mlx4_core: Fix wrong order of flow steering resources removal
Date: Thu, 21 Mar 2013 17:55:52 +0200
Message-ID: <1363881355-21137-3-git-send-email-ogerlitz@mellanox.com>
References: <1363881355-21137-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	jackm@dev.mellanox.co.il, hadarh@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:39288 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755952Ab3CUP4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 11:56:05 -0400
In-Reply-To: <1363881355-21137-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

On the resource tracker cleanup flow, the DMFS rules must be deleted before we
destroy the QPs, else the HW may attempt doing packet steering to non existent QPs.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 2995687..0d1d967 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -3806,6 +3806,7 @@ void mlx4_delete_all_resources_for_slave(struct mlx4_dev *dev, int slave)
 	mutex_lock(&priv->mfunc.master.res_tracker.slave_list[slave].mutex);
 	/*VLAN*/
 	rem_slave_macs(dev, slave);
+	rem_slave_fs_rule(dev, slave);
 	rem_slave_qps(dev, slave);
 	rem_slave_srqs(dev, slave);
 	rem_slave_cqs(dev, slave);
@@ -3814,6 +3815,5 @@ void mlx4_delete_all_resources_for_slave(struct mlx4_dev *dev, int slave)
 	rem_slave_mtts(dev, slave);
 	rem_slave_counters(dev, slave);
 	rem_slave_xrcdns(dev, slave);
-	rem_slave_fs_rule(dev, slave);
 	mutex_unlock(&priv->mfunc.master.res_tracker.slave_list[slave].mutex);
 }
-- 
1.7.1
