From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 04/17] bnx2x: Use
 netif_set_real_num_{rx,tx}_queues()
Date: Mon, 27 Sep 2010 19:25:27 +0100
Message-ID: <1285611927.2263.296.camel@achroite.uk.solarflarecom.com>
References: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Eilon Greenstein <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51155 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757174Ab0I0SZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 14:25:31 -0400
In-Reply-To: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index efc7be4..05c05a4 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -1207,8 +1207,8 @@ static int bnx2x_set_num_queues(struct bnx2x *bp)
 			bp->num_queues = 1;
 		break;
 	}
-	bp->dev->real_num_tx_queues = bp->num_queues;
-	return rc;
+	netif_set_real_num_tx_queues(bp->dev, bp->num_queues);
+	return netif_set_real_num_rx_queues(bp->dev, bp->num_queues);
 }
 
 static void bnx2x_release_firmware(struct bnx2x *bp)
@@ -1240,6 +1240,8 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	bp->state = BNX2X_STATE_OPENING_WAIT4_LOAD;
 
 	rc = bnx2x_set_num_queues(bp);
+	if (rc)
+		return rc;
 
 	if (bnx2x_alloc_mem(bp)) {
 		bnx2x_free_irq(bp, true);
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

