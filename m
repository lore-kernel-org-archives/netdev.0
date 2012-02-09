From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] stmmac: fix driver features
Date: Thu,  9 Feb 2012 11:56:33 +0100
Message-ID: <1328784993-31733-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:49088 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751398Ab2BIK4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 05:56:45 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 143E8265
	for <netdev@vger.kernel.org>; Thu,  9 Feb 2012 10:56:42 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id AE152248F
	for <netdev@vger.kernel.org>; Thu,  9 Feb 2012 10:56:42 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New GMAC chips can set the tx_coe and rx_csum
flags by looking at the HW cap register and this
happens during the open.
This patch fixes the stmmac_fix_feature function that
in some cases assumes that there is no HW csum
because no flags are passed through the platform.
As soon as the open method is called then the
stmmac_fix_feature could want to turn-on the NETIF_F_RXCSUM
or NETIF_F_ALL_CSUM.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 36ee77f..e03a873 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1541,8 +1541,13 @@ static netdev_features_t stmmac_fix_features(struct net_device *dev,
 
 	if (!priv->rx_coe)
 		features &= ~NETIF_F_RXCSUM;
+	else
+		features |= NETIF_F_RXCSUM;
+
 	if (!priv->plat->tx_coe)
 		features &= ~NETIF_F_ALL_CSUM;
+	else
+		features |= NETIF_F_ALL_CSUM;
 
 	/* Some GMAC devices have a bugged Jumbo frame support that
 	 * needs to have the Tx COE disabled for oversized frames
-- 
1.7.4.4
