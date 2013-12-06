From: Nithin Nayak Sujir <nsujir@broadcom.com>
Subject: [PATCH net-next 1/5] tg3: Don't add rxbds_empty to rx_over_errors
Date: Fri, 6 Dec 2013 09:53:16 -0800
Message-ID: <1386352400-9623-2-git-send-email-nsujir@broadcom.com>
References: <1386352400-9623-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:60849 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758318Ab3LFRxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 12:53:39 -0500
In-Reply-To: <1386352400-9623-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rxbds_empty is an informational statistic signifying that a ring full
condition was observed. It does not mean an overflow has occurred.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index e35a1c5..886d50b 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -11746,8 +11746,6 @@ static void tg3_get_nstats(struct tg3 *tp, struct rtnl_link_stats64 *stats)
 		get_stat64(&hw_stats->rx_frame_too_long_errors) +
 		get_stat64(&hw_stats->rx_undersize_packets);
 
-	stats->rx_over_errors = old_stats->rx_over_errors +
-		get_stat64(&hw_stats->rxbds_empty);
 	stats->rx_frame_errors = old_stats->rx_frame_errors +
 		get_stat64(&hw_stats->rx_align_errors);
 	stats->tx_aborted_errors = old_stats->tx_aborted_errors +
-- 
1.8.1.4
