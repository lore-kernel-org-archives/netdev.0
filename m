From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6 3/9] sfc: Always close net device at the end of a
 disabling reset
Date: Fri, 23 Apr 2010 23:25:42 +0100
Message-ID: <1272061542.5520.16.camel@achroite.uk.solarflarecom.com>
References: <1272061459.5520.15.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:46185 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753042Ab0DWWZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 18:25:46 -0400
In-Reply-To: <1272061459.5520.15.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a regression introduced by commit
eb9f6744cbfa97674c13263802259b5aa0034594 "sfc: Implement ethtool
reset operation".

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 6486657..649a264 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1861,6 +1861,7 @@ out:
 	}
 
 	if (disabled) {
+		dev_close(efx->net_dev);
 		EFX_ERR(efx, "has been disabled\n");
 		efx->state = STATE_DISABLED;
 	} else {
@@ -1884,8 +1885,7 @@ static void efx_reset_work(struct work_struct *data)
 	}
 
 	rtnl_lock();
-	if (efx_reset(efx, efx->reset_pending))
-		dev_close(efx->net_dev);
+	(void)efx_reset(efx, efx->reset_pending);
 	rtnl_unlock();
 }
 
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

