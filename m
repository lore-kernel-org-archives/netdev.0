From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH] rmmod pcnet32 OOPS with 2.6.0-test10
Date: Wed, 26 Nov 2003 10:49:09 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311261849.hAQIn9V10044@dyn318364bld.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When trying to rmmod pcnet32 multiple pci_unregister_driver calls causes
a null pointer to be dereferenced.  Fix tested with 2.6.0-test10-bk2.


--- linux-2.6.0-test10-bk2/drivers/net/pcnet32.c	Sun Nov 23 17:31:27 2003
+++ linux-2.6.0-test10-bk2p/drivers/net/pcnet32.c	Wed Nov 26 10:40:35 2003
@@ -1766,8 +1766,6 @@
 	next_dev = lp->next;
 	unregister_netdev(pcnet32_dev);
 	release_region(pcnet32_dev->base_addr, PCNET32_TOTAL_SIZE);
-	if (lp->pci_dev)
-	    pci_unregister_driver(&pcnet32_driver);
 	pci_free_consistent(lp->pci_dev, sizeof(*lp), lp, lp->dma_addr);
 	free_netdev(pcnet32_dev);
 	pcnet32_dev = next_dev;

-- 
Don Fry
brazilnut@us.ibm.com
