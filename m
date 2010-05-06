From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: emaclite: Use resource_size
Date: Thu,  6 May 2010 10:12:20 +0200
Message-ID: <1273133540-6894-1-git-send-email-tklauser@distanz.ch>
Cc: john.linn@xilinx.com, kernel-janitors@vger.kernel.org,
	Tobias Klauser <tklauser@distanz.ch>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:57723 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753270Ab0EFIUo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 May 2010 04:20:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the resource_size function instead of manually calculating the
resource size.  This reduces the chance of introducing off-by-one
errors.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/xilinx_emaclite.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emaclite.c
index e9381fe..93828d5 100644
--- a/drivers/net/xilinx_emaclite.c
+++ b/drivers/net/xilinx_emaclite.c
@@ -1171,7 +1171,7 @@ static int __devinit xemaclite_of_probe(struct of_device *ofdev,
 	}
 
 	/* Get the virtual base address for the device */
-	lp->base_addr = ioremap(r_mem.start, r_mem.end - r_mem.start + 1);
+	lp->base_addr = ioremap(r_mem.start, resource_size(&r_mem));
 	if (NULL == lp->base_addr) {
 		dev_err(dev, "EmacLite: Could not allocate iomem\n");
 		rc = -EIO;
@@ -1224,7 +1224,7 @@ static int __devinit xemaclite_of_probe(struct of_device *ofdev,
 	return 0;
 
 error1:
-	release_mem_region(ndev->mem_start, r_mem.end - r_mem.start + 1);
+	release_mem_region(ndev->mem_start, resource_size(&r_mem));
 
 error2:
 	xemaclite_remove_ndev(ndev);
-- 
1.6.3.3

