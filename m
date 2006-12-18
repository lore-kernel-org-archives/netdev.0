From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 5/8] NetXen: Link status message correction for quad port cards.
Date: Mon, 18 Dec 2006 05:53:12 -0800
Message-ID: <200612181353.kBIDrCX9012202@dut39.unminc.com>
Cc: amitkale@netxen.com, brazilnut@us.ibm.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com, sanjeev@netxen.com,
	wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:20159 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754059AbWLROW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Dec 2006 09:22:59 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Amit S. Kale <amitkale@netxen.com>
 
 netxen_nic_isr.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)
  

diff --git a/drivers/net/netxen/netxen_nic_isr.c b/drivers/net/netxen/netxen_nic_isr.c
index 1b45f50..06847d4 100644
--- a/drivers/net/netxen/netxen_nic_isr.c
+++ b/drivers/net/netxen/netxen_nic_isr.c
@@ -157,7 +157,8 @@ void netxen_nic_isr_other(struct netxen_
 	for (portno = 0; portno < NETXEN_NIU_MAX_GBE_PORTS; portno++) {
 		linkup = val & 1;
 		if (linkup != (qg_linksup & 1)) {
-			printk(KERN_INFO "%s: PORT %d link %s\n",
+			printk(KERN_INFO "%s: %s PORT %d link %s\n",
+			       adapter->port[portno]->netdev->name,
 			       netxen_nic_driver_name, portno,
 			       ((linkup == 0) ? "down" : "up"));
 			netxen_indicate_link_status(adapter, portno, linkup);
