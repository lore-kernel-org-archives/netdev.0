From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 1/5] netxen: fix physical port mapping
Date: Sun, 22 Feb 2009 23:42:12 -0800
Message-ID: <1235374936-28778-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:42579 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752780AbZBWHmV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Feb 2009 02:42:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PCI function to physical port mapping is valid only for
old firmware. New firmware (4.0.0+) abstracts this.
So driver should never try to access phy using invalid
mapping.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 7401779..f1811ca 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -796,9 +796,12 @@ skip_doorbell:
 	 * See if the firmware gave us a virtual-physical port mapping.
 	 */
 	adapter->physical_port = adapter->portnum;
-	i = adapter->pci_read_normalize(adapter, CRB_V2P(adapter->portnum));
-	if (i != 0x55555555)
-		adapter->physical_port = i;
+	if (adapter->fw_major < 4) {
+		i = adapter->pci_read_normalize(adapter,
+				CRB_V2P(adapter->portnum));
+		if (i != 0x55555555)
+			adapter->physical_port = i;
+	}
 
 	adapter->flags &= ~(NETXEN_NIC_MSI_ENABLED | NETXEN_NIC_MSIX_ENABLED);
 
-- 
1.6.0.2

