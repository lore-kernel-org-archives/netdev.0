From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 2/5] stmmac: allow mtu bigger than 1500 in case of normal desc (V2).
Date: Wed, 12 Oct 2011 15:38:05 +0200
Message-ID: <1318426688-9419-3-git-send-email-peppe.cavallaro@st.com>
References: <1318426688-9419-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net, Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Deepak SIKRI <deepak.sikri@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:60403 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750907Ab1JLOBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2011 10:01:20 -0400
In-Reply-To: <1318426688-9419-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows to set the mtu bigger than 1500
in case of normal descriptors.
This is helping some SPEAr customers.

Signed-off-by: Deepak SIKRI <deepak.sikri@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index ba7af2c..de3e536 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1357,17 +1357,17 @@ static void stmmac_set_rx_mode(struct net_device *dev)
 static int stmmac_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
-	int max_mtu;
+	int max_mtu = ETH_DATA_LEN;
 
 	if (netif_running(dev)) {
 		pr_err("%s: must be stopped to change its MTU\n", dev->name);
 		return -EBUSY;
 	}
 
-	if (priv->plat->has_gmac)
+	if (priv->plat->enh_desc)
 		max_mtu = JUMBO_LEN;
 	else
-		max_mtu = ETH_DATA_LEN;
+		max_mtu = BUF_SIZE_4KiB;
 
 	if ((new_mtu < 46) || (new_mtu > max_mtu)) {
 		pr_err("%s: invalid MTU, max MTU is: %d\n", dev->name, max_mtu);
-- 
1.7.4.4
