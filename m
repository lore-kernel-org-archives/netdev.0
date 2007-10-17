From: Badari Pulavarty <pbadari@us.ibm.com>
Subject: [PATCH] vortex_up should initialize "err"
Date: Wed, 17 Oct 2007 16:15:56 -0700
Message-ID: <1192662956.14504.14.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:47591 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755570AbXJQXMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 19:12:36 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simple compile warning fix. (against 2.6.23-git12)

Thanks,
Badari

vortex_up() should initialize 'err' for a successful return.

drivers/net/3c59x.c: In function `vortex_up':
drivers/net/3c59x.c:1494: warning: `err' might be used uninitialized in this function


Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
---
 drivers/net/3c59x.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.23/drivers/net/3c59x.c
===================================================================
--- linux-2.6.23.orig/drivers/net/3c59x.c	2007-10-17 15:33:07.000000000 -0700
+++ linux-2.6.23/drivers/net/3c59x.c	2007-10-17 16:07:10.000000000 -0700
@@ -1491,7 +1491,7 @@ vortex_up(struct net_device *dev)
 	struct vortex_private *vp = netdev_priv(dev);
 	void __iomem *ioaddr = vp->ioaddr;
 	unsigned int config;
-	int i, mii_reg1, mii_reg5, err;
+	int i, mii_reg1, mii_reg5, err = 0;
 
 	if (VORTEX_PCI(vp)) {
 		pci_set_power_state(VORTEX_PCI(vp), PCI_D0);	/* Go active */


