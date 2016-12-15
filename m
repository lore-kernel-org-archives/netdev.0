From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH] staging: octeon: Call SET_NETDEV_DEV()
Date: Wed, 14 Dec 2016 17:13:24 -0800
Message-ID: <20161215011326.8852-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "open list:STAGING SUBSYSTEM" <devel@driverdev.osuosl.org>,
 Asbjoern Sloth Toennesen <asbjorn@asbjorn.st>,
 Florian Fainelli <f.fainelli@gmail.com>, Aaro Koskinen <aaro.koskinen@iki.fi>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Laura Garcia Liebana <nevola@gmail.com>,
 open list <linux-kernel@vger.kernel.org>, Jarod Wilson <jarod@redhat.com>,
 Bhaktipriya Shridhar <bhaktipriya96@gmail.com>, davem@davemloft.net,
 Philippe Reynes <tremyfr@gmail.com>
To: netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

The Octeon driver calls into PHYLIB which now checks for
net_device->dev.parent, so make sure we do set it before calling into
any MDIO/PHYLIB related function.

Fixes: ec988ad78ed6 ("phy: Don't increment MDIO bus refcount unless it's a different owner")
Reported-by: Aaro Koskinen <aaro.koskinen@iki.fi>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/staging/octeon/ethernet.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/staging/octeon/ethernet.c b/drivers/staging/octeon/ethernet.c
index 8130dfe89745..4971aa54756a 100644
--- a/drivers/staging/octeon/ethernet.c
+++ b/drivers/staging/octeon/ethernet.c
@@ -770,6 +770,7 @@ static int cvm_oct_probe(struct platform_device *pdev)
 			/* Initialize the device private structure. */
 			struct octeon_ethernet *priv = netdev_priv(dev);
 
+			SET_NETDEV_DEV(dev, &pdev->dev);
 			dev->netdev_ops = &cvm_oct_pow_netdev_ops;
 			priv->imode = CVMX_HELPER_INTERFACE_MODE_DISABLED;
 			priv->port = CVMX_PIP_NUM_INPUT_PORTS;
@@ -816,6 +817,7 @@ static int cvm_oct_probe(struct platform_device *pdev)
 			}
 
 			/* Initialize the device private structure. */
+			SET_NETDEV_DEV(dev, &pdev->dev);
 			priv = netdev_priv(dev);
 			priv->netdev = dev;
 			priv->of_node = cvm_oct_node_for_port(pip, interface,
-- 
2.9.3
