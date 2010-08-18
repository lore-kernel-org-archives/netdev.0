From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] qlnic: fix a race in qlcnic_get_stats()
Date: Wed, 18 Aug 2010 12:42:48 +0200
Message-ID: <1282128168.2194.49.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Amit Kumar Salecha <amit.salecha@qlogic.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63825 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752711Ab0HRKmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 06:42:53 -0400
Received: by wwi17 with SMTP id 17so651276wwi.1
        for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 03:42:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dont clear netdev->stats, it might give transient wrong values to
concurrent stat readers.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/qlcnic/qlcnic_main.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index abd7cd6..d71d44a 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1980,8 +1980,6 @@ static struct net_device_stats *qlcnic_get_stats(struct net_device *netdev)
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct net_device_stats *stats = &netdev->stats;
 
-	memset(stats, 0, sizeof(*stats));
-
 	stats->rx_packets = adapter->stats.rx_pkts + adapter->stats.lro_pkts;
 	stats->tx_packets = adapter->stats.xmitfinished;
 	stats->rx_bytes = adapter->stats.rxbytes + adapter->stats.lrobytes;


