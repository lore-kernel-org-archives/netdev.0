From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 01/16] sfc: Use mod_timer() to set expiry and add_timer() together
Date: Fri, 16 May 2008 21:13:57 +0100
Message-ID: <20080516201357.GT28241@solarflare.com>
References: <20080516201005.GS28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:53500 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753343AbYEPUO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 16:14:57 -0400
Content-Disposition: inline
In-Reply-To: <20080516201005.GS28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/boards.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sfc/boards.c b/drivers/net/sfc/boards.c
index eecaa6d..7fc0328 100644
--- a/drivers/net/sfc/boards.c
+++ b/drivers/net/sfc/boards.c
@@ -27,10 +27,8 @@ static void blink_led_timer(unsigned long context)
 	struct efx_blinker *bl = &efx->board_info.blinker;
 	efx->board_info.set_fault_led(efx, bl->state);
 	bl->state = !bl->state;
-	if (bl->resubmit) {
-		bl->timer.expires = jiffies + BLINK_INTERVAL;
-		add_timer(&bl->timer);
-	}
+	if (bl->resubmit)
+		mod_timer(&bl->timer, jiffies + BLINK_INTERVAL);
 }
 
 static void board_blink(struct efx_nic *efx, int blink)
@@ -44,8 +42,7 @@ static void board_blink(struct efx_nic *efx, int blink)
 		blinker->state = 0;
 		setup_timer(&blinker->timer, blink_led_timer,
 			    (unsigned long)efx);
-		blinker->timer.expires = jiffies + BLINK_INTERVAL;
-		add_timer(&blinker->timer);
+		mod_timer(&blinker->timer, jiffies + BLINK_INTERVAL);
 	} else {
 		blinker->resubmit = 0;
 		if (blinker->timer.function)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
