From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/15] mlxsw: pci: Do not use MLXSW_PCI_SDQS_COUNT define
Date: Thu, 15 Oct 2015 17:43:18 +0200
Message-ID: <1444923809-20785-5-git-send-email-jiri@resnulli.us>
References: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:35350 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753718AbbJOPni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 11:43:38 -0400
Received: by lbwr8 with SMTP id r8so73576125lbw.2
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 08:43:36 -0700 (PDT)
In-Reply-To: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Use mlxsw_pci_sdq_count helper instead.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/pci.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 5ba740a..946341e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -497,6 +497,7 @@ static int mlxsw_pci_rdq_init(struct mlxsw_pci *mlxsw_pci, char *mbox,
 			      struct mlxsw_pci_queue *q)
 {
 	struct mlxsw_pci_queue_elem_info *elem_info;
+	u8 sdq_count = mlxsw_pci_sdq_count(mlxsw_pci);
 	int i;
 	int err;
 
@@ -504,9 +505,9 @@ static int mlxsw_pci_rdq_init(struct mlxsw_pci *mlxsw_pci, char *mbox,
 	q->consumer_counter = 0;
 
 	/* Set CQ of same number of this RDQ with base
-	 * above MLXSW_PCI_SDQS_MAX as the lower ones are assigned to SDQs.
+	 * above SDQ count as the lower ones are assigned to SDQs.
 	 */
-	mlxsw_cmd_mbox_sw2hw_dq_cq_set(mbox, q->num + MLXSW_PCI_SDQS_COUNT);
+	mlxsw_cmd_mbox_sw2hw_dq_cq_set(mbox, sdq_count + q->num);
 	mlxsw_cmd_mbox_sw2hw_dq_log2_dq_sz_set(mbox, 3); /* 8 pages */
 	for (i = 0; i < MLXSW_PCI_AQ_PAGES; i++) {
 		dma_addr_t mapaddr = __mlxsw_pci_queue_page_get(q, i);
-- 
1.9.3
