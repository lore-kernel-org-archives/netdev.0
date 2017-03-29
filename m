From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 6/7] NFC: nfcmrvl_uart: fix device-node leak during probe
Date: Wed, 29 Mar 2017 18:21:11 +0200
Message-ID: <20170329162112.18121-7-johan@kernel.org>
References: <20170329162112.18121-1-johan@kernel.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>,
        Vincent Cuissard <cuissard@marvell.com>
To: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
        Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
        Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170329162112.18121-1-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to release the device-node reference when done parsing the
node.

Fixes: e097dc624f78 ("NFC: nfcmrvl: add UART driver")
Cc: Vincent Cuissard <cuissard@marvell.com>
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/nfc/nfcmrvl/uart.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/nfc/nfcmrvl/uart.c b/drivers/nfc/nfcmrvl/uart.c
index 6c0c301611c4..91162f8e0366 100644
--- a/drivers/nfc/nfcmrvl/uart.c
+++ b/drivers/nfc/nfcmrvl/uart.c
@@ -84,6 +84,7 @@ static int nfcmrvl_uart_parse_dt(struct device_node *node,
 	ret = nfcmrvl_parse_dt(matched_node, pdata);
 	if (ret < 0) {
 		pr_err("Failed to get generic entries\n");
+		of_node_put(matched_node);
 		return ret;
 	}
 
@@ -97,6 +98,8 @@ static int nfcmrvl_uart_parse_dt(struct device_node *node,
 	else
 		pdata->break_control = 0;
 
+	of_node_put(matched_node);
+
 	return 0;
 }
 
-- 
2.12.2
