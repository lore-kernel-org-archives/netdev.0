From: Maciej Sosnowski <maciej.sosnowski@intel.com>
Subject: [PATCH 3/7] I/OAT: fail initialization on zero channels detection
Date: Thu, 26 Feb 2009 11:04:54 +0100
Message-ID: <20090226100446.3615.46026.stgit@linux.site>
References: <20090226100327.3615.21419.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snakebyte@gmx.de, shannon.nelson@intel.com,
	jeffrey.t.krisher@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42350 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756045AbZBZKNh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 05:13:37 -0500
In-Reply-To: <20090226100327.3615.21419.stgit@linux.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some systems with I/OAT ver.2 when DCA is disabled in BIOS
situations have been observed
that zero DMA channels are detected instead of four.
To avoid kernel panic driver should fail gracefully with appropriate message.

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Jeff Kirsher <jeffrey.t.krisher@intel.com>
---

 drivers/dma/ioat_dma.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/dma/ioat_dma.c b/drivers/dma/ioat_dma.c
index 879f4a0..9012da7 100644
--- a/drivers/dma/ioat_dma.c
+++ b/drivers/dma/ioat_dma.c
@@ -1659,6 +1659,13 @@ struct ioatdma_device *ioat_dma_probe(st
 		" %d channels, device version 0x%02x, driver version %s\n",
 		device->common.chancnt, device->version, IOAT_DMA_VERSION);
 
+	if (!device->common.chancnt) {
+		dev_err(&device->pdev->dev,
+			"Intel(R) I/OAT DMA Engine problem found: "
+			"zero channels detected\n");
+		goto err_setup_interrupts;
+	}
+
 	err = ioat_dma_setup_interrupts(device);
 	if (err)
 		goto err_setup_interrupts;

