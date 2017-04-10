From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 1/6] net: mvmdio: disable interrupts in driver failure path
Date: Mon, 10 Apr 2017 16:28:04 +0100
Message-ID: <E1cxbEa-0006g5-BY@rmk-PC.armlinux.org.uk>
References: <20170410152728.GT17774@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Marcin Wojtas <mw@semihalf.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:37642 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751396AbdDJP2L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 11:28:11 -0400
In-Reply-To: <20170410152728.GT17774@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the mvmdio driver has an interrupt, it enables the "done" interrupt
after requesting its interrupt handler.  However, probe failure results
in the interrupt being left enabled.  Disable it on the failure path.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/ethernet/marvell/mvmdio.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index a0d1b084ecec..7aea0beca56e 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -251,6 +251,8 @@ static int orion_mdio_probe(struct platform_device *pdev)
 	return 0;
 
 out_mdio:
+	if (dev->err_interrupt > 0)
+		writel(0, dev->regs + MVMDIO_ERR_INT_MASK);
 	if (!IS_ERR(dev->clk))
 		clk_disable_unprepare(dev->clk);
 	return ret;
-- 
2.7.4
