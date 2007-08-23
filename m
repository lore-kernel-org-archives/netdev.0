From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 2/2] [RFC] E1000: Fix hang in netdev_wait_allrefs()
Date: Thu, 23 Aug 2007 14:34:31 +0530
Message-ID: <20070823090431.13099.2597.sendpatchset@localhost.localdomain>
References: <20070823090418.13099.89298.sendpatchset@localhost.localdomain>
Cc: Krishna Kumar <krkumar2@in.ibm.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:36249 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756632AbXHWJCx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2007 05:02:53 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7N92qdD015892
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 05:02:52 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7N92quW446548
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 05:02:52 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7N92qsI018442
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 05:02:52 -0400
In-Reply-To: <20070823090418.13099.89298.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After applying patch1, I started getting "waiting for count" messages when
doing ifdown. Not sure if this is the right fix since the count was already
showing as -1 in that message, but this patch fixes the problem.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 e1000_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

diff -ruNp new/drivers/net/e1000/e1000_main.c new2/drivers/net/e1000/e1000_main.c
--- new/drivers/net/e1000/e1000_main.c	2007-08-23 13:32:34.000000000 +0530
+++ new2/drivers/net/e1000/e1000_main.c	2007-08-23 14:28:12.000000000 +0530
@@ -1219,12 +1219,13 @@ e1000_remove(struct pci_dev *pdev)
 	 * would have already happened in close and is redundant. */
 	e1000_release_hw_control(adapter);
 
-	unregister_netdev(netdev);
 #ifdef CONFIG_E1000_NAPI
 	for (i = 0; i < adapter->num_rx_queues; i++)
 		dev_put(&adapter->polling_netdev[i]);
 #endif
 
+	unregister_netdev(netdev);
+
 	if (!e1000_check_phy_reset_block(&adapter->hw))
 		e1000_phy_hw_reset(&adapter->hw);
 
