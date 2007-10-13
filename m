From: Florin Malita <fmalita@gmail.com>
Subject: [PATCH] tehuti: possible leak in bdx_probe
Date: Sat, 13 Oct 2007 13:03:38 -0400
Message-ID: <4710FA6A.2070902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: baum@tehutinetworks.net, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.225]:12111 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944AbXJMRFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2007 13:05:30 -0400
Received: by wr-out-0506.google.com with SMTP id 36so652521wra
        for <netdev@vger.kernel.org>; Sat, 13 Oct 2007 10:05:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If pci_enable_device fails, bdx_probe returns without freeing the 
allocated pci_nic structure.

Coverity CID 1908.

Signed-off-by: Florin Malita <fmalita@gmail.com>
---

 drivers/net/tehuti.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 8d04654..4e1b84e 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -1906,7 +1906,7 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
     /************** pci *****************/
 	if ((err = pci_enable_device(pdev)))	/* it trigers interrupt, dunno why. */
-		RET(err);			/* it's not a problem though */
+		goto err_pci;			/* it's not a problem though */
 
 	if (!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK)) &&
 	    !(err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK))) {
@@ -2076,6 +2076,7 @@ err_out_res:
 	pci_release_regions(pdev);
 err_dma:
 	pci_disable_device(pdev);
+err_pci:
 	vfree(nic);
 
 	RET(err);

