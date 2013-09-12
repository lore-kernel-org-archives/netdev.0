From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: [PATCH] bfin_mac: remove deprecated IRQF_DISABLED
Date: Thu, 12 Sep 2013 05:35:43 +0200
Message-ID: <1378956943-3470-1-git-send-email-michael.opdenacker@free-electrons.com>
Cc: richardcochran@gmail.com, jg1.han@samsung.com, jiri@resnulli.us,
	mugunthanvnm@ti.com, uclinux-dist-devel@blackfin.uclinux.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch proposes to remove the IRQF_DISABLED flag from
drivers/net/ethernet/adi/bfin_mac.c.

It's a NOOP since 2.6.35 and it will be removed one day.

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 drivers/net/ethernet/adi/bfin_mac.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index e66684a..75fb1d2 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -530,7 +530,7 @@ static int bfin_mac_ethtool_setwol(struct net_device *dev,
 	if (lp->wol && !lp->irq_wake_requested) {
 		/* register wake irq handler */
 		rc = request_irq(IRQ_MAC_WAKEDET, bfin_mac_wake_interrupt,
-				 IRQF_DISABLED, "EMAC_WAKE", dev);
+				 0, "EMAC_WAKE", dev);
 		if (rc)
 			return rc;
 		lp->irq_wake_requested = true;
@@ -1686,7 +1686,7 @@ static int bfin_mac_probe(struct platform_device *pdev)
 	/* now, enable interrupts */
 	/* register irq handler */
 	rc = request_irq(IRQ_MAC_RX, bfin_mac_interrupt,
-			IRQF_DISABLED, "EMAC_RX", ndev);
+			0, "EMAC_RX", ndev);
 	if (rc) {
 		dev_err(&pdev->dev, "Cannot request Blackfin MAC RX IRQ!\n");
 		rc = -EBUSY;
-- 
1.8.1.2
