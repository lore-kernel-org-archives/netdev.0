From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH] drivers/atm/solos-pci.c: exchange pci_iounmaps
Date: Sun, 19 Feb 2012 20:43:32 +0100
Message-ID: <1329680612-28055-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chas Williams <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

The calls to pci_iounmap are in the wrong order, as compared to the
associated calls to pci_iomap.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression e,x;
statement S,S1;
int ret;
@@
e = pci_iomap(x,...)
... when != pci_iounmap(x,e)
if (<+...e...+>) S
... when any
    when != pci_iounmap(x,e)
*if (...)
   { ... when != pci_iounmap(x,e)
     return ...; }
... when any
pci_iounmap(x,e);
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/atm/solos-pci.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 5d1d076..e8cd652 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -1206,9 +1206,9 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 	
  out_unmap_both:
 	pci_set_drvdata(dev, NULL);
-	pci_iounmap(dev, card->config_regs);
- out_unmap_config:
 	pci_iounmap(dev, card->buffers);
+ out_unmap_config:
+	pci_iounmap(dev, card->config_regs);
  out_release_regions:
 	pci_release_regions(dev);
  out:
