From: nikolay@redhat.com
Subject: [PATCH] netxen: check for root bus in netxen_mask_aer_correctable
Date: Fri, 14 Sep 2012 17:50:03 +0200
Message-ID: <1347637803-4837-1-git-send-email-nikolay@redhat.com>
Cc: rajesh.borundia@qlogic.com, netdev@vger.kernel.org
To: sony.chacko@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53762 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758824Ab2INPvV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2012 11:51:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>

Add a check if pdev->bus->self == NULL (root bus). When attaching
a netxen NIC to a VM it can be on the root bus and the guest would
crash in netxen_mask_aer_correctable() because of a NULL pointer
dereference if CONFIG_PCIEAER is present.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 342b3a7..e2a4858 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -1378,6 +1378,10 @@ static void netxen_mask_aer_correctable(struct netxen_adapter *adapter)
 	struct pci_dev *root = pdev->bus->self;
 	u32 aer_pos;
 
+	/* root bus? */
+	if (!root)
+		return;
+
 	if (adapter->ahw.board_type != NETXEN_BRDTYPE_P3_4_GB_MM &&
 		adapter->ahw.board_type != NETXEN_BRDTYPE_P3_10G_TP)
 		return;
-- 
1.7.11.4
