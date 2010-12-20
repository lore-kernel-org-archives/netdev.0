From: Dan Carpenter <error27@gmail.com>
Subject: [patch -next] pch_can: off by one bugs
Date: Mon, 20 Dec 2010 12:26:01 +0300
Message-ID: <20101220092601.GS1936@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:34638 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754317Ab0LTJ0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 04:26:12 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

priv->tx_enable[] has PCH_TX_OBJ_END elements so this code is
reading and writing one past the end of the array.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 8d45fdd..b2c1292 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -1077,7 +1077,7 @@ static int pch_can_suspend(struct pci_dev *pdev, pm_message_t state)
 	pch_can_set_int_enables(priv, PCH_CAN_DISABLE);
 
 	/* Save Tx buffer enable state */
-	for (i = PCH_TX_OBJ_START; i <= PCH_TX_OBJ_END; i++)
+	for (i = PCH_TX_OBJ_START; i < PCH_TX_OBJ_END; i++)
 		priv->tx_enable[i] = pch_can_get_rxtx_ir(priv, i, PCH_TX_IFREG);
 
 	/* Disable all Transmit buffers */
@@ -1138,7 +1138,7 @@ static int pch_can_resume(struct pci_dev *pdev)
 	pch_can_set_optmode(priv);
 
 	/* Enabling the transmit buffer. */
-	for (i = PCH_TX_OBJ_START; i <= PCH_TX_OBJ_END; i++)
+	for (i = PCH_TX_OBJ_START; i < PCH_TX_OBJ_END; i++)
 		pch_can_set_rxtx(priv, i, priv->tx_enable[i], PCH_TX_IFREG);
 
 	/* Configuring the receive buffer and enabling them. */
