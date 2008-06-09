From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] sfc: Recover from RX queue flush failure
Date: Mon, 9 Jun 2008 19:34:32 +0100
Message-ID: <20080609183431.GL11300@solarflare.com>
References: <cover.1213035645.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:60459 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753014AbYFISfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 14:35:34 -0400
Content-Disposition: inline
In-Reply-To: <cover.1213035645.git.bhutchings@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

RX queue flush can fail if traffic continues to arrive.  Recover by
performing an invisible reset.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index cbe2e83..f2d361f 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -842,8 +842,10 @@ void falcon_fini_rx(struct efx_rx_queue *rx_queue)
 			continue;
 		break;
 	}
-	if (rc)
+	if (rc) {
 		EFX_ERR(efx, "failed to flush rx queue %d\n", rx_queue->queue);
+		efx_schedule_reset(efx, RESET_TYPE_INVISIBLE);
+	}
 
 	/* Remove RX descriptor ring from card */
 	EFX_ZERO_OWORD(rx_desc_ptr);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
