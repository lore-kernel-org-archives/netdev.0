From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 2/2] atm: solos-pci: remove unnecessary pci_set_drvdata()
Date: Mon, 25 Nov 2013 12:33:33 +0900
Message-ID: <002901cee98f$1e067d60$5a137820$%han@samsung.com>
References: <002801cee98e$d93e9c30$8bbbd490$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Chas Williams' <chas@cmf.nrl.navy.mil>, netdev@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	'Jingoo Han' <jg1.han@samsung.com>,
	'Nathan Williams' <nathan@traverse.com.au>,
	'David Woodhouse' <David.Woodhouse@intel.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:30881 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753366Ab3KYDdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Nov 2013 22:33:35 -0500
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MWS008CVV7X4K80@mailout2.samsung.com> for
 netdev@vger.kernel.org; Mon, 25 Nov 2013 12:33:33 +0900 (KST)
In-reply-to: <002801cee98e$d93e9c30$8bbbd490$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/atm/solos-pci.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 32784d1..e3fb496 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -1335,7 +1335,6 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 	
  out_unmap_both:
 	kfree(card->dma_bounce);
-	pci_set_drvdata(dev, NULL);
 	pci_iounmap(dev, card->buffers);
  out_unmap_config:
 	pci_iounmap(dev, card->config_regs);
@@ -1457,7 +1456,6 @@ static void fpga_remove(struct pci_dev *dev)
 	pci_release_regions(dev);
 	pci_disable_device(dev);
 
-	pci_set_drvdata(dev, NULL);
 	kfree(card);
 }
 
-- 
1.7.10.4
