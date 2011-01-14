From: Daniel Hellstrom <daniel@gaisler.com>
Subject: [PATCH 2/7 v2] GRETH: fix opening/closing
Date: Fri, 14 Jan 2011 14:02:38 +0100
Message-ID: <1295010163-2585-2-git-send-email-daniel@gaisler.com>
References: <1295010163-2585-1-git-send-email-daniel@gaisler.com>
Cc: netdev@vger.kernel.org, kristoffer@gaisler.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail175c2.megamailservers.com ([69.49.111.75]:57036 "EHLO
	mail175c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756847Ab1ANNCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 08:02:54 -0500
In-Reply-To: <1295010163-2585-1-git-send-email-daniel@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When NAPI is disabled there is no point in having IRQs enabled, TX/RX
should be off before clearing the TX/RX descriptor rings.

Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>
---
 drivers/net/greth.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index 1c2dbdb..b307696 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -356,6 +356,8 @@ static int greth_open(struct net_device *dev)
 		dev_dbg(&dev->dev, " starting queue\n");
 	netif_start_queue(dev);
 
+	GRETH_REGSAVE(greth->regs->status, 0xFF);
+
 	napi_enable(&greth->napi);
 
 	greth_enable_irqs(greth);
@@ -371,7 +373,9 @@ static int greth_close(struct net_device *dev)
 
 	napi_disable(&greth->napi);
 
+	greth_disable_irqs(greth);
 	greth_disable_tx(greth);
+	greth_disable_rx(greth);
 
 	netif_stop_queue(dev);
 
-- 
1.5.4

