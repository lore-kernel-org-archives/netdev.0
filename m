From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 2/8] net: irda/sa1100_ir: convert to
 dma_request_slave_channel()
Date: Mon, 29 Aug 2016 12:26:10 +0100
Message-ID: <E1beKhe-0001Gt-4k@rmk-PC.armlinux.org.uk>
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
Received: from pandora.armlinux.org.uk ([78.32.30.218]:56838 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756977AbcH2L0U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 07:26:20 -0400
In-Reply-To: <20160829112540.GF1041@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert the sa11x0 irda driver to use the more modern
dma_request_slave_channel() method to get the DMA channel, rather than
using dma_request_channel() with a filter function exported by DMA
driver.  This allows us to get rid of the sa11x0-dma.h include.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/irda/sa1100_ir.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/irda/sa1100_ir.c b/drivers/net/irda/sa1100_ir.c
index b6e44ff4e373..7bc9c2955d4b 100644
--- a/drivers/net/irda/sa1100_ir.c
+++ b/drivers/net/irda/sa1100_ir.c
@@ -31,7 +31,6 @@
 #include <linux/platform_device.h>
 #include <linux/dma-mapping.h>
 #include <linux/dmaengine.h>
-#include <linux/sa11x0-dma.h>
 
 #include <net/irda/irda.h>
 #include <net/irda/wrapper.h>
@@ -124,7 +123,7 @@ static int sa1100_irda_dma_request(struct device *dev, struct sa1100_buf *buf,
 	dma_cap_zero(m);
 	dma_cap_set(DMA_SLAVE, m);
 
-	buf->chan = dma_request_channel(m, sa11x0_dma_filter_fn, (void *)name);
+	buf->chan = dma_request_slave_channel(dev, name);
 	if (!buf->chan) {
 		dev_err(dev, "unable to request DMA channel for %s\n",
 			name);
@@ -797,12 +796,12 @@ static int sa1100_irda_start(struct net_device *dev)
 
 	si->speed = 9600;
 
-	err = sa1100_irda_dma_request(si->dev, &si->dma_rx, "Ser2ICPRc",
+	err = sa1100_irda_dma_request(si->dev, &si->dma_rx, "rx",
 				&sa1100_irda_fir_rx);
 	if (err)
 		goto err_rx_dma;
 
-	err = sa1100_irda_dma_request(si->dev, &si->dma_tx, "Ser2ICPTr",
+	err = sa1100_irda_dma_request(si->dev, &si->dma_tx, "tx",
 				&sa1100_irda_sir_tx);
 	if (err)
 		goto err_tx_dma;
-- 
2.1.0
