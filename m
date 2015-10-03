From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 07/15] cx23885: use pci_set_dma_mask insted of pci_dma_supported
Date: Sat,  3 Oct 2015 17:19:31 +0200
Message-ID: <1443885579-7094-8-git-send-email-hch@lst.de>
References: <1443885579-7094-1-git-send-email-hch@lst.de>
Cc: linux-net-drivers@solarflare.com, dri-devel@lists.freedesktop.org,
	linux-media@vger.kernel.org, netdev@vger.kernel.org,
	linux-parisc@vger.kernel.org, linux-serial@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Don Fry <pcnet32@frontier.com>,
	Oliver Neukum <oneukum@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:51243 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005AbbJCPX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2015 11:23:56 -0400
In-Reply-To: <1443885579-7094-1-git-send-email-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This ensures the dma mask that is supported by the driver is recorded
in the device structure.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/media/pci/cx23885/cx23885-core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/media/pci/cx23885/cx23885-core.c b/drivers/media/pci/cx23885/cx23885-core.c
index 7aee76a..8194052 100644
--- a/drivers/media/pci/cx23885/cx23885-core.c
+++ b/drivers/media/pci/cx23885/cx23885-core.c
@@ -1990,7 +1990,7 @@ static int cx23885_initdev(struct pci_dev *pci_dev,
 		(unsigned long long)pci_resource_start(pci_dev, 0));
 
 	pci_set_master(pci_dev);
-	if (!pci_dma_supported(pci_dev, 0xffffffff)) {
+	if (!pci_set_dma_mask(pci_dev, 0xffffffff)) {
 		printk("%s/0: Oops: no 32bit PCI DMA ???\n", dev->name);
 		err = -EIO;
 		goto fail_context;
-- 
1.9.1
