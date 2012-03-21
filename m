From: <s-paulraj-l0cyMroinI0@public.gmane.org>
Subject: [PATCH] net: add device tree support for DaVinci MDIO
Date: Wed, 21 Mar 2012 11:05:03 -0400
Message-ID: <1332342303-23656-1-git-send-email-s-paulraj@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>,
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
Errors-To: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Sandeep Paulraj <s-paulraj-l0cyMroinI0@public.gmane.org>

This patch adds device tree support in the DaVinci MDIO driver.


Signed-off-by: Sandeep Paulraj <s-paulraj-l0cyMroinI0@public.gmane.org>
---
 .../devicetree/bindings/net/davinci_mdio.txt       |   12 ++++++++++++
 drivers/net/ethernet/ti/davinci_mdio.c             |    7 +++++++
 2 files changed, 19 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/davinci_mdio.txt

diff --git a/Documentation/devicetree/bindings/net/davinci_mdio.txt b/Documentation/devicetree/bindings/net/davinci_mdio.txt
new file mode 100644
index 0000000..cbe499f
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/davinci_mdio.txt
@@ -0,0 +1,12 @@
+MDIO on DaVinci SOCs
+
+Currently defined compatibles:
+- ti,davinci_mdio
+
+Example:
+
+mdio: mdio@2090300 {
+			compatible	= "ti,davinci_mdio";
+			reg		= <0x2090300 0x100>;
+		};
+
diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 7615040..362644d 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -34,6 +34,7 @@
 #include <linux/clk.h>
 #include <linux/err.h>
 #include <linux/io.h>
+#include <linux/of.h>
 #include <linux/davinci_emac.h>
 
 /*
@@ -449,11 +450,17 @@ static const struct dev_pm_ops davinci_mdio_pm_ops = {
 	.resume		= davinci_mdio_resume,
 };
 
+static struct of_device_id __devinitdata of_match[] = {
+	{ .compatible = "ti,davinci_mdio", },
+	{},
+};
+
 static struct platform_driver davinci_mdio_driver = {
 	.driver = {
 		.name	 = "davinci_mdio",
 		.owner	 = THIS_MODULE,
 		.pm	 = &davinci_mdio_pm_ops,
+		.of_match_table	= of_match,
 	},
 	.probe = davinci_mdio_probe,
 	.remove = __devexit_p(davinci_mdio_remove),
-- 
1.7.4.1
