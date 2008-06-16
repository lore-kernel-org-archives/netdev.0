From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 1/4] netxen: fix portnum for hp mezz cards
Date: Sun, 15 Jun 2008 22:59:43 -0700
Message-ID: <1213595986-1929-2-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:32887 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752132AbYFPGir (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 02:38:47 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a the issue where logical port number is set incorrectly
for HP blade mezz cards.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 7144c25..5a2fd21 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -530,9 +530,15 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netxen_initialize_adapter_sw(adapter);	/* initialize the buffers in adapter */
 
 	/* Mezz cards have PCI function 0,2,3 enabled */
-	if ((adapter->ahw.boardcfg.board_type == NETXEN_BRDTYPE_P2_SB31_10G_IMEZ)
-		&& (pci_func_id >= 2))
+	switch (adapter->ahw.boardcfg.board_type) {
+	case NETXEN_BRDTYPE_P2_SB31_10G_IMEZ:
+	case NETXEN_BRDTYPE_P2_SB31_10G_HMEZ:
+		if (pci_func_id >= 2)
 			adapter->portnum = pci_func_id - 2;
+		break;
+	default:
+		break;
+	}
 
 #ifdef CONFIG_IA64
 	if(adapter->portnum == 0) {
-- 
1.5.4.3

