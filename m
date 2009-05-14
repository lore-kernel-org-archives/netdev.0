From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 1/2] netxen: fix msi irq setup
Date: Thu, 14 May 2009 00:16:08 -0700
Message-ID: <1242285368-1142-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:48360 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751738AbZENHQL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 May 2009 03:16:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The pdev->irq was not saved in netxen_adapter, causing request_irq()
with invalid irq number.

This was broken in commit be339aee634d5cb98a8df8d6febe04002ec497f3.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 86ca081..50477f5 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -539,6 +539,7 @@ netxen_setup_intr(struct netxen_adapter *adapter)
 		adapter->msi_tgt_status =
 			msi_tgt_status[adapter->ahw.pci_func];
 		dev_info(&pdev->dev, "using msi interrupts\n");
+		adapter->msix_entries[0].vector = pdev->irq;
 		return;
 	}
 
-- 
1.6.0.2

