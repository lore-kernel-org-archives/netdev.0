From: Johan Hovold <johan@kernel.org>
Subject: [PATCH v2 2/8] NFC: nfcmrvl_uart: add missing tty-device sanity check
Date: Thu, 30 Mar 2017 12:15:36 +0200
Message-ID: <20170330101542.15384-3-johan@kernel.org>
References: <20170330101542.15384-1-johan@kernel.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>,
        stable <stable@vger.kernel.org>,
        Vincent Cuissard <cuissard@marvell.com>
To: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
        Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
        Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170330101542.15384-1-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to check the tty-device pointer before trying to access the
parent device to avoid dereferencing a NULL-pointer when the tty is one
end of a Unix98 pty.

Fixes: e097dc624f78 ("NFC: nfcmrvl: add UART driver")
Cc: stable <stable@vger.kernel.org>     # 4.2
Cc: Vincent Cuissard <cuissard@marvell.com>
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/nfc/nfcmrvl/uart.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/nfc/nfcmrvl/uart.c b/drivers/nfc/nfcmrvl/uart.c
index 83a99e38e7bd..6c0c301611c4 100644
--- a/drivers/nfc/nfcmrvl/uart.c
+++ b/drivers/nfc/nfcmrvl/uart.c
@@ -109,6 +109,7 @@ static int nfcmrvl_nci_uart_open(struct nci_uart *nu)
 	struct nfcmrvl_private *priv;
 	struct nfcmrvl_platform_data *pdata = NULL;
 	struct nfcmrvl_platform_data config;
+	struct device *dev = nu->tty->dev;
 
 	/*
 	 * Platform data cannot be used here since usually it is already used
@@ -116,9 +117,8 @@ static int nfcmrvl_nci_uart_open(struct nci_uart *nu)
 	 * and check if DT entries were added.
 	 */
 
-	if (nu->tty->dev->parent && nu->tty->dev->parent->of_node)
-		if (nfcmrvl_uart_parse_dt(nu->tty->dev->parent->of_node,
-					  &config) == 0)
+	if (dev && dev->parent && dev->parent->of_node)
+		if (nfcmrvl_uart_parse_dt(dev->parent->of_node, &config) == 0)
 			pdata = &config;
 
 	if (!pdata) {
@@ -131,7 +131,7 @@ static int nfcmrvl_nci_uart_open(struct nci_uart *nu)
 	}
 
 	priv = nfcmrvl_nci_register_dev(NFCMRVL_PHY_UART, nu, &uart_ops,
-					nu->tty->dev, pdata);
+					dev, pdata);
 	if (IS_ERR(priv))
 		return PTR_ERR(priv);
 
-- 
2.12.2
