From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 1/3] bnx2x: free workqueue when driver fail to register
Date: Wed, 6 May 2009 11:22:01 +0200
Message-ID: <20090506112201.28609620@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eilon Greenstein <eilong@broadcom.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35053 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752856AbZEFJ2Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2009 05:28:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/bnx2x_main.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index ad5ef25..ff2d9f6 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -11412,13 +11412,20 @@ static struct pci_driver bnx2x_pci_driver = {
 
 static int __init bnx2x_init(void)
 {
+	int ret;
+
 	bnx2x_wq = create_singlethread_workqueue("bnx2x");
 	if (bnx2x_wq == NULL) {
 		printk(KERN_ERR PFX "Cannot create workqueue\n");
 		return -ENOMEM;
 	}
 
-	return pci_register_driver(&bnx2x_pci_driver);
+	ret = pci_register_driver(&bnx2x_pci_driver);
+	if (ret) {
+		printk(KERN_ERR PFX "Cannot register driver\n");
+		destroy_workqueue(bnx2x_wq);
+	}
+	return ret;
 }
 
 static void __exit bnx2x_cleanup(void)
-- 
1.5.5.6

