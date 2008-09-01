From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 39/52] sfc: Remove the STATE_RESETTING flag
Date: Mon, 1 Sep 2008 12:49:08 +0100
Message-ID: <20080901114907.GG7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:36091 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759014AbYIALtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:49:12 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was originally a kludge to fix broken locking, which has since
been fixed properly.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |    5 +----
 drivers/net/sfc/net_driver.h |    3 +--
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index e1e2f80..d593086 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -140,8 +140,7 @@ static void efx_fini_channels(struct efx_nic *efx);
 
 #define EFX_ASSERT_RESET_SERIALISED(efx)		\
 	do {						\
-		if ((efx->state == STATE_RUNNING) ||	\
-		    (efx->state == STATE_RESETTING))	\
+		if (efx->state == STATE_RUNNING)	\
 			ASSERT_RTNL();			\
 	} while (0)
 
@@ -1615,7 +1614,6 @@ static int efx_reset(struct efx_nic *efx)
 		goto unlock_rtnl;
 	}
 
-	efx->state = STATE_RESETTING;
 	EFX_INFO(efx, "resetting (%d)\n", method);
 
 	efx_reset_down(efx, &ecmd);
@@ -1646,7 +1644,6 @@ static int efx_reset(struct efx_nic *efx)
 		goto disable;
 
 	EFX_LOG(efx, "reset complete\n");
-	efx->state = STATE_RUNNING;
  unlock_rtnl:
 	rtnl_unlock();
 	return 0;
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 531d939..567df00 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -459,8 +459,7 @@ enum nic_state {
 	STATE_INIT = 0,
 	STATE_RUNNING = 1,
 	STATE_FINI = 2,
-	STATE_RESETTING = 3, /* rtnl_lock always held */
-	STATE_DISABLED = 4,
+	STATE_DISABLED = 3,
 	STATE_MAX,
 };
 
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

