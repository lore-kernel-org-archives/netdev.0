From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 8/9] Increment rx_reset when reported as driver event
Date: Wed, 7 May 2008 13:00:39 +0100
Message-ID: <20080507120039.GT2217@solarflare.com>
References: <20080507114121.GL2217@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:55770 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755306AbYEGMBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 08:01:09 -0400
Content-Disposition: inline
In-Reply-To: <20080507114121.GL2217@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An RX_RESET event can be reported either as a global or as a driver event.
We were counting only global events.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 9cac344..247629c 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1129,6 +1129,7 @@ static void falcon_handle_driver_event(struct efx_channel *channel,
 	case RX_RECOVERY_EV_DECODE:
 		EFX_ERR(efx, "channel %d seen DRIVER RX_RESET event. "
 			"Resetting.\n", channel->channel);
+		atomic_inc(&efx->rx_reset);
 		efx_schedule_reset(efx,
 				   EFX_WORKAROUND_6555(efx) ?
 				   RESET_TYPE_RX_RECOVERY :

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
