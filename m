From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net] sfc: don't BUG_ON efx->max_channels == 0 in probe
Date: Mon, 3 Nov 2014 14:14:35 +0000
Message-ID: <alpine.LFD.2.03.1411031409100.24185@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: <netdev@vger.kernel.org>, <sshah@solarflare.com>,
	<linux-net-drivers@solarflare.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:1158 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750816AbaKCOOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 09:14:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_ef10_probe() was BUGging out if the BAR2 size was 0.  This is
 unnecessarily violent; instead we should just fail to probe the device.
Kept a WARN_ON as this problem indicates a broken or misconfigured NIC.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 002d4cd..a77f05c 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -180,7 +180,8 @@ static int efx_ef10_probe(struct efx_nic *efx)
 		      EFX_MAX_CHANNELS,
 		      resource_size(&efx->pci_dev->resource[EFX_MEM_BAR]) /
 		      (EFX_VI_PAGE_SIZE * EFX_TXQ_TYPES));
-	BUG_ON(efx->max_channels == 0);
+	if (WARN_ON(efx->max_channels == 0))
+		return -EIO;
 
 	nic_data = kzalloc(sizeof(*nic_data), GFP_KERNEL);
 	if (!nic_data)
-- 
1.7.11.7
