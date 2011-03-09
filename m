From: Thomas Lange <thomas@corelatus.se>
Subject: [PATCH] Davinci: Do not reset EMAC TX overruns counter on read
Date: Wed, 09 Mar 2011 15:41:16 +0100
Message-ID: <4D77918C.9050800@corelatus.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	davem@davemloft.net, anantgole@ti.com, chaithrika@ti.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-gw11.han.skanova.net ([81.236.55.20]:45828 "EHLO
	smtp-gw11.han.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757027Ab1CIOlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 09:41:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't reset tx_fifo_errors when reading out current EMAC stats.
  (tx_fifo_errors shows up as TX overruns in netdev stats.)

Without this correction, the old counter value is lost every time
stats are read out.

Signed-off-by: Thomas Lange <thomas@corelatus.se>
---
  drivers/net/davinci_emac.c |    2 +-
  1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 2a628d1..922c8c5 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -1730,7 +1730,7 @@ static struct net_device_stats *emac_dev_getnetstats(struct net_device *ndev)
  		emac_read(EMAC_TXCARRIERSENSE);
  	emac_write(EMAC_TXCARRIERSENSE, stats_clear_mask);

-	ndev->stats.tx_fifo_errors = emac_read(EMAC_TXUNDERRUN);
+	ndev->stats.tx_fifo_errors += emac_read(EMAC_TXUNDERRUN);
  	emac_write(EMAC_TXUNDERRUN, stats_clear_mask);

  	return &ndev->stats;
-- 
1.7.2.5

