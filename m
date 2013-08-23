From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH v2 3/4] ps3_gelic: lower NAPI weight
Date: Fri, 23 Aug 2013 15:41:19 +0200
Message-ID: <5217667F.5010207@redhat.com>
References: <1377103771-1590-1-git-send-email-mschmidt@redhat.com>  <1377103771-1590-4-git-send-email-mschmidt@redhat.com> <1377118988.8674.82.camel@smoke>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Geoff Levand <geoff@infradead.org>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45307 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754940Ab3HWNlq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 09:41:46 -0400
In-Reply-To: <1377118988.8674.82.camel@smoke>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 82dc3c63 ("net: introduce NAPI_POLL_WEIGHT")
netif_napi_add() produces an error message if a NAPI poll weight
greater than 64 is requested.

GELIC_NET_NAPI_WEIGHT is defined to GELIC_NET_RX_DESCRIPTORS,
which is 128.

Use the standard NAPI weight.

v2: proper reference to the related commit

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
Acked-by: Geoff Levand <geoff@infradead.org>
---
 drivers/net/ethernet/toshiba/ps3_gelic_net.c | 3 +--
 drivers/net/ethernet/toshiba/ps3_gelic_net.h | 1 -
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_net.c b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
index ad32af6..9c805e0 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_net.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
@@ -1466,8 +1466,7 @@ static void gelic_ether_setup_netdev_ops(struct net_device *netdev,
 {
 	netdev->watchdog_timeo = GELIC_NET_WATCHDOG_TIMEOUT;
 	/* NAPI */
-	netif_napi_add(netdev, napi,
-		       gelic_net_poll, GELIC_NET_NAPI_WEIGHT);
+	netif_napi_add(netdev, napi, gelic_net_poll, NAPI_POLL_WEIGHT);
 	netdev->ethtool_ops = &gelic_ether_ethtool_ops;
 	netdev->netdev_ops = &gelic_netdevice_ops;
 }
diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_net.h b/drivers/net/ethernet/toshiba/ps3_gelic_net.h
index a93df6a..309abb4 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_net.h
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_net.h
@@ -37,7 +37,6 @@
 #define GELIC_NET_RXBUF_ALIGN           128
 #define GELIC_CARD_RX_CSUM_DEFAULT      1 /* hw chksum */
 #define GELIC_NET_WATCHDOG_TIMEOUT      5*HZ
-#define GELIC_NET_NAPI_WEIGHT           (GELIC_NET_RX_DESCRIPTORS)
 #define GELIC_NET_BROADCAST_ADDR        0xffffffffffffL
 
 #define GELIC_NET_MC_COUNT_MAX          32 /* multicast address list */
-- 
1.8.3.1
