From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/2] can: c_can_pci: fix null-pointer-deref in c_can_start() - set device pointer
Date: Wed, 18 Jan 2017 13:08:51 +0100
Message-ID: <20170118120852.6095-2-mkl@pengutronix.de>
References: <20170118120852.6095-1-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de,
        =?UTF-8?q?Einar=20J=C3=B3n?= <tolvupostur@gmail.com>,
        linux-stable <stable@vger.kernel.org>,
        Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:57381 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751553AbdARMJf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 07:09:35 -0500
In-Reply-To: <20170118120852.6095-1-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Einar Jón <tolvupostur@gmail.com>

The priv->device pointer for c_can_pci is never set, but it is used
without a NULL check in c_can_start(). Setting it in c_can_pci_probe()
like c_can_plat_probe() prevents c_can_pci.ko from crashing, with and
without CONFIG_PM.

This might also cause the pm_runtime_*() functions in c_can.c to
actually be executed for c_can_pci devices - they are the only other
place where priv->device is used, but they all contain a null check.

Signed-off-by: Einar Jón <tolvupostur@gmail.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can_pci.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/can/c_can/c_can_pci.c b/drivers/net/can/c_can/c_can_pci.c
index 7be393c96b1a..cf7c18947189 100644
--- a/drivers/net/can/c_can/c_can_pci.c
+++ b/drivers/net/can/c_can/c_can_pci.c
@@ -161,6 +161,7 @@ static int c_can_pci_probe(struct pci_dev *pdev,
 
 	dev->irq = pdev->irq;
 	priv->base = addr;
+	priv->device = &pdev->dev;
 
 	if (!c_can_pci_data->freq) {
 		dev_err(&pdev->dev, "no clock frequency defined\n");
-- 
2.11.0
