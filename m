From: Andre Heider <a.heider@gmail.com>
Subject: [PATCH 3/3] ps3_gelic: Don't kill the device on DMA failure
Date: Tue, 12 Jul 2011 22:13:26 +0200
Message-ID: <1310501606-829-4-git-send-email-a.heider@gmail.com>
References: <1310501606-829-1-git-send-email-a.heider@gmail.com>
Cc: netdev@vger.kernel.org, cbe-oss-dev@lists.ozlabs.org,
	Andre Heider <a.heider@gmail.com>
To: Geoff Levand <geoff@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:45807 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755147Ab1GLUNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 16:13:55 -0400
Received: by mail-bw0-f46.google.com with SMTP id 5so4318012bwd.19
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2011 13:13:55 -0700 (PDT)
In-Reply-To: <1310501606-829-1-git-send-email-a.heider@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reset card->tx_dma_progress when lv1_net_start_tx_dma() fails or it
won't send anything afterwards anymore

Signed-off-by: Andre Heider <a.heider@gmail.com>
---
 drivers/net/ps3_gelic_net.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
index 94422fc..4acc17b 100644
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -838,9 +838,11 @@ static int gelic_card_kick_txdma(struct gelic_card *card,
 		card->tx_dma_progress = 1;
 		status = lv1_net_start_tx_dma(bus_id(card), dev_id(card),
 					      descr->bus_addr, 0);
-		if (status)
+		if (status) {
+			card->tx_dma_progress = 0;
 			dev_info(ctodev(card), "lv1_net_start_txdma failed," \
 				 "status=%d\n", status);
+		}
 	}
 	return status;
 }
-- 
1.7.5.4

