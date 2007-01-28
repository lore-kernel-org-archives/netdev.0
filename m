From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 2.6.20-rc5 3/4] atl1: properly use CONFIG_PM
Date: Sat, 27 Jan 2007 18:12:47 -0600
Message-ID: <20070128001247.GC10269@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net,
	akpm@osdl.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf21aec.mail.bellsouth.net ([205.152.59.69]:34266 "EHLO
	imf21aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932175AbXA1AMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jan 2007 19:12:48 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Jay Cliburn <jacliburn@bellsouth.net>

Fix power management by properly using ifdef CONFIG_PM.  Discovered by
and modification suggested by Andrew Morton.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---

 drivers/net/atl1/atl1_main.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index a9e02d1..1045325 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -2345,6 +2345,7 @@ static void __devexit atl1_remove(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 }
 
+#ifdef CONFIG_PM
 static int atl1_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
@@ -2438,6 +2439,10 @@ static int atl1_resume(struct pci_dev *pdev)
 
 	return 0;
 }
+#else
+#define atl1_suspend NULL
+#define atl1_resume NULL
+#endif
 
 static struct pci_driver atl1_driver = {
 	.name = atl1_driver_name,
@@ -2446,10 +2451,8 @@ static struct pci_driver atl1_driver = {
 	.remove = __devexit_p(atl1_remove),
 	/* Power Managment Hooks */
 	/* probably broken right now -- CHS */
-#ifdef CONFIG_PM
 	.suspend = atl1_suspend,
 	.resume = atl1_resume
-#endif
 };
 
 /**
