From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 01/17] sfc: Reduce log level for MCDI error
 response in efx_mcdi_rpc()
Date: Thu, 02 Dec 2010 23:46:09 +0000
Message-ID: <1291333569.3259.24.camel@bwh-desktop>
References: <1291333490.3259.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:12949 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757178Ab0LBXqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 18:46:12 -0500
In-Reply-To: <1291333490.3259.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some errors are expected, e.g. when sending new commands to an MC
running old firmware.  Only the caller of efx_mcdi_rpc() can decide
what is a real error.  Therefore log the error responses with
netif_dbg().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mcdi.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/mcdi.c b/drivers/net/sfc/mcdi.c
index 12cf910..e389ac6 100644
--- a/drivers/net/sfc/mcdi.c
+++ b/drivers/net/sfc/mcdi.c
@@ -381,7 +381,7 @@ int efx_mcdi_rpc(struct efx_nic *efx, unsigned cmd,
 				  -rc);
 			efx_schedule_reset(efx, RESET_TYPE_MC_FAILURE);
 		} else
-			netif_err(efx, hw, efx->net_dev,
+			netif_dbg(efx, hw, efx->net_dev,
 				  "MC command 0x%x inlen %d failed rc=%d\n",
 				  cmd, (int)inlen, -rc);
 	}
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

