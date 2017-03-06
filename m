From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] mlxsw: pci: Remove unused bit
Date: Mon,  6 Mar 2017 21:25:21 +0100
Message-ID: <1488831921-5152-3-git-send-email-jiri@resnulli.us>
References: <1488831921-5152-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36485 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753351AbdCFUdk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 15:33:40 -0500
Received: by mail-wr0-f194.google.com with SMTP id l37so23150897wrc.3
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 12:33:39 -0800 (PST)
In-Reply-To: <1488831921-5152-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The overrun ignore bit isn't supported by the device's firmware and was
recently removed from the programmer's reference manual (PRM).

Remove it from the driver as well.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/cmd.h | 12 ------------
 drivers/net/ethernet/mellanox/mlxsw/pci.c |  2 --
 2 files changed, 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/cmd.h b/drivers/net/ethernet/mellanox/mlxsw/cmd.h
index a1b4842..479511c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/cmd.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/cmd.h
@@ -1043,13 +1043,6 @@ MLXSW_ITEM32(cmd_mbox, sw2hw_cq, cv, 0x00, 28, 4);
  */
 MLXSW_ITEM32(cmd_mbox, sw2hw_cq, c_eqn, 0x00, 24, 1);
 
-/* cmd_mbox_sw2hw_cq_oi
- * When set, overrun ignore is enabled. When set, updates of
- * CQ consumer counter (poll for completion) or Request completion
- * notifications (Arm CQ) DoorBells should not be rung on that CQ.
- */
-MLXSW_ITEM32(cmd_mbox, sw2hw_cq, oi, 0x00, 12, 1);
-
 /* cmd_mbox_sw2hw_cq_st
  * Event delivery state machine
  * 0x0 - FIRED
@@ -1132,11 +1125,6 @@ static inline int mlxsw_cmd_sw2hw_eq(struct mlxsw_core *mlxsw_core,
  */
 MLXSW_ITEM32(cmd_mbox, sw2hw_eq, int_msix, 0x00, 24, 1);
 
-/* cmd_mbox_sw2hw_eq_oi
- * When set, overrun ignore is enabled.
- */
-MLXSW_ITEM32(cmd_mbox, sw2hw_eq, oi, 0x00, 12, 1);
-
 /* cmd_mbox_sw2hw_eq_st
  * Event delivery state machine
  * 0x0 - FIRED
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index a223c85..ffeb746 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -580,7 +580,6 @@ static int mlxsw_pci_cq_init(struct mlxsw_pci *mlxsw_pci, char *mbox,
 
 	mlxsw_cmd_mbox_sw2hw_cq_cv_set(mbox, 0); /* CQE ver 0 */
 	mlxsw_cmd_mbox_sw2hw_cq_c_eqn_set(mbox, MLXSW_PCI_EQ_COMP_NUM);
-	mlxsw_cmd_mbox_sw2hw_cq_oi_set(mbox, 0);
 	mlxsw_cmd_mbox_sw2hw_cq_st_set(mbox, 0);
 	mlxsw_cmd_mbox_sw2hw_cq_log_cq_size_set(mbox, ilog2(q->count));
 	for (i = 0; i < MLXSW_PCI_AQ_PAGES; i++) {
@@ -755,7 +754,6 @@ static int mlxsw_pci_eq_init(struct mlxsw_pci *mlxsw_pci, char *mbox,
 	}
 
 	mlxsw_cmd_mbox_sw2hw_eq_int_msix_set(mbox, 1); /* MSI-X used */
-	mlxsw_cmd_mbox_sw2hw_eq_oi_set(mbox, 0);
 	mlxsw_cmd_mbox_sw2hw_eq_st_set(mbox, 1); /* armed */
 	mlxsw_cmd_mbox_sw2hw_eq_log_eq_size_set(mbox, ilog2(q->count));
 	for (i = 0; i < MLXSW_PCI_AQ_PAGES; i++) {
-- 
2.7.4
