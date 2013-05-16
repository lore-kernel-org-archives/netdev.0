From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Subject: [PATCH 5/5] net: davinci_mdio: trivial cleanup
Date: Thu, 16 May 2013 13:00:38 +0530
Message-ID: <1368689438-23889-6-git-send-email-prabhakar.csengg@gmail.com>
References: <1368689438-23889-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>
To: DLOS <davinci-linux-open-source@linux.davincidsp.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Kosina <trivial@kernel.org>, <netdev@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368689438-23889-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lad, Prabhakar <prabhakar.csengg@gmail.com>

remove unwanted header inclusion and sort the alphabetically
also guard the davinci_mdio_of_mtable table and davinci_mdio_probe_dt()
with CONFIG_OF.

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c |   23 +++++++++++------------
 1 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 12aec17..bc6cfec 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -24,20 +24,16 @@
  * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  * ---------------------------------------------------------------------------
  */
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/platform_device.h>
-#include <linux/delay.h>
-#include <linux/sched.h>
-#include <linux/slab.h>
-#include <linux/phy.h>
+
 #include <linux/clk.h>
-#include <linux/err.h>
-#include <linux/io.h>
-#include <linux/pm_runtime.h>
 #include <linux/davinci_emac.h>
+#include <linux/delay.h>
+#include <linux/io.h>
+#include <linux/module.h>
 #include <linux/of.h>
-#include <linux/of_device.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+#include <linux/pm_runtime.h>
 
 /*
  * This timeout definition is a worst-case ultra defensive measure against
@@ -291,6 +287,7 @@ static int davinci_mdio_write(struct mii_bus *bus, int phy_id,
 	return 0;
 }
 
+#if IS_ENABLED(CONFIG_OF)
 static int davinci_mdio_probe_dt(struct mdio_platform_data *data,
 			 struct platform_device *pdev)
 {
@@ -308,7 +305,7 @@ static int davinci_mdio_probe_dt(struct mdio_platform_data *data,
 
 	return 0;
 }
-
+#endif
 
 static int davinci_mdio_probe(struct platform_device *pdev)
 {
@@ -481,11 +478,13 @@ static const struct dev_pm_ops davinci_mdio_pm_ops = {
 	.resume		= davinci_mdio_resume,
 };
 
+#if IS_ENABLED(CONFIG_OF)
 static const struct of_device_id davinci_mdio_of_mtable[] = {
 	{ .compatible = "ti,davinci_mdio", },
 	{ /* sentinel */ },
 };
 MODULE_DEVICE_TABLE(of, davinci_mdio_of_mtable);
+#endif
 
 static struct platform_driver davinci_mdio_driver = {
 	.driver = {
-- 
1.7.4.1
