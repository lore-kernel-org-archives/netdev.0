From: Daniel Hellstrom <daniel@gaisler.com>
Subject: [PATCH 05/10] GRETH: fix opening/closing
Date: Thu, 13 Jan 2011 09:25:30 +0100
Message-ID: <1294907135-24884-5-git-send-email-daniel@gaisler.com>
References: <1294907135-24884-1-git-send-email-daniel@gaisler.com>
Cc: netdev@vger.kernel.org, kristoffer@gaisler.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail201c2.megamailservers.com ([69.49.111.102]:39241 "EHLO
	mail201c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753307Ab1AMJAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 04:00:04 -0500
In-Reply-To: <1294907135-24884-1-git-send-email-daniel@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When NAPI is disabled there is no point in having IRQs enabled, TX/RX
should be off before clearing the TX/RX descriptor rings.

Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>
---
 drivers/net/greth.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index 775dc24..27578c9 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -366,6 +366,8 @@ static int greth_open(struct net_device *dev)
 		dev_dbg(&dev->dev, " starting queue\n");
 	netif_start_queue(dev);
 
+	GRETH_REGSAVE(greth->regs->status, 0xFF);
+
 	napi_enable(&greth->napi);
 
 	greth_enable_irqs(greth);
@@ -381,7 +383,9 @@ static int greth_close(struct net_device *dev)
 
 	napi_disable(&greth->napi);
 
+	greth_disable_irqs(greth);
 	greth_disable_tx(greth);
+	greth_disable_rx(greth);
 
 	netif_stop_queue(dev);
 
-- 
1.5.4

