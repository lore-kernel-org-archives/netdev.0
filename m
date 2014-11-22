From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 4/6] solos-pci: fix error return code
Date: Sat, 22 Nov 2014 15:39:17 +0100
Message-ID: <1416667159-9808-5-git-send-email-Julia.Lawall@lip6.fr>
References: <1416667159-9808-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chas Williams <chas@cmf.nrl.navy.mil>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416667159-9808-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Return a negative error code on failure.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
identifier ret; expression e1,e2;
@@
(
if (\(ret < 0\|ret != 0\))
 { ... return ret; }
|
ret = 0
)
... when != ret = e1
    when != &ret
*if(...)
{
  ... when != ret = e2
      when forall
 return ret;
}
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/atm/solos-pci.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 7652e8d..21b0bc6 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -1225,11 +1225,13 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 	card->config_regs = pci_iomap(dev, 0, CONFIG_RAM_SIZE);
 	if (!card->config_regs) {
 		dev_warn(&dev->dev, "Failed to ioremap config registers\n");
+		err = -ENOMEM;
 		goto out_release_regions;
 	}
 	card->buffers = pci_iomap(dev, 1, DATA_RAM_SIZE);
 	if (!card->buffers) {
 		dev_warn(&dev->dev, "Failed to ioremap data buffers\n");
+		err = -ENOMEM;
 		goto out_unmap_config;
 	}
 
