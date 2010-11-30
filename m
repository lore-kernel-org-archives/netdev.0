From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 v6 20/20] can: EG20T PCH: Replace netif_rx to
 netif_receive_skb
Date: Tue, 30 Nov 2010 13:41:10 +0900
Message-ID: <4CF48066.1040009__41790.6619645239$1291092129$gmane$org@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, margie.foster@intel.com
To: Wolfgang Grandegger <wg@grandegger.com>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Christian Pellegrin <chripell@fsfe.org>,
	Barry Song <21cnbao@gmail.com>,
	Samuel Ortiz <sameo@linux.inte
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:34793 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751677Ab0K3Elm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 23:41:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since this driver is implemented as NAPI,
netif_receive_skb must be used not netif_rx.

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 596dc1e..0ee3fc6 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -578,7 +578,7 @@ static void pch_can_error(struct net_device *ndev, u32 status)
 	cf->data[7] = (errc & PCH_REC) >> 8;
 
 	priv->can.state = state;
-	netif_rx(skb);
+	netif_receive_skb(skb);
 
 	stats->rx_packets++;
 	stats->rx_bytes += cf->can_dlc;
-- 
1.6.0.6
