From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 9/9] sfc: Improve test for IOMMU in use
Date: Mon, 24 Jun 2013 21:15:23 +0100
Message-ID: <1372104923.1896.38.camel@bwh-desktop.uk.level5networks.com>
References: <1372104708.1896.29.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Alex Williamson" <alex.williamson@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17359 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505Ab3FXUP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 16:15:27 -0400
In-Reply-To: <1372104708.1896.29.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device::iommu_group field may be set even if no IOMMU is in use.
iommu_present() is still a better indicator, although it doesn't tell
us whether *our* device is affected.

Reported-by: Alex Williamson <alex.williamson@redhat.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/rx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 5c45118..65646cd 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -677,7 +677,7 @@ static void efx_init_rx_recycle_ring(struct efx_nic *efx,
 #ifdef CONFIG_PPC64
 	bufs_in_recycle_ring = EFX_RECYCLE_RING_SIZE_IOMMU;
 #else
-	if (efx->pci_dev->dev.iommu_group)
+	if (iommu_present(&pci_bus_type))
 		bufs_in_recycle_ring = EFX_RECYCLE_RING_SIZE_IOMMU;
 	else
 		bufs_in_recycle_ring = EFX_RECYCLE_RING_SIZE_NOIOMMU;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
