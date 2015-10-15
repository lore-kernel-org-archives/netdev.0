From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/15] mlxsw: Use dev_level_ratelimited instead of net_ratelimit & dev_level
Date: Thu, 15 Oct 2015 17:43:22 +0200
Message-ID: <1444923809-20785-9-git-send-email-jiri@resnulli.us>
References: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:34950 "EHLO
	mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753678AbbJOPnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 11:43:42 -0400
Received: by lffy185 with SMTP id y185so33148988lff.2
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 08:43:41 -0700 (PDT)
In-Reply-To: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/pci.c      | 7 +++----
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 5 ++---
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 87afa5f..974ce47 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -431,8 +431,7 @@ static int mlxsw_pci_wqe_frag_map(struct mlxsw_pci *mlxsw_pci, char *wqe,
 
 	mapaddr = pci_map_single(pdev, frag_data, frag_len, direction);
 	if (unlikely(pci_dma_mapping_error(pdev, mapaddr))) {
-		if (net_ratelimit())
-			dev_err(&pdev->dev, "failed to dma map tx frag\n");
+		dev_err_ratelimited(&pdev->dev, "failed to dma map tx frag\n");
 		return -EIO;
 	}
 	mlxsw_pci_wqe_address_set(wqe, index, mapaddr);
@@ -700,8 +699,8 @@ static void mlxsw_pci_cqe_rdq_handle(struct mlxsw_pci *mlxsw_pci,
 put_new_skb:
 	memset(wqe, 0, q->elem_size);
 	err = mlxsw_pci_rdq_skb_alloc(mlxsw_pci, elem_info);
-	if (err && net_ratelimit())
-		dev_dbg(&pdev->dev, "Failed to alloc skb for RDQ\n");
+	if (err)
+		dev_dbg_ratelimited(&pdev->dev, "Failed to alloc skb for RDQ\n");
 	/* Everything is set up, ring doorbell to pass elem to HW */
 	q->producer_counter++;
 	mlxsw_pci_queue_doorbell_producer_ring(mlxsw_pci, q);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index fd6f438..39a0074 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -1210,9 +1210,8 @@ static void mlxsw_sx_rx_listener_func(struct sk_buff *skb, u8 local_port,
 	struct mlxsw_sx_port_pcpu_stats *pcpu_stats;
 
 	if (unlikely(!mlxsw_sx_port)) {
-		if (net_ratelimit())
-			dev_warn(mlxsw_sx->bus_info->dev, "Port %d: skb received for non-existent port\n",
-				 local_port);
+		dev_warn_ratelimited(mlxsw_sx->bus_info->dev, "Port %d: skb received for non-existent port\n",
+				     local_port);
 		return;
 	}
 
-- 
1.9.3
