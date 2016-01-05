From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: pci: Adjust value of CPU egress traffic class
Date: Tue,  5 Jan 2016 11:36:40 +0100
Message-ID: <1451990200-2356-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38847 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478AbcAEKgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 05:36:43 -0500
Received: by mail-wm0-f48.google.com with SMTP id b14so22192321wmb.1
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 02:36:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

During initialization, when creating the send descriptor queues (SDQs),
we specify the CPU egress traffic class of each SDQ. The maximum number
of classes of this type is different in the two ASICs supported by this
PCI driver.

New firmware versions check this value is set correctly, which causes
errors on the Spectrum ASIC, as its max exposed egress traffic class is
lower than 7.

Solve this by setting this field to 3, which is an acceptable value for
both ASICs.

Note that we currently do not expose the QoS capabilities of the ASICs,
so setting this to an hardcoded value is OK for now.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/pci.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index d2102e5..c071077 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -384,7 +384,7 @@ static int mlxsw_pci_sdq_init(struct mlxsw_pci *mlxsw_pci, char *mbox,
 
 	/* Set CQ of same number of this SDQ. */
 	mlxsw_cmd_mbox_sw2hw_dq_cq_set(mbox, q->num);
-	mlxsw_cmd_mbox_sw2hw_dq_sdq_tclass_set(mbox, 7);
+	mlxsw_cmd_mbox_sw2hw_dq_sdq_tclass_set(mbox, 3);
 	mlxsw_cmd_mbox_sw2hw_dq_log2_dq_sz_set(mbox, 3); /* 8 pages */
 	for (i = 0; i < MLXSW_PCI_AQ_PAGES; i++) {
 		dma_addr_t mapaddr = __mlxsw_pci_queue_page_get(q, i);
-- 
1.9.3
