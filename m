From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH net-next 1/2] net: davinci_mdio: don't request io address range
Date: Tue, 24 Feb 2015 16:27:30 -0500
Message-ID: <1424813251-31610-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Murali Karicheri <m-karicheri2@ti.com>
To: <davem@davemloft.net>, <mugunthanvnm@ti.com>,
	<george.cherian@ti.com>, <prabhakar.csengg@gmail.com>,
	<varkabhadram@gmail.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <tony@atomide.com>,
	<grygorii.strashko@ti.com>, <lokeshvutla@ti.com>,
	<mpa@pengutronix.de>, <w-kwok2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grygorii Strashko <grygorii.strashko@ti.com>

Historically Davinci MDIO driver was  created with assumption that
MDIO is standalone device, but for Keystone 2 it's a part
of NETCP module and now NETCP driver requests IO range which
includes MDIO IO range too. This causes Keystone 2 networking stack
failure during the boot.

"netcp-1.0 2620110.netcp: Probe of module(netcp-gbe) failed with -16"

Hence, don't request io address range from Davinci MDIO driver and
just remap it.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 98655b4..b13ec82 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -371,7 +371,7 @@ static int davinci_mdio_probe(struct platform_device *pdev)
 	spin_lock_init(&data->lock);
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	data->regs = devm_ioremap_resource(dev, res);
+	data->regs = devm_ioremap_nocache(dev, res->start, resource_size(res));
 	if (IS_ERR(data->regs)) {
 		ret = PTR_ERR(data->regs);
 		goto bail_out;
-- 
1.7.9.5
