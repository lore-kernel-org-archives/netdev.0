From: Tim Wright <tim@binbash.co.uk>
Subject: [PATCH 1/1] IB/mlx5: Add port_xmit_wait to counter registers read
Date: Mon,  1 May 2017 17:30:08 +0100
Message-ID: <20170501163008.27043-1-tim@binbash.co.uk>
Cc: Tim Wright <tim@binbash.co.uk>, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org
To: matanb@mellanox.com, leonro@mellanox.com, dledford@redhat.com,
        sean.hefty@intel.com, hal.rosenstock@gmail.com, saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgout0101.bt.lon5.cpcloud.co.uk ([65.20.0.121]:5504 "EHLO
        rgout01.bt.lon5.cpcloud.co.uk" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752464AbdEAQh1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 12:37:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add port_xmit_wait to the error counters read by mlx5_ib_process_mad to
ensure sysfs port counter provides correct value for PortXmitWait.
Otherwise the sysfs port_xmit_wait file always contains zero.

The previous MAD_IFC implementation populated this counter, but it was
removed during the migration to PPCNT for error counters (32-bit only).

Signed-off-by: Tim Wright <tim@binbash.co.uk>
---
 drivers/infiniband/hw/mlx5/mad.c | 2 ++
 include/linux/mlx5/mlx5_ifc.h    | 4 +++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/mlx5/mad.c b/drivers/infiniband/hw/mlx5/mad.c
index 8dacb49..f1b56de6 100644
--- a/drivers/infiniband/hw/mlx5/mad.c
+++ b/drivers/infiniband/hw/mlx5/mad.c
@@ -187,6 +187,8 @@ static void pma_cnt_assign(struct ib_pma_portcounters *pma_cnt,
 			     port_xmit_discards);
 	MLX5_ASSIGN_PMA_CNTR(pma_cnt->port_xmit_constraint_errors,
 			     port_xmit_constraint_errors);
+	MLX5_ASSIGN_PMA_CNTR(pma_cnt->port_xmit_wait,
+			     port_xmit_wait);
 	MLX5_ASSIGN_PMA_CNTR(pma_cnt->port_rcv_constraint_errors,
 			     port_rcv_constraint_errors);
 	MLX5_ASSIGN_PMA_CNTR(pma_cnt->link_overrun_errors,
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 8382426..e641bc3 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -1452,7 +1452,9 @@ struct mlx5_ifc_ib_port_cntrs_grp_data_layout_bits {
 
 	u8         vl_15_dropped[0x10];
 
-	u8	   reserved_at_a0[0xa0];
+	u8	   reserved_at_a0[0x80];
+
+	u8         port_xmit_wait[0x20];
 };
 
 struct mlx5_ifc_eth_per_traffic_grp_data_layout_bits {
-- 
1.8.3.1
