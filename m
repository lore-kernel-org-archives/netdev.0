From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 v9 20/20] pch_can: Replace netif_rx to netif_receive_skb
Date: Mon, 13 Dec 2010 15:24:26 +0900
Message-ID: <1292221467-8039-20-git-send-email-tomoya-linux@dsn.okisemi.com>
References: <1292221467-8039-1-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-2-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-3-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-4-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-5-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-6-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-7-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-8-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-9-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-10-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-11-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-12-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-13-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-14-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-15-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-16-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-17-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-18-git-send-email-tomoya-linux@dsn.okisemi.com>
 <1292221467-8039-19-git-send-email-tomoya-linux@dsn.okisemi.com>
Cc: qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, margie.foster@intel.com,
	Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
To: wg@grandegger.com, w.sang@pengutronix.de, chripell@fsfe.org,
	21cnbao@gmail.com, sameo@linux.intel.com,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	linux-kernel@vger.kerne
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:24502 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752490Ab0LMGWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 01:22:09 -0500
In-Reply-To: <1292221467-8039-19-git-send-email-tomoya-linux@dsn.okisemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since this driver is implemented as NAPI,
netif_receive_skb must be used not netif_rx.

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/pch_can.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 4697b1c..8d45fdd 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -572,7 +572,7 @@ static void pch_can_error(struct net_device *ndev, u32 status)
 	cf->data[7] = (errc & PCH_REC) >> 8;
 
 	priv->can.state = state;
-	netif_rx(skb);
+	netif_receive_skb(skb);
 
 	stats->rx_packets++;
 	stats->rx_bytes += cf->can_dlc;
-- 
1.6.0.6

