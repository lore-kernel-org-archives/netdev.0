From: Randy Dunlap <rdunlap@xenotime.net>
Subject: [PATCH -next] hippi: fix printk format in rrunner.c
Date: Mon, 16 Apr 2012 18:01:33 -0700
Message-ID: <4F8CC0ED.2000006@xenotime.net>
References: <20120416161121.261ba4e7e38989173accfb16@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, linux-hippi@sunsite.dk,
	Jes Sorensen <jes@trained-monkey.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120416161121.261ba4e7e38989173accfb16@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

Fix printk format warning (from i386 build):

drivers/net/hippi/rrunner.c:146:9: warning: format '%08llx' expects type 'long long unsigned int', but argument 3 has type 'resource_size_t'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
Cc: Jes Sorensen <jes@trained-monkey.org>
Cc:	linux-hippi@sunsite.dk
---
 drivers/net/hippi/rrunner.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- linux-next-20120416.orig/drivers/net/hippi/rrunner.c
+++ linux-next-20120416/drivers/net/hippi/rrunner.c
@@ -142,8 +142,9 @@ static int __devinit rr_init_one(struct
 	pci_set_master(pdev);
 
 	printk(KERN_INFO "%s: Essential RoadRunner serial HIPPI "
-	       "at 0x%08llx, irq %i, PCI latency %i\n", dev->name,
-	       pci_resource_start(pdev, 0), pdev->irq, pci_latency);
+	       "at 0x%llx, irq %i, PCI latency %i\n", dev->name,
+	       (unsigned long long)pci_resource_start(pdev, 0),
+	       pdev->irq, pci_latency);
 
 	/*
 	 * Remap the MMIO regs into kernel space.
