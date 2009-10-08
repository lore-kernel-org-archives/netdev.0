From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] net: Fix OF platform drivers coldplug/hotplug when
	compiled as modules
Date: Thu, 8 Oct 2009 16:15:12 +0400
Message-ID: <20091008121512.GA2390@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Some OF platform drivers are missing module device tables, so they won't
load automatically on boot. This patch fixes the issue by adding proper
MODULE_DEVICE_TABLE() macros to the drivers.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/can/sja1000/sja1000_of_platform.c |    1 +
 drivers/net/fec_mpc52xx_phy.c                 |    1 +
 drivers/net/fs_enet/fs_enet-main.c            |    1 +
 drivers/net/fs_enet/mii-bitbang.c             |    1 +
 drivers/net/fs_enet/mii-fec.c                 |    1 +
 drivers/net/fsl_pq_mdio.c                     |    1 +
 drivers/net/gianfar.c                         |    4 +---
 drivers/net/ibm_newemac/core.c                |    2 ++
 drivers/net/phy/mdio-gpio.c                   |    1 +
 9 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/sja1000/sja1000_of_platform.c b/drivers/net/can/sja1000/sja1000_of_platform.c
index 3373560..9dd076a 100644
--- a/drivers/net/can/sja1000/sja1000_of_platform.c
+++ b/drivers/net/can/sja1000/sja1000_of_platform.c
@@ -213,6 +213,7 @@ static struct of_device_id __devinitdata sja1000_ofp_table[] = {
 	{.compatible = "nxp,sja1000"},
 	{},
 };
+MODULE_DEVICE_TABLE(of, sja1000_ofp_table);
 
 static struct of_platform_driver sja1000_ofp_driver = {
 	.owner = THIS_MODULE,
diff --git a/drivers/net/fec_mpc52xx_phy.c b/drivers/net/fec_mpc52xx_phy.c
index 31e6d62..ee0f3c6 100644
--- a/drivers/net/fec_mpc52xx_phy.c
+++ b/drivers/net/fec_mpc52xx_phy.c
@@ -155,6 +155,7 @@ static struct of_device_id mpc52xx_fec_mdio_match[] = {
 	{ .compatible = "mpc5200b-fec-phy", },
 	{}
 };
+MODULE_DEVICE_TABLE(of, mpc52xx_fec_mdio_match);
 
 struct of_platform_driver mpc52xx_fec_mdio_driver = {
 	.name = "mpc5200b-fec-phy",
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 2bc2d2b..ec2f503 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -1110,6 +1110,7 @@ static struct of_device_id fs_enet_match[] = {
 #endif
 	{}
 };
+MODULE_DEVICE_TABLE(of, fs_enet_match);
 
 static struct of_platform_driver fs_enet_driver = {
 	.name	= "fs_enet",
diff --git a/drivers/net/fs_enet/mii-bitbang.c b/drivers/net/fs_enet/mii-bitbang.c
index 93b481b..24ff9f4 100644
--- a/drivers/net/fs_enet/mii-bitbang.c
+++ b/drivers/net/fs_enet/mii-bitbang.c
@@ -221,6 +221,7 @@ static struct of_device_id fs_enet_mdio_bb_match[] = {
 	},
 	{},
 };
+MODULE_DEVICE_TABLE(of, fs_enet_mdio_bb_match);
 
 static struct of_platform_driver fs_enet_bb_mdio_driver = {
 	.name = "fsl-bb-mdio",
diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
index a2d69c1..96eba42 100644
--- a/drivers/net/fs_enet/mii-fec.c
+++ b/drivers/net/fs_enet/mii-fec.c
@@ -219,6 +219,7 @@ static struct of_device_id fs_enet_mdio_fec_match[] = {
 #endif
 	{},
 };
+MODULE_DEVICE_TABLE(of, fs_enet_mdio_fec_match);
 
 static struct of_platform_driver fs_enet_fec_mdio_driver = {
 	.name = "fsl-fec-mdio",
diff --git a/drivers/net/fsl_pq_mdio.c b/drivers/net/fsl_pq_mdio.c
index d167090..6ac4648 100644
--- a/drivers/net/fsl_pq_mdio.c
+++ b/drivers/net/fsl_pq_mdio.c
@@ -407,6 +407,7 @@ static struct of_device_id fsl_pq_mdio_match[] = {
 	},
 	{},
 };
+MODULE_DEVICE_TABLE(of, fsl_pq_mdio_match);
 
 static struct of_platform_driver fsl_pq_mdio_driver = {
 	.name = "fsl-pq_mdio",
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 1e5289f..5bf31f1 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -2325,9 +2325,6 @@ static irqreturn_t gfar_error(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-/* work with hotplug and coldplug */
-MODULE_ALIAS("platform:fsl-gianfar");
-
 static struct of_device_id gfar_match[] =
 {
 	{
@@ -2336,6 +2333,7 @@ static struct of_device_id gfar_match[] =
 	},
 	{},
 };
+MODULE_DEVICE_TABLE(of, gfar_match);
 
 /* Structure for a device driver */
 static struct of_platform_driver gfar_driver = {
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 89c82c5..4baa37c 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -24,6 +24,7 @@
  *
  */
 
+#include <linux/module.h>
 #include <linux/sched.h>
 #include <linux/string.h>
 #include <linux/errno.h>
@@ -2985,6 +2986,7 @@ static struct of_device_id emac_match[] =
 	},
 	{},
 };
+MODULE_DEVICE_TABLE(of, emac_match);
 
 static struct of_platform_driver emac_driver = {
 	.name = "emac",
diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 250e10f..8659d34 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -238,6 +238,7 @@ static struct of_device_id mdio_ofgpio_match[] = {
 	},
 	{},
 };
+MODULE_DEVICE_TABLE(of, mdio_ofgpio_match);
 
 static struct of_platform_driver mdio_ofgpio_driver = {
 	.name = "mdio-gpio",
-- 
1.6.3.3
