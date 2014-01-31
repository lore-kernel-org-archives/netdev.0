From: Max Filippov <jcmvbkbc@gmail.com>
Subject: [PATCH v2 3/4] net: ethoc: implement ethtool get registers
Date: Fri, 31 Jan 2014 09:41:06 +0400
Message-ID: <1391146867-30508-4-git-send-email-jcmvbkbc@gmail.com>
References: <1391146867-30508-1-git-send-email-jcmvbkbc@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Marc Gauthier <marc@cadence.com>,
	Max Filippov <jcmvbkbc@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391146867-30508-1-git-send-email-jcmvbkbc@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Reviewed-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/ethernet/ethoc.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 779d3c3..5da32a7 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -51,6 +51,7 @@ MODULE_PARM_DESC(buffer_size, "DMA buffer allocation size");
 #define	ETH_HASH0	0x48
 #define	ETH_HASH1	0x4c
 #define	ETH_TXCTRL	0x50
+#define	ETH_END		0x54
 
 /* mode register */
 #define	MODER_RXEN	(1 <<  0) /* receive enable */
@@ -912,9 +913,28 @@ static int ethoc_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	return phy_ethtool_sset(phydev, cmd);
 }
 
+static int ethoc_get_regs_len(struct net_device *netdev)
+{
+	return ETH_END;
+}
+
+static void ethoc_get_regs(struct net_device *dev, struct ethtool_regs *regs,
+			   void *p)
+{
+	struct ethoc *priv = netdev_priv(dev);
+	u32 *regs_buff = p;
+	unsigned i;
+
+	regs->version = 0;
+	for (i = 0; i < ETH_END / sizeof(u32); ++i)
+		regs_buff[i] = ethoc_read(priv, i * sizeof(u32));
+}
+
 const struct ethtool_ops ethoc_ethtool_ops = {
 	.get_settings = ethoc_get_settings,
 	.set_settings = ethoc_set_settings,
+	.get_regs_len = ethoc_get_regs_len,
+	.get_regs = ethoc_get_regs,
 	.get_link = ethtool_op_get_link,
 	.get_ts_info = ethtool_op_get_ts_info,
 };
-- 
1.8.1.4
