From: Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 1/5] NetXen: Removal of extra free_irq call
Date: Fri, 1 Jun 2007 04:13:08 -0700
Message-ID: <200706011113.l51BD8HW004651@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, mithlesh@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:29577 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753976AbXFALNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 07:13:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Removal of redundant free_irq
This patch removes a redundant free_irq() call from remove() routine.
This will also eliminate a warning during unload of driver.

Signed-by: Mithlesh Thukral <mithlesh@netxen.com>
---

 drivers/net/netxen/netxen_nic_main.c |    2 --
 1 files changed, 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 2c5c6d2..c61181f 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -654,8 +654,6 @@ static void __devexit netxen_nic_remove(
 	if (adapter->portnum == 0)
 		netxen_free_adapter_offload(adapter);
 
-	if (adapter->irq)
-		free_irq(adapter->irq, adapter);
 	if(adapter->portnum == 0) {
 		/* leave the hw in the same state as reboot */
 		writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
