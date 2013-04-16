From: Devendra Naga <devendra.aaru@gmail.com>
Subject: [PATCH net-next] tlan: cancel work at remove path
Date: Tue, 16 Apr 2013 17:00:38 +0530
Message-ID: <1366111838-29841-1-git-send-email-devendra.aaru@gmail.com>
Cc: Devendra Naga <devendra.aaru@gmail.com>, Sriram <srk@ti.com>,
	Cyril Chemparathy <cyril@ti.com>,
	Vinay Hegde <vinay.hegde@ti.com>
To: Samuel Chessman <chessman@tux.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:46267 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754463Ab3DPLaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 07:30:52 -0400
Received: by mail-pd0-f174.google.com with SMTP id p12so244137pdj.19
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 04:30:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the work has been scheduled from interrupt, and not been
cancelled when the driver is unloaded, which doesn't remove
the work item from the global workqueue. call the
cancel_work_sync when the driver is removed (rmmod'ed).

Cc: Sriram <srk@ti.com>
Cc: Cyril Chemparathy <cyril@ti.com>
Cc: Vinay Hegde <vinay.hegde@ti.com>
Signed-off-by: Devendra Naga <devendra.aaru@gmail.com>
---

Hi,
	This is only compile tested and not tested
	on the the NIC which i dont have.

thanks

 drivers/net/ethernet/ti/tlan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index bdda36f..60c400f 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -320,6 +320,7 @@ static void tlan_remove_one(struct pci_dev *pdev)
 	free_netdev(dev);
 
 	pci_set_drvdata(pdev, NULL);
+	cancel_work_sync(&priv->tlan_tqueue);
 }
 
 static void tlan_start(struct net_device *dev)
-- 
1.8.1.4
