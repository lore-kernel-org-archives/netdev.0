From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next] mlx4: Use actual number of PCI functions (PF + VFs) for alias GUID logic
Date: Sun, 23 Mar 2014 09:50:43 +0200
Message-ID: <1395561043-435-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Matan Barak <matanb@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:52800 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750974AbaCWHut (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Mar 2014 03:50:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

The code which is dealing with SRIOV alias GUIDs in the mlx4 IB driver has some
logic which operated according to the maximal possible active functions (PF + VFs).

After the single port VFs code integration this resulted in a flow of false-positive
warnings going to the kernel log after the PF driver started the alias GUID work. 

Fix it by referring to the actual number of functions.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/alias_GUID.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/alias_GUID.c b/drivers/infiniband/hw/mlx4/alias_GUID.c
index 2f215b9..0eb141c 100644
--- a/drivers/infiniband/hw/mlx4/alias_GUID.c
+++ b/drivers/infiniband/hw/mlx4/alias_GUID.c
@@ -154,7 +154,7 @@ void mlx4_ib_notify_slaves_on_guid_change(struct mlx4_ib_dev *dev,
 			continue;
 
 		slave_id = (block_num * NUM_ALIAS_GUID_IN_REC) + i ;
-		if (slave_id >= dev->dev->num_slaves)
+		if (slave_id >= dev->dev->num_vfs + 1)
 			return;
 		tmp_cur_ag = *(__be64 *)&p_data[i * GUID_REC_SIZE];
 		form_cache_ag = get_cached_alias_guid(dev, port_num,
-- 
1.7.1
