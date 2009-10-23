From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 14/27] sfc: Change order of device removal to reverse of
	probe order
Date: Fri, 23 Oct 2009 19:31:37 +0100
Message-ID: <1256322697.2785.31.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8779 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930AbZJWSbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:31:35 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes efx_pci_remove_main() more obviously the inverse of
efx_pci_probe_main(), and matches our out-of-tree driver.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 8b67553..862e483 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -2025,12 +2025,12 @@ static void efx_pci_remove_main(struct efx_nic *efx)
 	if (!efx->membase)
 		return;
 
+	falcon_fini_interrupt(efx);
 	efx_fini_channels(efx);
 	efx_fini_port(efx);
 
 	/* Shutdown the board, then the NIC and board state */
 	efx->board_info.fini(efx);
-	falcon_fini_interrupt(efx);
 
 	efx_fini_napi(efx);
 	efx_remove_all(efx);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

