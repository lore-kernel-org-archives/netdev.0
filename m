From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 1/4] tg3: Make 1000Base-X FC resolution look
 like 1000T
Date: Mon, 21 Nov 2011 17:01:17 -0800
Message-ID: <1321923680-7925-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2487 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757641Ab1KVBCF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Nov 2011 20:02:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes tg3's 1000Base-X flow control resolution to look like
the 1000Base-T flow control resolution code.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   18 ++++++------------
 1 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index d9e9c8c..438d099 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -1706,18 +1706,12 @@ static u8 tg3_resolve_flowctrl_1000X(u16 lcladv, u16 rmtadv)
 {
 	u8 cap = 0;
 
-	if (lcladv & ADVERTISE_1000XPAUSE) {
-		if (lcladv & ADVERTISE_1000XPSE_ASYM) {
-			if (rmtadv & LPA_1000XPAUSE)
-				cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
-			else if (rmtadv & LPA_1000XPAUSE_ASYM)
-				cap = FLOW_CTRL_RX;
-		} else {
-			if (rmtadv & LPA_1000XPAUSE)
-				cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
-		}
-	} else if (lcladv & ADVERTISE_1000XPSE_ASYM) {
-		if ((rmtadv & LPA_1000XPAUSE) && (rmtadv & LPA_1000XPAUSE_ASYM))
+	if (lcladv & rmtadv & ADVERTISE_1000XPAUSE) {
+		cap = FLOW_CTRL_TX | FLOW_CTRL_RX;
+	} else if (lcladv & rmtadv & ADVERTISE_1000XPSE_ASYM) {
+		if (lcladv & ADVERTISE_1000XPAUSE)
+			cap = FLOW_CTRL_RX;
+		if (rmtadv & ADVERTISE_1000XPAUSE)
 			cap = FLOW_CTRL_TX;
 	}
 
-- 
1.7.3.4
