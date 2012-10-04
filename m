From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/3] can: peak_pci: fix error return code
Date: Thu,  4 Oct 2012 19:57:20 +0200
Message-ID: <1349373442-11128-2-git-send-email-mkl@pengutronix.de>
References: <1349373442-11128-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	Peter Senna Tschudin <peter.senna@gmail.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:51911 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322Ab2JDR52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 13:57:28 -0400
In-Reply-To: <1349373442-11128-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Senna Tschudin <peter.senna@gmail.com>

Convert a nonnegative error return code to a negative one, as returned
elsewhere in the function.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
(
if@p1 (\(ret < 0\|ret != 0\))
 { ... return ret; }
|
ret@p1 = 0
)
... when != ret = e1
    when != &ret
*if(...)
{
  ... when != ret = e2
      when forall
 return ret;
}
// </smpl>

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/sja1000/peak_pci.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/can/sja1000/peak_pci.c b/drivers/net/can/sja1000/peak_pci.c
index f0a1296..f5b82ae 100644
--- a/drivers/net/can/sja1000/peak_pci.c
+++ b/drivers/net/can/sja1000/peak_pci.c
@@ -583,12 +583,14 @@ static int __devinit peak_pci_probe(struct pci_dev *pdev,
 	cfg_base = pci_iomap(pdev, 0, PEAK_PCI_CFG_SIZE);
 	if (!cfg_base) {
 		dev_err(&pdev->dev, "failed to map PCI resource #0\n");
+		err = -ENOMEM;
 		goto failure_release_regions;
 	}
 
 	reg_base = pci_iomap(pdev, 1, PEAK_PCI_CHAN_SIZE * channels);
 	if (!reg_base) {
 		dev_err(&pdev->dev, "failed to map PCI resource #1\n");
+		err = -ENOMEM;
 		goto failure_unmap_cfg_base;
 	}
 
-- 
1.7.10
