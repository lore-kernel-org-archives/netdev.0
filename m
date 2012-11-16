From: Simon Marchi <simon.marchi@polymtl.ca>
Subject: [PATCH] tilegx: request_irq with a non-null device name
Date: Thu, 15 Nov 2012 23:13:19 -0500
Message-ID: <1353039199-12520-1-git-send-email-simon.marchi@polymtl.ca>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	cmetcalf@tilera.com, Simon Marchi <simon.marchi@polymtl.ca>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch simply makes the tilegx net driver call request_irq with a
non-null name. It makes the output in /proc/interrupts more obvious, but
also helps tools that don't expect to find null there.

Signed-off-by: Simon Marchi <simon.marchi@polymtl.ca>
Acked-by: Chris Metcalf <cmetcalf@tilera.com>
---
I am not sure if this patch will get picked up directly by David Miller
of it should go through Chris Metcalf's tree first. Hopefully it is
simple enough that it can get merged directly.

 drivers/net/ethernet/tile/tilegx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 4e98100..66e025a 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -917,7 +917,7 @@ static int tile_net_setup_interrupts(struct net_device *dev)
 	ingress_irq = rc;
 	tile_irq_activate(ingress_irq, TILE_IRQ_PERCPU);
 	rc = request_irq(ingress_irq, tile_net_handle_ingress_irq,
-			 0, NULL, NULL);
+			 0, "tile_net", NULL);
 	if (rc != 0) {
 		netdev_err(dev, "request_irq failed: %d\n", rc);
 		destroy_irq(ingress_irq);
-- 
1.7.1
