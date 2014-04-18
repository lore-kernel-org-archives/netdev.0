From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 4/4] net: davinci_mdio: simplify IO memory mapping
Date: Fri, 18 Apr 2014 20:24:57 +0300
Message-ID: <1397841897-9170-5-git-send-email-grygorii.strashko@ti.com>
References: <1397841897-9170-1-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Randy Dunlap <rdunlap@infradead.org>,
	Jonathan Cameron <jic23@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	<prabhakar.csengg@gmail.com>, <santosh.shilimkar@ti.com>,
	Sekhar Nori <nsekhar@ti.com>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<davinci-linux-open-source@linux.davincidsp.com>,
	<sergei.shtylyov@cogentembedded.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>
To: Florian Fainelli <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397841897-9170-1-git-send-email-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simplify IO memory mapping by using devm_ioremap_resource()
which will do all errors handling and reporting for us.

Cc: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c |   21 +++------------------
 1 file changed, 3 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 98d53a3..87e9f20 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -363,24 +363,9 @@ static int davinci_mdio_probe(struct platform_device *pdev)
 	spin_lock_init(&data->lock);
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	if (!res) {
-		dev_err(dev, "could not find register map resource\n");
-		ret = -ENOENT;
-		goto bail_out;
-	}
-
-	res = devm_request_mem_region(dev, res->start, resource_size(res),
-					    dev_name(dev));
-	if (!res) {
-		dev_err(dev, "could not allocate register map resource\n");
-		ret = -ENXIO;
-		goto bail_out;
-	}
-
-	data->regs = devm_ioremap_nocache(dev, res->start, resource_size(res));
-	if (!data->regs) {
-		dev_err(dev, "could not map mdio registers\n");
-		ret = -ENOMEM;
+	data->regs = devm_ioremap_resource(dev, res);
+	if (IS_ERR(data->regs)) {
+		ret = PTR_ERR(data->regs);
 		goto bail_out;
 	}
 
-- 
1.7.9.5
