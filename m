From: Tristan Colgate <tristan@cloudflare.com>
Subject: [PATCH] net ixgbevf: ethtool statistics yields/misses fixes
Date: Thu, 17 Dec 2015 15:16:32 +0000
Message-ID: <CAKMD_B1woL6tWv+D9SVrOwA6VEeWX1pY22DEuw1jn-Vq=+Lp6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:33987 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755687AbbLQPQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 10:16:33 -0500
Received: by mail-wm0-f51.google.com with SMTP id l126so27958380wml.1
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2015 07:16:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ixgbevf over counts yields and does not actually count misses.
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index d3e5f5b..ffdd8df 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -417,13 +417,13 @@ static void ixgbevf_get_ethtool_stats(struct
net_device *netdev,
        for (i = 0; i < adapter->num_rx_queues; i++) {
                rx_yields += adapter->rx_ring[i]->stats.yields;
                rx_cleaned += adapter->rx_ring[i]->stats.cleaned;
-               rx_yields += adapter->rx_ring[i]->stats.yields;
+               rx_missed += adapter->rx_ring[i]->stats.misses;
        }

        for (i = 0; i < adapter->num_tx_queues; i++) {
                tx_yields += adapter->tx_ring[i]->stats.yields;
                tx_cleaned += adapter->tx_ring[i]->stats.cleaned;
-               tx_yields += adapter->tx_ring[i]->stats.yields;
+               tx_missed += adapter->tx_ring[i]->stats.misses;
        }

        adapter->bp_rx_yields = rx_yields;
-- 
2.1.4
