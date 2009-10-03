From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 2.6.32-rc1] pcnet_cs: add cis of National
 Semicondoctor's multifunction pcmcia card
Date: Sun, 4 Oct 2009 07:32:57 +0900
Message-ID: <20091004073257.52a6624b.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	<20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	<20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ken_kawasaki@spring.nifty.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg502.nifty.com ([202.248.238.82]:23749 "EHLO
	userg502.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751533AbZJCWdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2009 18:33:53 -0400
In-Reply-To: <20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


pcnet_cs,serial_cs:
  
add cis of National Semicondoctor's lan&modem mulitifunction pcmcia card,
NE2K, tamarack ethernet card,
and some serial card(COMpad2, COMpad4).

   
Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

 drivers/net/pcmcia/pcnet_cs.c  |   10 +++++-----
 drivers/serial/serial_cs.c     |   12 ++++++------
 firmware/Makefile              |    7 +++++--
 firmware/WHENCE                |    5 +++++
 firmware/cis/COMpad2.cis.ihex  |   11 +++++++++++
 firmware/cis/COMpad4.cis.ihex  |    9 +++++++++
 firmware/cis/DP83903.cis.ihex  |   14 ++++++++++++++
 firmware/cis/NE2K.cis.ihex     |    8 ++++++++
 firmware/cis/tamarack.cis.ihex |   10 ++++++++++
 9 files changed, 73 insertions(+), 13 deletions(-)

diff -uprN linux-2.6.32-rc1.orig/drivers/net/pcmcia/pcnet_cs.c linux-2.6.32-rc1/drivers/net/pcmcia/pcnet_cs.c
--- linux-2.6.32-rc1.orig/drivers/net/pcmcia/pcnet_cs.c	2009-10-03 10:52:41.000000000 +0900
+++ linux-2.6.32-rc1/drivers/net/pcmcia/pcnet_cs.c	2009-10-03 11:13:10.000000000 +0900
@@ -1754,14 +1754,14 @@ static struct pcmcia_device_id pcnet_ids
 	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(0, "Psion Dacom", "Gold Card V34 Ethernet", 0xf5f025c2, 0x338e8155, "cis/PCMLM28.cis"),
 	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(0, "Psion Dacom", "Gold Card V34 Ethernet GSM", 0xf5f025c2, 0x4ae85d35, "cis/PCMLM28.cis"),
 	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(0, "LINKSYS", "PCMLM28", 0xf7cb0b07, 0x66881874, "cis/PCMLM28.cis"),
-	PCMCIA_MFC_DEVICE_CIS_PROD_ID12(0, "DAYNA COMMUNICATIONS", "LAN AND MODEM MULTIFUNCTION", 0x8fdf8f89, 0xdd5ed9e8, "DP83903.cis"),
-	PCMCIA_MFC_DEVICE_CIS_PROD_ID4(0, "NSC MF LAN/Modem", 0x58fc6056, "DP83903.cis"),
-	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(0, 0x0175, 0x0000, "DP83903.cis"),
+	PCMCIA_MFC_DEVICE_CIS_PROD_ID12(0, "DAYNA COMMUNICATIONS", "LAN AND MODEM MULTIFUNCTION", 0x8fdf8f89, 0xdd5ed9e8, "cis/DP83903.cis"),
+	PCMCIA_MFC_DEVICE_CIS_PROD_ID4(0, "NSC MF LAN/Modem", 0x58fc6056, "cis/DP83903.cis"),
+	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(0, 0x0175, 0x0000, "cis/DP83903.cis"),
 	PCMCIA_DEVICE_CIS_MANF_CARD(0xc00f, 0x0002, "cis/LA-PCM.cis"),
 	PCMCIA_DEVICE_CIS_PROD_ID12("KTI", "PE520 PLUS", 0xad180345, 0x9d58d392, "PE520.cis"),
-	PCMCIA_DEVICE_CIS_PROD_ID12("NDC", "Ethernet", 0x01c43ae1, 0x00b2e941, "NE2K.cis"),
+	PCMCIA_DEVICE_CIS_PROD_ID12("NDC", "Ethernet", 0x01c43ae1, 0x00b2e941, "cis/NE2K.cis"),
 	PCMCIA_DEVICE_CIS_PROD_ID12("PMX   ", "PE-200", 0x34f3f1c8, 0x10b59f8c, "PE-200.cis"),
-	PCMCIA_DEVICE_CIS_PROD_ID12("TAMARACK", "Ethernet", 0xcf434fba, 0x00b2e941, "tamarack.cis"),
+	PCMCIA_DEVICE_CIS_PROD_ID12("TAMARACK", "Ethernet", 0xcf434fba, 0x00b2e941, "cis/tamarack.cis"),
 	PCMCIA_DEVICE_PROD_ID12("Ethernet", "CF Size PC Card", 0x00b2e941, 0x43ac239b),
 	PCMCIA_DEVICE_PROD_ID123("Fast Ethernet", "CF Size PC Card", "1.0",
 		0xb4be14e3, 0x43ac239b, 0x0877b627),
diff -uprN linux-2.6.32-rc1.orig/drivers/serial/serial_cs.c linux-2.6.32-rc1/drivers/serial/serial_cs.c
--- linux-2.6.32-rc1.orig/drivers/serial/serial_cs.c	2009-10-03 10:52:42.000000000 +0900
+++ linux-2.6.32-rc1/drivers/serial/serial_cs.c	2009-10-03 11:12:46.000000000 +0900
@@ -873,10 +873,10 @@ static struct pcmcia_device_id serial_id
 	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(1, "Psion Dacom", "Gold Card V34 Ethernet", 0xf5f025c2, 0x338e8155, "cis/PCMLM28.cis"),
 	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(1, "Psion Dacom", "Gold Card V34 Ethernet GSM", 0xf5f025c2, 0x4ae85d35, "cis/PCMLM28.cis"),
 	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(1, "LINKSYS", "PCMLM28", 0xf7cb0b07, 0x66881874, "cis/PCMLM28.cis"),
-	PCMCIA_MFC_DEVICE_CIS_PROD_ID12(1, "DAYNA COMMUNICATIONS", "LAN AND MODEM MULTIFUNCTION", 0x8fdf8f89, 0xdd5ed9e8, "DP83903.cis"),
-	PCMCIA_MFC_DEVICE_CIS_PROD_ID4(1, "NSC MF LAN/Modem", 0x58fc6056, "DP83903.cis"),
+	PCMCIA_MFC_DEVICE_CIS_PROD_ID12(1, "DAYNA COMMUNICATIONS", "LAN AND MODEM MULTIFUNCTION", 0x8fdf8f89, 0xdd5ed9e8, "cis/DP83903.cis"),
+	PCMCIA_MFC_DEVICE_CIS_PROD_ID4(1, "NSC MF LAN/Modem", 0x58fc6056, "cis/DP83903.cis"),
 	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(1, 0x0101, 0x0556, "cis/3CCFEM556.cis"),
-	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(1, 0x0175, 0x0000, "DP83903.cis"),
+	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(1, 0x0175, 0x0000, "cis/DP83903.cis"),
 	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(1, 0x0101, 0x0035, "cis/3CXEM556.cis"),
 	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(1, 0x0101, 0x003d, "cis/3CXEM556.cis"),
 	PCMCIA_DEVICE_CIS_PROD_ID12("Sierra Wireless", "AC850", 0xd85f6206, 0x42a2c018, "SW_8xx_SER.cis"),  /* Sierra Wireless AC850 3G Network Adapter R1 */
@@ -884,9 +884,9 @@ static struct pcmcia_device_id serial_id
 	PCMCIA_DEVICE_CIS_MANF_CARD(0x0192, 0xa555, "SW_555_SER.cis"),  /* Sierra Aircard 555 CDMA 1xrtt Modem -- pre update */
 	PCMCIA_DEVICE_CIS_MANF_CARD(0x013f, 0xa555, "SW_555_SER.cis"),  /* Sierra Aircard 555 CDMA 1xrtt Modem -- post update */
 	PCMCIA_DEVICE_CIS_PROD_ID12("MultiTech", "PCMCIA 56K DataFax", 0x842047ee, 0xc2efcf03, "cis/MT5634ZLX.cis"),
-	PCMCIA_DEVICE_CIS_PROD_ID12("ADVANTECH", "COMpad-32/85B-2", 0x96913a85, 0x27ab5437, "COMpad2.cis"),
-	PCMCIA_DEVICE_CIS_PROD_ID12("ADVANTECH", "COMpad-32/85B-4", 0x96913a85, 0xcec8f102, "COMpad4.cis"),
-	PCMCIA_DEVICE_CIS_PROD_ID123("ADVANTECH", "COMpad-32/85", "1.0", 0x96913a85, 0x8fbe92ae, 0x0877b627, "COMpad2.cis"),
+	PCMCIA_DEVICE_CIS_PROD_ID12("ADVANTECH", "COMpad-32/85B-2", 0x96913a85, 0x27ab5437, "cis/COMpad2.cis"),
+	PCMCIA_DEVICE_CIS_PROD_ID12("ADVANTECH", "COMpad-32/85B-4", 0x96913a85, 0xcec8f102, "cis/COMpad4.cis"),
+	PCMCIA_DEVICE_CIS_PROD_ID123("ADVANTECH", "COMpad-32/85", "1.0", 0x96913a85, 0x8fbe92ae, 0x0877b627, "cis/COMpad2.cis"),
 	PCMCIA_DEVICE_CIS_PROD_ID2("RS-COM 2P", 0xad20b156, "cis/RS-COM-2P.cis"),
 	PCMCIA_DEVICE_CIS_MANF_CARD(0x0013, 0x0000, "GLOBETROTTER.cis"),
 	PCMCIA_DEVICE_PROD_ID12("ELAN DIGITAL SYSTEMS LTD, c1997.","SERIAL CARD: SL100  1.00.",0x19ca78af,0xf964f42b),
diff -uprN linux-2.6.32-rc1.orig/firmware/Makefile linux-2.6.32-rc1/firmware/Makefile
--- linux-2.6.32-rc1.orig/firmware/Makefile	2009-10-03 10:52:43.000000000 +0900
+++ linux-2.6.32-rc1/firmware/Makefile	2009-10-03 11:03:01.000000000 +0900
@@ -67,10 +67,13 @@ fw-shipped-$(CONFIG_DVB_TTUSB_BUDGET) +=
 fw-shipped-$(CONFIG_E100) += e100/d101m_ucode.bin e100/d101s_ucode.bin \
 			     e100/d102e_ucode.bin
 fw-shipped-$(CONFIG_MYRI_SBUS) += myricom/lanai.bin
-fw-shipped-$(CONFIG_PCMCIA_PCNET) += cis/LA-PCM.cis cis/PCMLM28.cis
+fw-shipped-$(CONFIG_PCMCIA_PCNET) += cis/LA-PCM.cis cis/PCMLM28.cis \
+				     cis/DP83903.cis cis/NE2K.cis \
+				     cis/tamarack.cis
 fw-shipped-$(CONFIG_PCMCIA_3C589) += cis/3CXEM556.cis
 fw-shipped-$(CONFIG_PCMCIA_3C574) += cis/3CCFEM556.cis
-fw-shipped-$(CONFIG_SERIAL_8250_CS) += cis/MT5634ZLX.cis cis/RS-COM-2P.cis
+fw-shipped-$(CONFIG_SERIAL_8250_CS) += cis/MT5634ZLX.cis cis/RS-COM-2P.cis \
+				       cis/COMpad2.cis cis/COMpad4.cis
 fw-shipped-$(CONFIG_PCMCIA_SMC91C92) += ositech/Xilinx7OD.bin
 fw-shipped-$(CONFIG_SCSI_ADVANSYS) += advansys/mcode.bin advansys/38C1600.bin \
 				      advansys/3550.bin advansys/38C0800.bin
diff -uprN linux-2.6.32-rc1.orig/firmware/WHENCE linux-2.6.32-rc1/firmware/WHENCE
--- linux-2.6.32-rc1.orig/firmware/WHENCE	2009-10-03 10:52:43.000000000 +0900
+++ linux-2.6.32-rc1/firmware/WHENCE	2009-10-03 11:06:04.000000000 +0900
@@ -597,6 +597,9 @@ Driver: PCMCIA_PCNET - NE2000 compatible
 
 File: cis/LA-PCM.cis
       cis/PCMLM28.cis
+      cis/DP83903.cis
+      cis/NE2K.cis
+      cis/tamarack.cis
 
 Licence: GPL
 
@@ -628,6 +631,8 @@ Driver: SERIAL_8250_CS - Serial PCMCIA a
 
 File: cis/MT5634ZLX.cis
       cis/RS-COM-2P.cis
+      cis/COMpad2.cis
+      cis/COMpad4.cis
 
 Licence: GPL
 
diff -uprN linux-2.6.32-rc1.orig/firmware/cis/COMpad2.cis.ihex linux-2.6.32-rc1/firmware/cis/COMpad2.cis.ihex
--- linux-2.6.32-rc1.orig/firmware/cis/COMpad2.cis.ihex	1970-01-01 09:00:00.000000000 +0900
+++ linux-2.6.32-rc1/firmware/cis/COMpad2.cis.ihex	2009-10-03 10:56:23.000000000 +0900
@@ -0,0 +1,11 @@
+:1000000001030000FF151F0401414456414E5445B1
+:10001000434800434F4D7061642D33322F38350013
+:10002000312E300000FF210202011A0501050001F6
+:10003000031B0EC18118AA61E80207E8030730B864
+:100040009E1B08820108AA6030030F1B0883010869
+:10005000AA6040030F1B08840108AA6050030F1B0D
+:0D00600008850108AA6060030F1400FF006E
+:00000001FF
+#
+# Replacement CIS for Advantech COMpad-32/85
+#
diff -uprN linux-2.6.32-rc1.orig/firmware/cis/COMpad4.cis.ihex linux-2.6.32-rc1/firmware/cis/COMpad4.cis.ihex
--- linux-2.6.32-rc1.orig/firmware/cis/COMpad4.cis.ihex	1970-01-01 09:00:00.000000000 +0900
+++ linux-2.6.32-rc1/firmware/cis/COMpad4.cis.ihex	2009-10-03 10:56:33.000000000 +0900
@@ -0,0 +1,9 @@
+:1000000001030000FF151F0401414456414E5445B1
+:10001000434800434F4D7061642D33322F383542D1
+:100020002D34000000FF210202011A050102000127
+:10003000011B0BC18118AA6040021F30B89E1B082B
+:0C004000820108AA6040031F1400FF00AA
+:00000001FF
+#
+# Replacement CIS for Advantech COMpad-32/85B-4
+#
diff -uprN linux-2.6.32-rc1.orig/firmware/cis/DP83903.cis.ihex linux-2.6.32-rc1/firmware/cis/DP83903.cis.ihex
--- linux-2.6.32-rc1.orig/firmware/cis/DP83903.cis.ihex	1970-01-01 09:00:00.000000000 +0900
+++ linux-2.6.32-rc1/firmware/cis/DP83903.cis.ihex	2009-10-03 10:56:11.000000000 +0900
@@ -0,0 +1,14 @@
+:1000000001030000FF152904014D756C74696675C4
+:100010006E6374696F6E20436172640000004E531A
+:1000200043204D46204C414E2F4D6F64656D00FFBF
+:1000300020047501000021020000060B02004900A7
+:100040000000006A000000FF00130343495321022F
+:1000500006001A060517201077021B0C970179017C
+:10006000556530FFFF284000FF001303434953212B
+:100070000202001A060507401077021B09870119C2
+:0800800001552330FFFFFF00D2
+:00000001FF
+#
+# This CIS is for cards based on the National Semiconductor
+# DP83903 Multiple Function Interface Chip
+#
diff -uprN linux-2.6.32-rc1.orig/firmware/cis/NE2K.cis.ihex linux-2.6.32-rc1/firmware/cis/NE2K.cis.ihex
--- linux-2.6.32-rc1.orig/firmware/cis/NE2K.cis.ihex	1970-01-01 09:00:00.000000000 +0900
+++ linux-2.6.32-rc1/firmware/cis/NE2K.cis.ihex	2009-10-03 10:57:26.000000000 +0900
@@ -0,0 +1,8 @@
+:1000000001030000FF1515040150434D4349410011
+:1000100045746865726E6574000000FF2102060079
+:100020001A050120F803031B09E001190155653089
+:06003000FFFF1400FF00B9
+:00000001FF
+#
+# Replacement CIS for various busted NE2000-compatible cards
+#
diff -uprN linux-2.6.32-rc1.orig/firmware/cis/tamarack.cis.ihex linux-2.6.32-rc1/firmware/cis/tamarack.cis.ihex
--- linux-2.6.32-rc1.orig/firmware/cis/tamarack.cis.ihex	1970-01-01 09:00:00.000000000 +0900
+++ linux-2.6.32-rc1/firmware/cis/tamarack.cis.ihex	2009-10-03 10:57:33.000000000 +0900
@@ -0,0 +1,10 @@
+:100000000103D400FF17034100FF152404015441EC
+:100010004D415241434B0045746865726E657400F2
+:10002000410030303437343331313830303100FF33
+:10003000210206001A050120F803031B14E08119B0
+:100040003F554D5D06864626E551000F100F30FFE7
+:05005000FF1400FF0099
+:00000001FF
+#
+# Replacement CIS for Surecom, Tamarack NE2000 cards
+#
