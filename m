From: Peter Huewe <peterhuewe@gmx.de>
Subject: [PATCH 19/19] net/ethernet/nvidia/forcedeth: Use module_pci_driver to register driver
Date: Wed, 22 May 2013 01:42:56 +0200
Message-ID: <1369179778-20115-19-git-send-email-peterhuewe@gmx.de>
References: <1369176146-19383-1-git-send-email-peterhuewe@gmx.de>
Cc: Peter Huewe <peterhuewe@gmx.de>,
	David Decotigny <decot@googlers.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	linux-kernel@vger.kernel.org (open list)
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:56074 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754450Ab3EUXii (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 19:38:38 -0400
Received: from mailout-de.gmx.net ([10.1.76.33]) by mrigmx.server.lan
 (mrigmx001) with ESMTP (Nemesis) id 0MUSkP-1V6GPm0jqN-00RLaB for
 <netdev@vger.kernel.org>; Wed, 22 May 2013 01:38:37 +0200
In-Reply-To: <1369176146-19383-1-git-send-email-peterhuewe@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removing some boilerplate by using module_pci_driver instead of calling
register and unregister in the otherwise empty init/exit functions.

The name of the pci_driver struct had to be changed in order to prevent
a build failure.

Signed-off-by: Peter Huewe <peterhuewe@gmx.de>
---
 drivers/net/ethernet/nvidia/forcedeth.c | 17 ++---------------
 1 file changed, 2 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index b003fe5..098b96d 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -6340,7 +6340,7 @@ static DEFINE_PCI_DEVICE_TABLE(pci_tbl) = {
 	{0,},
 };
 
-static struct pci_driver driver = {
+static struct pci_driver forcedeth_pci_driver = {
 	.name		= DRV_NAME,
 	.id_table	= pci_tbl,
 	.probe		= nv_probe,
@@ -6349,16 +6349,6 @@ static struct pci_driver driver = {
 	.driver.pm	= NV_PM_OPS,
 };
 
-static int __init init_nic(void)
-{
-	return pci_register_driver(&driver);
-}
-
-static void __exit exit_nic(void)
-{
-	pci_unregister_driver(&driver);
-}
-
 module_param(max_interrupt_work, int, 0);
 MODULE_PARM_DESC(max_interrupt_work, "forcedeth maximum events handled per interrupt");
 module_param(optimization_mode, int, 0);
@@ -6379,11 +6369,8 @@ module_param(debug_tx_timeout, bool, 0);
 MODULE_PARM_DESC(debug_tx_timeout,
 		 "Dump tx related registers and ring when tx_timeout happens");
 
+module_pci_driver(forcedeth_pci_driver);
 MODULE_AUTHOR("Manfred Spraul <manfred@colorfullife.com>");
 MODULE_DESCRIPTION("Reverse Engineered nForce ethernet driver");
 MODULE_LICENSE("GPL");
-
 MODULE_DEVICE_TABLE(pci, pci_tbl);
-
-module_init(init_nic);
-module_exit(exit_nic);
-- 
1.8.1.5
