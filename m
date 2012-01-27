From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 02/32] sfc: Avoid assignment in an if-statement,
 reported by checkpatch
Date: Fri, 27 Jan 2012 20:42:40 +0000
Message-ID: <1327696960.2503.9.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:63471 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752114Ab2A0Umn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:42:43 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the following error:

ERROR: do not use assignment in if condition

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 11cc585..0539a8d 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1069,9 +1069,11 @@ static int efx_init_io(struct efx_nic *efx)
 	 * masks event though they reject 46 bit masks.
 	 */
 	while (dma_mask > 0x7fffffffUL) {
-		if (pci_dma_supported(pci_dev, dma_mask) &&
-		    ((rc = pci_set_dma_mask(pci_dev, dma_mask)) == 0))
-			break;
+		if (pci_dma_supported(pci_dev, dma_mask)) {
+			rc = pci_set_dma_mask(pci_dev, dma_mask);
+			if (rc == 0)
+				break;
+		}
 		dma_mask >>= 1;
 	}
 	if (rc) {
-- 
1.7.7.5



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
