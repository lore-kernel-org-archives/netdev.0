From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 2.6.33-rc1  updated] pcnet_cs: add cis of KTI PE520
 pcmcia network card
Date: Wed, 23 Dec 2009 17:10:04 +0900
Message-ID: <20091223171004.77316fa5.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	<20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	<20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	<20091004073257.52a6624b.ken_kawasaki@spring.nifty.jp>
	<20091221205849.dae4e929.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg507.nifty.com ([202.248.238.87]:64974 "EHLO
	userg507.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238AbZLWIK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 03:10:58 -0500
In-Reply-To: <20091221205849.dae4e929.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


pcnet_cs,serial_cs:

add cis of KTI PE520 pcmcia network card,
and serial card(Sierra Wireless AC860).

Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

 drivers/net/pcmcia/pcnet_cs.c |    4 ++--
 drivers/serial/serial_cs.c    |   16 +++++++++++++++-
 firmware/Makefile             |    3 ++-
 firmware/WHENCE               |    1 +
 firmware/cis/PE520.cis.ihex   |    9 +++++++++
 5 files changed, 29 insertions(+), 4 deletions(-)

diff -uprN linux-2.6.33-rc1.orig/drivers/net/pcmcia/pcnet_cs.c linux-2.6.33-rc1/drivers/net/pcmcia/pcnet_cs.c
--- linux-2.6.33-rc1.orig/drivers/net/pcmcia/pcnet_cs.c	2009-12-20 18:17:04.000000000 +0900
+++ linux-2.6.33-rc1/drivers/net/pcmcia/pcnet_cs.c	2009-12-20 18:30:54.000000000 +0900
@@ -1741,7 +1741,7 @@ static struct pcmcia_device_id pcnet_ids
 	PCMCIA_MFC_DEVICE_CIS_PROD_ID4(0, "NSC MF LAN/Modem", 0x58fc6056, "cis/DP83903.cis"),
 	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(0, 0x0175, 0x0000, "cis/DP83903.cis"),
 	PCMCIA_DEVICE_CIS_MANF_CARD(0xc00f, 0x0002, "cis/LA-PCM.cis"),
-	PCMCIA_DEVICE_CIS_PROD_ID12("KTI", "PE520 PLUS", 0xad180345, 0x9d58d392, "PE520.cis"),
+	PCMCIA_DEVICE_CIS_PROD_ID12("KTI", "PE520 PLUS", 0xad180345, 0x9d58d392, "cis/PE520.cis"),
 	PCMCIA_DEVICE_CIS_PROD_ID12("NDC", "Ethernet", 0x01c43ae1, 0x00b2e941, "cis/NE2K.cis"),
 	PCMCIA_DEVICE_CIS_PROD_ID12("PMX   ", "PE-200", 0x34f3f1c8, 0x10b59f8c, "cis/PE-200.cis"),
 	PCMCIA_DEVICE_CIS_PROD_ID12("TAMARACK", "Ethernet", 0xcf434fba, 0x00b2e941, "cis/tamarack.cis"),
@@ -1754,7 +1754,7 @@ MODULE_DEVICE_TABLE(pcmcia, pcnet_ids);
 MODULE_FIRMWARE("cis/PCMLM28.cis");
 MODULE_FIRMWARE("cis/DP83903.cis");
 MODULE_FIRMWARE("cis/LA-PCM.cis");
-MODULE_FIRMWARE("PE520.cis");
+MODULE_FIRMWARE("cis/PE520.cis");
 MODULE_FIRMWARE("cis/NE2K.cis");
 MODULE_FIRMWARE("cis/PE-200.cis");
 MODULE_FIRMWARE("cis/tamarack.cis");
diff -uprN linux-2.6.33-rc1.orig/drivers/serial/serial_cs.c linux-2.6.33-rc1/drivers/serial/serial_cs.c
--- linux-2.6.33-rc1.orig/drivers/serial/serial_cs.c	2009-12-20 18:17:05.000000000 +0900
+++ linux-2.6.33-rc1/drivers/serial/serial_cs.c	2009-12-23 16:39:06.000000000 +0900
@@ -819,6 +819,7 @@ static struct pcmcia_device_id serial_id
 	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(1, 0x0101, 0x0035, "cis/3CXEM556.cis"),
 	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(1, 0x0101, 0x003d, "cis/3CXEM556.cis"),
 	PCMCIA_DEVICE_CIS_PROD_ID12("Sierra Wireless", "AC850", 0xd85f6206, 0x42a2c018, "cis/SW_8xx_SER.cis"), /* Sierra Wireless AC850 3G Network Adapter R1 */
+	PCMCIA_DEVICE_CIS_PROD_ID12("Sierra Wireless", "AC860", 0xd85f6206, 0x698f93db, "cis/SW_8xx_SER.cis"), /* Sierra Wireless AC860 3G Network Adapter R1 */
 	PCMCIA_DEVICE_CIS_PROD_ID12("Sierra Wireless", "AC710/AC750", 0xd85f6206, 0x761b11e0, "cis/SW_7xx_SER.cis"),  /* Sierra Wireless AC710/AC750 GPRS Network Adapter R1 */
 	PCMCIA_DEVICE_CIS_MANF_CARD(0x0192, 0xa555, "cis/SW_555_SER.cis"),  /* Sierra Aircard 555 CDMA 1xrtt Modem -- pre update */
 	PCMCIA_DEVICE_CIS_MANF_CARD(0x013f, 0xa555, "cis/SW_555_SER.cis"),  /* Sierra Aircard 555 CDMA 1xrtt Modem -- post update */
@@ -827,7 +828,7 @@ static struct pcmcia_device_id serial_id
 	PCMCIA_DEVICE_CIS_PROD_ID12("ADVANTECH", "COMpad-32/85B-4", 0x96913a85, 0xcec8f102, "cis/COMpad4.cis"),
 	PCMCIA_DEVICE_CIS_PROD_ID123("ADVANTECH", "COMpad-32/85", "1.0", 0x96913a85, 0x8fbe92ae, 0x0877b627, "cis/COMpad2.cis"),
 	PCMCIA_DEVICE_CIS_PROD_ID2("RS-COM 2P", 0xad20b156, "cis/RS-COM-2P.cis"),
-	PCMCIA_DEVICE_CIS_MANF_CARD(0x0013, 0x0000, "GLOBETROTTER.cis"),
+	PCMCIA_DEVICE_CIS_MANF_CARD(0x0013, 0x0000, "cis/GLOBETROTTER.cis"),
 	PCMCIA_DEVICE_PROD_ID12("ELAN DIGITAL SYSTEMS LTD, c1997.","SERIAL CARD: SL100  1.00.",0x19ca78af,0xf964f42b),
 	PCMCIA_DEVICE_PROD_ID12("ELAN DIGITAL SYSTEMS LTD, c1997.","SERIAL CARD: SL100",0x19ca78af,0x71d98e83),
 	PCMCIA_DEVICE_PROD_ID12("ELAN DIGITAL SYSTEMS LTD, c1997.","SERIAL CARD: SL232  1.00.",0x19ca78af,0x69fb7490),
@@ -861,6 +862,19 @@ static struct pcmcia_device_id serial_id
 };
 MODULE_DEVICE_TABLE(pcmcia, serial_ids);
 
