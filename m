From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH 3/7] ethoc: write number of TX buffers in init_ring
Date: Fri, 11 Jun 2010 14:47:36 +0200
Message-ID: <1276260460-14531-3-git-send-email-jonas@southpole.se>
References: <1276260460-14531-1-git-send-email-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:49426 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755877Ab0FKMrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 08:47:51 -0400
In-Reply-To: <1276260460-14531-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This moves the write of the TX_BD_NUM to init_ring together with the
rest of the code setting up the transmission buffers.

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/ethoc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index 5904ad2..afeb993 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -298,6 +298,8 @@ static int ethoc_init_ring(struct ethoc *dev, void* mem_start)
 	dev->dty_tx = 0;
 	dev->cur_rx = 0;
 
+	ethoc_write(dev, TX_BD_NUM, dev->num_tx);
+
 	/* setup transmission buffers */
 	bd.addr = mem_start;
 	bd.stat = TX_BD_IRQ | TX_BD_CRC;
@@ -676,8 +678,6 @@ static int ethoc_open(struct net_device *dev)
 	if (ret)
 		return ret;
 
-	ethoc_write(priv, TX_BD_NUM, priv->num_tx);
-
 	ethoc_init_ring(priv, (void*)dev->mem_start);
 	ethoc_reset(priv);
 
-- 
1.7.0.4

