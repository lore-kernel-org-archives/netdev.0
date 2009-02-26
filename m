From: Maciej Sosnowski <maciej.sosnowski@intel.com>
Subject: [PATCH 4/7] I/OAT: cancel watchdog before dma remove
Date: Thu, 26 Feb 2009 11:05:07 +0100
Message-ID: <20090226100502.3615.19068.stgit@linux.site>
References: <20090226100327.3615.21419.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snakebyte@gmx.de, shannon.nelson@intel.com,
	jeffrey.t.krisher@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4674 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756192AbZBZKNu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 05:13:50 -0500
In-Reply-To: <20090226100327.3615.21419.stgit@linux.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Channel watchdog should be canceled before the rest of dma remove stuff.

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Jeff Kirsher <jeffrey.t.krisher@intel.com>
---

 drivers/dma/ioat_dma.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/dma/ioat_dma.c b/drivers/dma/ioat_dma.c
index 9012da7..fc9b845 100644
--- a/drivers/dma/ioat_dma.c
+++ b/drivers/dma/ioat_dma.c
@@ -1705,6 +1705,9 @@ void ioat_dma_remove(struct ioatdma_devi
 	struct dma_chan *chan, *_chan;
 	struct ioat_dma_chan *ioat_chan;
 
+	if (device->version != IOAT_VER_3_0)
+		cancel_delayed_work(&device->work);
+
 	ioat_dma_remove_interrupts(device);
 
 	dma_async_device_unregister(&device->common);
@@ -1716,10 +1719,6 @@ void ioat_dma_remove(struct ioatdma_devi
 	pci_release_regions(device->pdev);
 	pci_disable_device(device->pdev);
 
-	if (device->version != IOAT_VER_3_0) {
-		cancel_delayed_work(&device->work);
-	}
-
 	list_for_each_entry_safe(chan, _chan,
 				 &device->common.channels, device_node) {
 		ioat_chan = to_ioat_chan(chan);

