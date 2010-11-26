From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 18/19 v5] can: EG20T PCH: Add setting TEC/REC
 statistics processing
Date: Fri, 26 Nov 2010 11:26:10 +0900
Message-ID: <4CEF1AC2.40704__23808.7893849753$1290738426$gmane$org@dsn.okisemi.com>
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
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:37801 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752967Ab0KZC0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 21:26:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add setting TEC/REC statistics processing

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 16806da..1c3baca 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -574,6 +574,9 @@ static void pch_can_error(struct net_device *ndev, u32 status)
 		break;
 	}
 
+	cf->data[6] = errc & PCH_TEC;
+	cf->data[7] = (errc & PCH_REC) >> 8;
+
 	priv->can.state = state;
 	netif_rx(skb);
 
-- 
1.6.0.6
