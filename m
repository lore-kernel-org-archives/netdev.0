From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 1/2] netxen: fix build with without CONFIG_PM
Date: Mon, 22 Jun 2009 23:26:20 -0700
Message-ID: <1245738381-30163-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:51581 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751315AbZFWG0X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jun 2009 02:26:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

wrap pci suspend() and resume() with CONFIG_PM check.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 71daa3d..43ac333 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1178,6 +1178,7 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 	free_netdev(netdev);
 }
 
+#ifdef CONFIG_PM
 static int
 netxen_nic_suspend(struct pci_dev *pdev, pm_message_t state)
 {
@@ -1242,6 +1243,7 @@ netxen_nic_resume(struct pci_dev *pdev)
 
 	return 0;
 }
+#endif
 
 static int netxen_nic_open(struct net_device *netdev)
 {
@@ -1771,8 +1773,10 @@ static struct pci_driver netxen_driver = {
 	.id_table = netxen_pci_tbl,
 	.probe = netxen_nic_probe,
 	.remove = __devexit_p(netxen_nic_remove),
+#ifdef CONFIG_PM
 	.suspend = netxen_nic_suspend,
 	.resume = netxen_nic_resume
+#endif
 };
 
 /* Driver Registration on NetXen card    */
-- 
1.6.0.2

