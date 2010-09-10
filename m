From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 04/10] sfc: Fix failure paths in
 efx_probe_port()
Date: Fri, 10 Sep 2010 17:41:19 +0100
Message-ID: <1284136879.2267.98.camel@achroite.uk.solarflarecom.com>
References: <1284136817.2267.93.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:25582 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755840Ab0IJQlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 12:41:23 -0400
In-Reply-To: <1284136817.2267.93.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index b385f89..a576045 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -761,7 +761,7 @@ static int efx_probe_port(struct efx_nic *efx)
 	/* Connect up MAC/PHY operations table */
 	rc = efx->type->probe_port(efx);
 	if (rc)
-		goto err;
+		return rc;
 
 	/* Sanity check MAC address */
 	if (is_valid_ether_addr(efx->mac_address)) {
@@ -782,7 +782,7 @@ static int efx_probe_port(struct efx_nic *efx)
 	return 0;
 
  err:
-	efx_remove_port(efx);
+	efx->type->remove_port(efx);
 	return rc;
 }
 
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

