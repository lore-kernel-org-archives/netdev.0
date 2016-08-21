From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next v2] net: phy: Add missing of_node_put() in
 xgmiitorgmii_probe()
Date: Sun, 21 Aug 2016 22:46:15 +0000
Message-ID: <1471819575-13389-1-git-send-email-weiyj.lk@gmail.com>
References: <1471706815-27723-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Wei Yongjun <weiyj.lk@gmail.com>,
 linux-arm-kernel@lists.infradead.org
To: f.fainelli@gmail.com, michal.simek@xilinx.com, soren.brinkmann@xilinx.com,
 Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1471706815-27723-1-git-send-email-weiyj.lk@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This node pointer is returned by of_parse_phandle() with
refcount incremented in this function. of_node_put() on it
before exitting this function.

This is detected by Coccinelle semantic patch.

Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>
---
v1 -> v2: release it unconditionally as Andrew and David's suggestion
---
 drivers/net/phy/xilinx_gmii2rgmii.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/xilinx_gmii2rgmii.c b/drivers/net/phy/xilinx_gmii2rgmii.c
index cad6e19..73b50f3 100644
--- a/drivers/net/phy/xilinx_gmii2rgmii.c
+++ b/drivers/net/phy/xilinx_gmii2rgmii.c
@@ -73,6 +73,7 @@ int xgmiitorgmii_probe(struct mdio_device *mdiodev)
 	}
 
 	priv->phy_dev = of_phy_find_device(phy_node);
+	of_node_put(phy_node);
 	if (!priv->phy_dev) {
 		dev_info(dev, "Couldn't find phydev\n");
 		return -EPROBE_DEFER;
