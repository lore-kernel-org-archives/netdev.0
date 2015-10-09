From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH] pcnet32: fix a logic error with pci_set_dma_mask
Date: Fri,  9 Oct 2015 03:45:39 -0700
Message-ID: <c2a42526779ca29258fa84bff51f8d94ed9fcc28.1444415947.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Don Fry <pcnet32@frontier.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-11.163.com ([220.181.12.11]:45296 "EHLO m12-11.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757565AbbJIKqA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Oct 2015 06:46:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pcnet32 can't work on my machine recently. It says "architecture
does not support 32bit PCI busmaster DMA". There is a logic error
in it: pci_set_dma_mask() return 0 means return successfully.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 drivers/net/ethernet/amd/pcnet32.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index e2afabf..2d9d216 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -1500,7 +1500,7 @@ pcnet32_probe_pci(struct pci_dev *pdev, const struct pci_device_id *ent)
 		return -ENODEV;
 	}
 
-	if (!pci_set_dma_mask(pdev, PCNET32_DMA_MASK)) {
+	if (pci_set_dma_mask(pdev, PCNET32_DMA_MASK)) {
 		if (pcnet32_debug & NETIF_MSG_PROBE)
 			pr_err("architecture does not support 32bit PCI busmaster DMA\n");
 		return -ENODEV;
-- 
1.9.1
