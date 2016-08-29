From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 1/8] dmaengine: sa11x0: add DMA filters
Date: Mon, 29 Aug 2016 12:26:04 +0100
Message-ID: <E1beKhY-0001Gn-PB@rmk-PC.armlinux.org.uk>
References: <20160829112540.GF1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Dan Williams <dan.j.williams@intel.com>,
        Samuel Ortiz <samuel@sortiz.org>,
        Vinod Koul <vinod.koul@intel.com>
To: dmaengine@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:56835 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756135AbcH2L0R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 07:26:17 -0400
In-Reply-To: <20160829112540.GF1041@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add DMA filters for the sa11x0 DMA channels.  This will allow us to
migrate away from directly using the DMA filter function in drivers.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/dma/sa11x0-dma.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/dma/sa11x0-dma.c b/drivers/dma/sa11x0-dma.c
index 43db255050d2..565bc67fac7e 100644
--- a/drivers/dma/sa11x0-dma.c
+++ b/drivers/dma/sa11x0-dma.c
@@ -823,6 +823,13 @@ static const struct sa11x0_dma_channel_desc chan_desc[] = {
 	CD(Ser4SSPRc, DDAR_RW),
 };
 
+static const struct dma_slave_map sa11x0_dma_map[] = {
+	{ "sa11x0-ir", "tx", "Ser2ICPTr" },
+	{ "sa11x0-ir", "rx", "Ser2ICPRc" },
+	{ "sa11x0-ssp", "tx", "Ser4SSPTr" },
+	{ "sa11x0-ssp", "rx", "Ser4SSPRc" },
+};
+
 static int sa11x0_dma_init_dmadev(struct dma_device *dmadev,
 	struct device *dev)
 {
@@ -909,6 +916,10 @@ static int sa11x0_dma_probe(struct platform_device *pdev)
 	spin_lock_init(&d->lock);
 	INIT_LIST_HEAD(&d->chan_pending);
 
+	d->slave.filter.fn = sa11x0_dma_filter_fn;
+	d->slave.filter.mapcnt = ARRAY_SIZE(sa11x0_dma_map);
+	d->slave.filter.map = sa11x0_dma_map;
+
 	d->base = ioremap(res->start, resource_size(res));
 	if (!d->base) {
 		ret = -ENOMEM;
-- 
2.1.0
