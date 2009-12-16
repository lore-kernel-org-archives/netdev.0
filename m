From: "Denis Kirjanov <kirjanov@gmail.com" <kirjanov@gmail.com>
Subject: [PATCH] vxge: use DMA_BIT_MASK instead of plain values.
Date: Wed, 16 Dec 2009 23:10:16 +0300
Message-ID: <20091216201016.GA9532@coldcone>
Reply-To: kirjanov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:57875 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762469AbZLPUIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 15:08:35 -0500
Received: by fxm21 with SMTP id 21so1288084fxm.21
        for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 12:08:32 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use DMA_BIT_MASK instead of plain values.

Signed-off-by: Denis Kirjanov <kirjanov@gmail.com>

---

drivers/net/vxge/vxge-main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index f1c4b2a..0fdfd58 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -4087,21 +4087,21 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 		goto _exit0;
 	}
 
-	if (!pci_set_dma_mask(pdev, 0xffffffffffffffffULL)) {
+	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		vxge_debug_ll_config(VXGE_TRACE,
 			"%s : using 64bit DMA", __func__);
 
 		high_dma = 1;
 
 		if (pci_set_consistent_dma_mask(pdev,
-						0xffffffffffffffffULL)) {
+						DMA_BIT_MASK(64))) {
 			vxge_debug_init(VXGE_ERR,
 				"%s : unable to obtain 64bit DMA for "
 				"consistent allocations", __func__);
 			ret = -ENOMEM;
 			goto _exit1;
 		}
-	} else if (!pci_set_dma_mask(pdev, 0xffffffffUL)) {
+	} else if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
 		vxge_debug_ll_config(VXGE_TRACE,
 			"%s : using 32bit DMA", __func__);
 	} else {
