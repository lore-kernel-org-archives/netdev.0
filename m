From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH 3/9] staging: slicoss: ensure mapping of io-memory is uncached
Date: Fri, 22 Jul 2016 23:09:13 +0200
Message-ID: <1469221759-17652-4-git-send-email-LinoSanfilippo@gmx.de>
References: <1469221759-17652-1-git-send-email-LinoSanfilippo@gmx.de>
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Lino Sanfilippo <lsanfil@marvell.com>,
	Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: liodot@gmail.com, charrer@alacritech.com,
	gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469221759-17652-1-git-send-email-LinoSanfilippo@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lino Sanfilippo <lsanfil@marvell.com>

Writes to registers should be done uncached for various reasons. Ensure
this by replacing ioremap() with ioremap_nocache().

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/staging/slicoss/slicoss.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/slicoss/slicoss.c b/drivers/staging/slicoss/slicoss.c
index a9323a9..4dba080 100644
--- a/drivers/staging/slicoss/slicoss.c
+++ b/drivers/staging/slicoss/slicoss.c
@@ -3136,7 +3136,7 @@ static int slic_entry_probe(struct pci_dev *pcidev,
 	mmio_start = pci_resource_start(pcidev, 0);
 	mmio_len = pci_resource_len(pcidev, 0);
 
-	memmapped_ioaddr = ioremap(mmio_start, mmio_len);
+	memmapped_ioaddr = ioremap_nocache(mmio_start, mmio_len);
 	if (!memmapped_ioaddr) {
 		dev_err(&pcidev->dev, "cannot remap MMIO region %lx @ %lx\n",
 			mmio_len, mmio_start);
-- 
1.9.1
