From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6 1/2] sfc: Fix sign of efx_mcdi_poll_reboot() error
 in efx_mcdi_poll()
Date: Fri, 19 Feb 2010 23:29:27 +0000
Message-ID: <1266622168.2091.5.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:22504 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756267Ab0BSX3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 18:29:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_mcdi_poll() uses positive error numbers, matching the MCDI
protocol.  It must negate the result of efx_mcdi_poll_reboot() which
returns the usual negative error numbers.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mcdi.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/mcdi.c b/drivers/net/sfc/mcdi.c
index 9f035b9..f66b3da 100644
--- a/drivers/net/sfc/mcdi.c
+++ b/drivers/net/sfc/mcdi.c
@@ -127,7 +127,7 @@ static int efx_mcdi_poll(struct efx_nic *efx)
 	efx_dword_t reg;
 
 	/* Check for a reboot atomically with respect to efx_mcdi_copyout() */
-	rc = efx_mcdi_poll_reboot(efx);
+	rc = -efx_mcdi_poll_reboot(efx);
 	if (rc)
 		goto out;
 
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

