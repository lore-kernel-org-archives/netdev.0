From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH -mm v2 1/5] ssb: add dma_dev to ssb_device structure
Date: Tue, 16 Feb 2010 00:04:06 +0900
Message-ID: <1266246250-5344-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
References: <1266246250-5344-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	fujita.tomonori@lab.ntt.co.jp, davem@davemloft.net,
	Michael Buesch <mb@bu3sch.de>,
	Gary Zambrano <zambrano@broadcom.com>,
	Stefano Brivio <stefano.brivio@polimi.it>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	"John W. Linville" <linville@tuxdriver.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:38258 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755288Ab0BOPK0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2010 10:10:26 -0500
In-Reply-To: <1266246250-5344-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add dma_dev, a pointer to struct device, to struct ssb_device. We pass
it to the generic DMA API with SSB_BUSTYPE_PCI and
SSB_BUSTYPE_SSB. ssb_devices_register() sets up it properly.

This is preparation for replacing the ssb bus specific DMA API
(ssb_dma_*) with the generic DMA API.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: Michael Buesch <mb@bu3sch.de>
Cc: Gary Zambrano <zambrano@broadcom.com>
Cc: Stefano Brivio <stefano.brivio@polimi.it>
Cc: Larry Finger <Larry.Finger@lwfinger.net>
Cc: John W. Linville <linville@tuxdriver.com>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/ssb/main.c      |    2 ++
 include/linux/ssb/ssb.h |    2 +-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
index 5681ebe..1a41b3f 100644
--- a/drivers/ssb/main.c
+++ b/drivers/ssb/main.c
@@ -485,6 +485,7 @@ static int ssb_devices_register(struct ssb_bus *bus)
 #ifdef CONFIG_SSB_PCIHOST
 			sdev->irq = bus->host_pci->irq;
 			dev->parent = &bus->host_pci->dev;
+			sdev->dma_dev = dev->parent;
 #endif
 			break;
 		case SSB_BUSTYPE_PCMCIA:
@@ -501,6 +502,7 @@ static int ssb_devices_register(struct ssb_bus *bus)
 			break;
 		case SSB_BUSTYPE_SSB:
 			dev->dma_mask = &dev->coherent_dma_mask;
+			sdev->dma_dev = dev;
 			break;
 		}
 
diff --git a/include/linux/ssb/ssb.h b/include/linux/ssb/ssb.h
index 24f9885..c5e00b2 100644
--- a/include/linux/ssb/ssb.h
+++ b/include/linux/ssb/ssb.h
@@ -167,7 +167,7 @@ struct ssb_device {
 	 * is an optimization. */
 	const struct ssb_bus_ops *ops;
 
-	struct device *dev;
+	struct device *dev, *dma_dev;
 
 	struct ssb_bus *bus;
 	struct ssb_device_id id;
-- 
1.6.5

