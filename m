From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH] can: sja1000_isa: fix "limited range" compiler warnings
Date: Thu, 24 Nov 2011 10:08:35 +0100
Message-ID: <4ECE0993.6050902@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the compiler warnings: "comparison is always
false due to limited range of data type" by using "0xff" instead
of "-1" for unsigned values.

Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/sja1000/sja1000_isa.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/can/sja1000/sja1000_isa.c b/drivers/net/can/sja1000/sja1000_isa.c
index 496223e..f0840d5 100644
--- a/drivers/net/can/sja1000/sja1000_isa.c
+++ b/drivers/net/can/sja1000/sja1000_isa.c
@@ -44,9 +44,9 @@ static unsigned long port[MAXDEV];
 static unsigned long mem[MAXDEV];
 static int __devinitdata irq[MAXDEV];
 static int __devinitdata clk[MAXDEV];
-static char __devinitdata cdr[MAXDEV] = {[0 ... (MAXDEV - 1)] = -1};
-static char __devinitdata ocr[MAXDEV] = {[0 ... (MAXDEV - 1)] = -1};
-static char __devinitdata indirect[MAXDEV] = {[0 ... (MAXDEV - 1)] = -1};
+static unsigned char __devinitdata cdr[MAXDEV] = {[0 ... (MAXDEV - 1)] = 0xff};
+static unsigned char __devinitdata ocr[MAXDEV] = {[0 ... (MAXDEV - 1)] = 0xff};
+static int __devinitdata indirect[MAXDEV] = {[0 ... (MAXDEV - 1)] = -1};
 
 module_param_array(port, ulong, NULL, S_IRUGO);
 MODULE_PARM_DESC(port, "I/O port number");
@@ -54,7 +54,7 @@ MODULE_PARM_DESC(port, "I/O port number");
 module_param_array(mem, ulong, NULL, S_IRUGO);
 MODULE_PARM_DESC(mem, "I/O memory address");
 
-module_param_array(indirect, byte, NULL, S_IRUGO);
+module_param_array(indirect, int, NULL, S_IRUGO);
 MODULE_PARM_DESC(indirect, "Indirect access via address and data port");
 
 module_param_array(irq, int, NULL, S_IRUGO);
@@ -189,17 +189,17 @@ static int __devinit sja1000_isa_probe(struct device *pdev, unsigned int idx)
 	else
 		priv->can.clock.freq = CLK_DEFAULT / 2;
 
-	if (ocr[idx] != -1)
-		priv->ocr = ocr[idx] & 0xff;
-	else if (ocr[0] != -1)
-		priv->ocr = ocr[0] & 0xff;
+	if (ocr[idx] != 0xff)
+		priv->ocr = ocr[idx];
+	else if (ocr[0] != 0xff)
+		priv->ocr = ocr[0];
 	else
 		priv->ocr = OCR_DEFAULT;
 
-	if (cdr[idx] != -1)
-		priv->cdr = cdr[idx] & 0xff;
-	else if (cdr[0] != -1)
-		priv->cdr = cdr[0] & 0xff;
+	if (cdr[idx] != 0xff)
+		priv->cdr = cdr[idx];
+	else if (cdr[0] != 0xff)
+		priv->cdr = cdr[0];
 	else
 		priv->cdr = CDR_DEFAULT;
 
-- 
1.7.4.1
