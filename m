From: Arjan van de Ven <arjan@infradead.org>
Subject: tiacx - don't use UTS_RELEASE
Date: Tue, 04 Jul 2006 11:07:59 +0200
Message-ID: <1152004080.3109.18.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:19346 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1750883AbWGDJIB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jul 2006 05:08:01 -0400
To: akpm@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

patch below removes the use of UTS_RELEASE from the tiacx driver; there
is absolutely no reason for a driver to print the kernel version or use
the UTS_RELEASE field; in addition this field changes all the time so
this causes spurious rebuilds..

Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>

---
 drivers/net/wireless/tiacx/pci.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6.17-mm4/drivers/net/wireless/tiacx/pci.c
===================================================================
--- linux-2.6.17-mm4.orig/drivers/net/wireless/tiacx/pci.c
+++ linux-2.6.17-mm4/drivers/net/wireless/tiacx/pci.c
@@ -1705,8 +1705,8 @@ acxpci_e_probe(struct pci_dev *pdev, con
 	/* acx_sem_unlock(adev); */
 
 	printk("acx "ACX_RELEASE": net device %s, driver compiled "
-		"against wireless extensions %d and Linux %s\n",
-		ndev->name, WIRELESS_EXT, UTS_RELEASE);
+		"against wireless extensions %d\n",
+		ndev->name, WIRELESS_EXT);
 
 #if CMD_DISCOVERY
 	great_inquisitor(adev);