+MODULE_FIRMWARE("cis/PCMLM28.cis");
+MODULE_FIRMWARE("cis/DP83903.cis");
+MODULE_FIRMWARE("cis/3CCFEM556.cis");
+MODULE_FIRMWARE("cis/3CXEM556.cis");
+MODULE_FIRMWARE("cis/SW_8xx_SER.cis");
+MODULE_FIRMWARE("cis/SW_7xx_SER.cis");
+MODULE_FIRMWARE("cis/SW_555_SER.cis");
+MODULE_FIRMWARE("cis/MT5634ZLX.cis");
+MODULE_FIRMWARE("cis/COMpad2.cis");
+MODULE_FIRMWARE("cis/COMpad4.cis");
+MODULE_FIRMWARE("cis/RS-COM-2P.cis");
+MODULE_FIRMWARE("cis/GLOBETROTTER.cis");
+
 static struct pcmcia_driver serial_cs_driver = {
 	.owner		= THIS_MODULE,
 	.drv		= {
diff -uprN linux-2.6.33-rc1.orig/firmware/cis/PE520.cis.ihex linux-2.6.33-rc1/firmware/cis/PE520.cis.ihex
--- linux-2.6.33-rc1.orig/firmware/cis/PE520.cis.ihex	1970-01-01 09:00:00.000000000 +0900
+++ linux-2.6.33-rc1/firmware/cis/PE520.cis.ihex	2009-12-23 16:43:17.000000000 +0900
@@ -0,0 +1,9 @@
+:1000000001030000FF152304014B544900504535FE
+:10001000323020504C55530050434D434941204508
+:10002000746865726E65740000FF20046101100041
+:10003000210206001A050101D00F0B1B09C101198D
+:0A00400001556530FFFF1400FF00BA
+:00000001FF
+#
+# Replacement CIS for PE520 ethernet card
+#
diff -uprN linux-2.6.33-rc1.orig/firmware/Makefile linux-2.6.33-rc1/firmware/Makefile
--- linux-2.6.33-rc1.orig/firmware/Makefile	2009-12-20 18:17:07.000000000 +0900
+++ linux-2.6.33-rc1/firmware/Makefile	2009-12-23 16:32:28.000000000 +0900
@@ -69,7 +69,8 @@ fw-shipped-$(CONFIG_E100) += e100/d101m_
 fw-shipped-$(CONFIG_MYRI_SBUS) += myricom/lanai.bin
 fw-shipped-$(CONFIG_PCMCIA_PCNET) += cis/LA-PCM.cis cis/PCMLM28.cis \
 				     cis/DP83903.cis cis/NE2K.cis \
-				     cis/tamarack.cis cis/PE-200.cis
+				     cis/tamarack.cis cis/PE-200.cis \
+				     cis/PE520.cis
 fw-shipped-$(CONFIG_PCMCIA_3C589) += cis/3CXEM556.cis
 fw-shipped-$(CONFIG_PCMCIA_3C574) += cis/3CCFEM556.cis
 fw-shipped-$(CONFIG_SERIAL_8250_CS) += cis/MT5634ZLX.cis cis/RS-COM-2P.cis \
diff -uprN linux-2.6.33-rc1.orig/firmware/WHENCE linux-2.6.33-rc1/firmware/WHENCE
--- linux-2.6.33-rc1.orig/firmware/WHENCE	2009-12-20 18:17:07.000000000 +0900
+++ linux-2.6.33-rc1/firmware/WHENCE	2009-12-23 16:33:06.000000000 +0900
@@ -601,6 +601,7 @@ File: cis/LA-PCM.cis
       cis/NE2K.cis
       cis/tamarack.cis
       cis/PE-200.cis
+      cis/PE520.cis
 
 Licence: GPL
 
