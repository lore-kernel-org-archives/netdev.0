From: Bhadram Varka <vbhadram@nvidia.com>
Subject: [PATCH net-next] stmmac: copy unicast mac address to MAC registers
Date: Fri, 27 Oct 2017 08:22:02 +0530
Message-ID: <1509072722-31657-1-git-send-email-vbhadram@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
        Bhadram Varka <vbhadram@nvidia.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate16.nvidia.com ([216.228.121.65]:16106 "EHLO
        hqemgate16.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932334AbdJ0Cwe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 22:52:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently stmmac driver not copying the valid ethernet
MAC address to MAC registers. This patch takes care
of updating the MAC register with MAC address.

Signed-off-by: Bhadram Varka <vbhadram@nvidia.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 0e1b0a3..e0e6348 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3748,6 +3748,20 @@ static int stmmac_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	return ret;
 }
 
+static int stmmac_set_mac_address(struct net_device *ndev, void *addr)
+{
+	struct stmmac_priv *priv = netdev_priv(ndev);
+	int ret = 0;
+
+	ret = eth_mac_addr(ndev, addr);
+	if (ret)
+		return ret;
+
+	priv->hw->mac->set_umac_addr(priv->hw, ndev->dev_addr, 0);
+
+	return ret;
+}
+
 #ifdef CONFIG_DEBUG_FS
 static struct dentry *stmmac_fs_dir;
 
@@ -3975,7 +3989,7 @@ static const struct net_device_ops stmmac_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = stmmac_poll_controller,
 #endif
-	.ndo_set_mac_address = eth_mac_addr,
+	.ndo_set_mac_address = stmmac_set_mac_address,
 };
 
 /**
-- 
2.7.4
