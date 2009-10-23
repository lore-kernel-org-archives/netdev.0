From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 23/27] sfc: Remove unnecessary tests of efx->membase
Date: Fri, 23 Oct 2009 19:33:00 +0100
Message-ID: <1256322780.2785.49.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8939 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753003AbZJWSc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:32:58 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These cleanup functions will never be called if the MMIO region could
not be mapped.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index c925801..8fc6a6e 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -2022,10 +2022,6 @@ static void efx_fini_struct(struct efx_nic *efx)
  */
 static void efx_pci_remove_main(struct efx_nic *efx)
 {
-	/* Skip everything if we never obtained a valid membase */
-	if (!efx->membase)
-		return;
-
 	falcon_fini_interrupt(efx);
 	efx_fini_channels(efx);
 	efx_fini_port(efx);
@@ -2056,9 +2052,6 @@ static void efx_pci_remove(struct pci_dev *pci_dev)
 	/* Allow any queued efx_resets() to complete */
 	rtnl_unlock();
 
-	if (efx->membase == NULL)
-		goto out;
-
 	efx_unregister_netdev(efx);
 
 	efx_mtd_remove(efx);
@@ -2071,7 +2064,6 @@ static void efx_pci_remove(struct pci_dev *pci_dev)
 
 	efx_pci_remove_main(efx);
 
-out:
 	efx_fini_io(efx);
 	EFX_LOG(efx, "shutdown successful\n");
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

