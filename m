From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 03/17] bnx2: Use
 netif_set_real_num_{rx,tx}_queues()
Date: Mon, 27 Sep 2010 19:25:16 +0100
Message-ID: <1285611916.2263.295.camel@achroite.uk.solarflarecom.com>
References: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Michael Chan <mchan@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51124 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933058Ab0I0SZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 14:25:19 -0400
In-Reply-To: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/bnx2.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 3d1a5da..b10be27 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6202,7 +6202,7 @@ bnx2_enable_msix(struct bnx2 *bp, int msix_vecs)
 	}
 }
 
-static void
+static int
 bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
 {
 	int cpus = num_online_cpus();
@@ -6231,9 +6231,10 @@ bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
 	}
 
 	bp->num_tx_rings = rounddown_pow_of_two(bp->irq_nvecs);
-	bp->dev->real_num_tx_queues = bp->num_tx_rings;
+	netif_set_real_num_tx_queues(bp->dev, bp->num_tx_rings);
 
 	bp->num_rx_rings = bp->irq_nvecs;
+	return netif_set_real_num_rx_queues(bp->dev, bp->num_rx_rings);
 }
 
 /* Called with rtnl_lock */
@@ -6248,7 +6249,9 @@ bnx2_open(struct net_device *dev)
 	bnx2_set_power_state(bp, PCI_D0);
 	bnx2_disable_int(bp);
 
-	bnx2_setup_int_mode(bp, disable_msi);
+	rc = bnx2_setup_int_mode(bp, disable_msi);
+	if (rc)
+		goto open_err;
 	bnx2_init_napi(bp);
 	bnx2_napi_enable(bp);
 	rc = bnx2_alloc_mem(bp);
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

