From: Andres Salomon <dilinger@queued.net>
Subject: [PATCH 14/19] janz: mfd_cell is now implicitly available to drivers
Date: Wed, 2 Feb 2011 20:17:53 -0800
Message-ID: <20110202201753.73300ea3@queued.net>
References: <20110202195417.228e2656@queued.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Mark Brown <broonie@opensource.wolfsonmicro.com>,
	Wolfgang Grandegger <wg@grandegger.com>,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110202195417.228e2656@queued.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


No need to explicitly set the cell's platform_data/data_size.

In this case, move the various platform_data pointers
to driver_data.  All of the clients which make use of it
are also changed.

Signed-off-by: Andres Salomon <dilinger@queued.net>
---
 drivers/gpio/janz-ttl.c      |    2 +-
 drivers/mfd/janz-cmodio.c    |    3 +--
 drivers/net/can/janz-ican3.c |    2 +-
 3 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/gpio/janz-ttl.c b/drivers/gpio/janz-ttl.c
index 813ac07..98a3f9d 100644
--- a/drivers/gpio/janz-ttl.c
+++ b/drivers/gpio/janz-ttl.c
@@ -149,7 +149,7 @@ static int __devinit ttl_probe(struct platform_device *pdev)
 	struct resource *res;
 	int ret;
 
-	pdata = pdev->dev.platform_data;
+	pdata = platform_get_drvdata(pdev);
 	if (!pdata) {
 		dev_err(dev, "no platform data\n");
 		ret = -ENXIO;
diff --git a/drivers/mfd/janz-cmodio.c b/drivers/mfd/janz-cmodio.c
index 36a166b..77e3a1f 100644
--- a/drivers/mfd/janz-cmodio.c
+++ b/drivers/mfd/janz-cmodio.c
@@ -86,8 +86,7 @@ static int __devinit cmodio_setup_subdevice(struct cmodio_device *priv,
 
 	/* Add platform data */
 	pdata->modno = modno;
-	cell->platform_data = pdata;
-	cell->data_size = sizeof(*pdata);
+	cell->driver_data = pdata;
 
 	/* MODULbus registers -- PCI BAR3 is big-endian MODULbus access */
 	res->flags = IORESOURCE_MEM;
diff --git a/drivers/net/can/janz-ican3.c b/drivers/net/can/janz-ican3.c
index b9a6d7a..7d282c3 100644
--- a/drivers/net/can/janz-ican3.c
+++ b/drivers/net/can/janz-ican3.c
@@ -1643,7 +1643,7 @@ static int __devinit ican3_probe(struct platform_device *pdev)
 	struct device *dev;
 	int ret;
 
-	pdata = pdev->dev.platform_data;
+	pdata = platform_get_drvdata(pdev);
 	if (!pdata)
 		return -ENXIO;
 
-- 
1.7.2.3
