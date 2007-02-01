From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 2.6.20-rc7 1/2] atl1: get rid of pci_module_init
Date: Wed, 31 Jan 2007 19:10:52 -0600
Message-ID: <20070201011052.GA1752@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net,
	alan@lxorguk.ukuu.org.uk
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf21aec.mail.bellsouth.net ([205.152.59.69]:34058 "EHLO
	imf21aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161164AbXBABK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 20:10:56 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jay Cliburn <jacliburn@bellsouth.net>

pci_module_init is deprecated.  Use pci_register_driver instead.
Discovered by and modification suggested by Alan Cox.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---

 drivers/net/atl1/atl1_main.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 0afa9c1..793c43b 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -2461,12 +2461,9 @@ static void __exit atl1_exit_module(void)
  */
 static int __init atl1_init_module(void)
 {
-	int ret;
 	printk(KERN_INFO "%s - version %s\n", atl1_driver_string, DRIVER_VERSION);
 	printk(KERN_INFO "%s\n", atl1_copyright);
-	ret = pci_module_init(&atl1_driver);
-
-	return ret;
+	return pci_register_driver(&atl1_driver);
 }
 
 module_init(atl1_init_module);
