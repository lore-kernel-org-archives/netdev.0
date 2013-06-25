From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: [PATCH v2 3/3] net: davinci_mdio: gaurd the DT code with IS_ENABLED(CONFIG_OF)
Date: Tue, 25 Jun 2013 21:24:53 +0530
Message-ID: <1372175693-20318-4-git-send-email-prabhakar.csengg@gmail.com>
References: <1372175693-20318-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: DLOS <davinci-linux-open-source@linux.davincidsp.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372175693-20318-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>

guard the davinci_mdio_of_mtable table and davinci_mdio_probe_dt()
with CONFIG_OF.

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index c47f0db..dac6f58 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -291,6 +291,7 @@ static int davinci_mdio_write(struct mii_bus *bus, int phy_id,
 	return 0;
 }
 
+#if IS_ENABLED(CONFIG_OF)
 static int davinci_mdio_probe_dt(struct mdio_platform_data *data,
 			 struct platform_device *pdev)
 {
@@ -308,7 +309,7 @@ static int davinci_mdio_probe_dt(struct mdio_platform_data *data,
 
 	return 0;
 }
-
+#endif
 
 static int davinci_mdio_probe(struct platform_device *pdev)
 {
@@ -477,11 +478,13 @@ static const struct dev_pm_ops davinci_mdio_pm_ops = {
 	.resume_early	= davinci_mdio_resume,
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
1.7.9.5
