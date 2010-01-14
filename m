From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] ethoc: Use resource_size
Date: Thu, 14 Jan 2010 17:46:08 +0100
Message-ID: <1263487568-13682-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org, Tobias Klauser <tklauser@distanz.ch>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.zhaw.ch ([160.85.104.51]:63180 "EHLO mx2.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756672Ab0ANQzR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jan 2010 11:55:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the resource_size function instead of manually calculating the
resource size.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethoc.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index bd1db92..f9d5ca0 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -904,7 +904,7 @@ static int ethoc_probe(struct platform_device *pdev)
 	}
 
 	mmio = devm_request_mem_region(&pdev->dev, res->start,
-			res->end - res->start + 1, res->name);
+			resource_size(res), res->name);
 	if (!mmio) {
 		dev_err(&pdev->dev, "cannot request I/O memory space\n");
 		ret = -ENXIO;
@@ -917,7 +917,7 @@ static int ethoc_probe(struct platform_device *pdev)
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
 	if (res) {
 		mem = devm_request_mem_region(&pdev->dev, res->start,
-			res->end - res->start + 1, res->name);
+			resource_size(res), res->name);
 		if (!mem) {
 			dev_err(&pdev->dev, "cannot request memory space\n");
 			ret = -ENXIO;
@@ -945,7 +945,7 @@ static int ethoc_probe(struct platform_device *pdev)
 	priv->dma_alloc = 0;
 
 	priv->iobase = devm_ioremap_nocache(&pdev->dev, netdev->base_addr,
-			mmio->end - mmio->start + 1);
+			resource_size(mmio));
 	if (!priv->iobase) {
 		dev_err(&pdev->dev, "cannot remap I/O memory space\n");
 		ret = -ENXIO;
@@ -954,7 +954,7 @@ static int ethoc_probe(struct platform_device *pdev)
 
 	if (netdev->mem_end) {
 		priv->membase = devm_ioremap_nocache(&pdev->dev,
-			netdev->mem_start, mem->end - mem->start + 1);
+			netdev->mem_start, resource_size(mem));
 		if (!priv->membase) {
 			dev_err(&pdev->dev, "cannot remap memory space\n");
 			ret = -ENXIO;
-- 
1.6.3.3

