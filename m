From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 5/6] stmmac: remove useless check in the stmmac_tx_clean
Date: Tue, 25 Feb 2014 10:58:28 +0100
Message-ID: <1393322309-10390-5-git-send-email-peppe.cavallaro@st.com>
References: <1393322309-10390-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:38391 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752027AbaBYJ76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 04:59:58 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 4C8371A0
	for <netdev@vger.kernel.org>; Tue, 25 Feb 2014 09:59:56 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas22.st.com [10.75.90.92])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 12309B51B
	for <netdev@vger.kernel.org>; Tue, 25 Feb 2014 09:59:56 +0000 (GMT)
In-Reply-To: <1393322309-10390-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is an useless if condition that this patch is removing
when the driver cleans the tx resources.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index a50c8fc..352aef1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1321,12 +1321,9 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 	if (unlikely(netif_queue_stopped(priv->dev) &&
 		     stmmac_tx_avail(priv) > STMMAC_TX_THRESH(priv))) {
 		netif_tx_lock(priv->dev);
-		if (netif_queue_stopped(priv->dev) &&
-		    stmmac_tx_avail(priv) > STMMAC_TX_THRESH(priv)) {
-			if (netif_msg_tx_done(priv))
-				pr_debug("%s: restart transmit\n", __func__);
-			netif_wake_queue(priv->dev);
-		}
+		if (netif_msg_tx_done(priv))
+			pr_debug("%s: restart transmit\n", __func__);
+		netif_wake_queue(priv->dev);
 		netif_tx_unlock(priv->dev);
 	}
 
-- 
1.7.4.4
