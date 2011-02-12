From: Andres Salomon <dilinger-pFFUokh25LWsTnJN9+BGXg@public.gmane.org>
Subject: [PATCH 15/17] janz: mfd_cell is now implicitly available to drivers
Date: Fri, 11 Feb 2011 18:17:33 -0800
Message-ID: <20110211181733.38a49ad8@queued.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mark Brown <broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
To: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org


The cell's platform_data is now accessed with a helper function;
change clients to use that, and remove the now-unused data_size.

Signed-off-by: Andres Salomon <dilinger-pFFUokh25LWsTnJN9+BGXg@public.gmane.org>
---
 drivers/gpio/janz-ttl.c      |    2 +-
 drivers/mfd/janz-cmodio.c    |    1 -
 drivers/net/can/janz-ican3.c |    2 +-
 3 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/gpio/janz-ttl.c b/drivers/gpio/janz-ttl.c
index 813ac07..ef399ee 100644
--- a/drivers/gpio/janz-ttl.c
+++ b/drivers/gpio/janz-ttl.c
@@ -149,7 +149,7 @@ static int __devinit ttl_probe(struct platform_device *pdev)
 	struct resource *res;
 	int ret;
 
-	pdata = pdev->dev.platform_data;
+	pdata = mfd_get_data(pdev);
 	if (!pdata) {
 		dev_err(dev, "no platform data\n");
 		ret = -ENXIO;
diff --git a/drivers/mfd/janz-cmodio.c b/drivers/mfd/janz-cmodio.c
index 36a166b..58de1e2 100644
--- a/drivers/mfd/janz-cmodio.c
+++ b/drivers/mfd/janz-cmodio.c
@@ -87,7 +87,6 @@ static int __devinit cmodio_setup_subdevice(struct cmodio_device *priv,
 	/* Add platform data */
 	pdata->modno = modno;
 	cell->platform_data = pdata;
-	cell->data_size = sizeof(*pdata);
 
 	/* MODULbus registers -- PCI BAR3 is big-endian MODULbus access */
 	res->flags = IORESOURCE_MEM;
diff --git a/drivers/net/can/janz-ican3.c b/drivers/net/can/janz-ican3.c
index 366f5cc..bc2b15b 100644
--- a/drivers/net/can/janz-ican3.c
+++ b/drivers/net/can/janz-ican3.c
@@ -1643,7 +1643,7 @@ static int __devinit ican3_probe(struct platform_device *pdev)
 	struct device *dev;
 	int ret;
 
-	pdata = pdev->dev.platform_data;
+	pdata = mfd_get_data(pdev);
 	if (!pdata)
 		return -ENXIO;
 
-- 
1.7.2.3
