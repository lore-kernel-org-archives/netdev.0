From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH] pcnet_cs: add cis of Linksys multifunction pcmcia card
Date: Sun, 13 Sep 2009 07:22:03 +0900
Message-ID: <20090913072203.d92f1734.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	<20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ken_kawasaki@spring.nifty.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sv1.nifty.com ([220.209.183.60]:42440 "EHLO
	defg303p.nifty.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752822AbZILWcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Sep 2009 18:32:43 -0400
Received: from userg500.nifty.com (userg500p.nifty.com [172.22.128.80])by defg303p.nifty.com with ESMTP id n8CMMgeW022776
	for <netdev@vger.kernel.org>; Sun, 13 Sep 2009 07:22:42 +0900
In-Reply-To: <20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


pcnet_cs,serial_cs:
 
add cis of Linksys lan&modem mulitifunction pcmcia card
and some modem card(MT5634ZLX, RS-COM-2P).

  
Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
 
---
 
 drivers/net/pcmcia/pcnet_cs.c   |   10 +++++-----
 drivers/serial/serial_cs.c      |   14 +++++++-------
 firmware/Makefile               |    3 ++-
 firmware/WHENCE                 |   12 ++++++++++++
 firmware/cis/MT5634ZLX.cis.ihex |   11 +++++++++++
 firmware/cis/PCMLM28.cis.ihex   |   18 ++++++++++++++++++
 firmware/cis/RS-COM-2P.cis.ihex |   10 ++++++++++
 7 files changed, 65 insertions(+), 13 deletions(-)

diff -uprN linux-2.6.31.orig/drivers/net/pcmcia/pcnet_cs.c linux-2.6.31/drivers/net/pcmcia/pcnet_cs.c
--- linux-2.6.31.orig/drivers/net/pcmcia/pcnet_cs.c	2009-09-10 07:13:59.000000000 +0900
+++ linux-2.6.31/drivers/net/pcmcia/pcnet_cs.c	2009-09-12 19:59:57.000000000 +0900
@@ -1751,11 +1751,11 @@ static struct pcmcia_device_id pcnet_ids
 	PCMCIA_DEVICE_PROD_ID2("EN-6200P2", 0xa996d078),
 	/* too generic! */
 	/* PCMCIA_DEVICE_PROD_ID12("PCMCIA", "10/100 Ethernet Card", 0x281f1c5d, 0x11b0ffc0), */
-	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(0, "PCMCIA", "EN2218-LAN/MODEM", 0x281f1c5d, 0x570f348e, "PCMLM28.cis"),
-	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(0, "PCMCIA", "UE2218-LAN/MODEM", 0x281f1c5d, 0x6fdcacee, "PCMLM28.cis"),
-	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(0, "Psion Dacom", "Gold Card V34 Ethernet", 0xf5f025c2, 0x338e8155, "PCMLM28.cis"),
-	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(0, "Psion Dacom", "Gold Card V34 Ethernet GSM", 0xf5f025c2, 0x4ae85d35, "PCMLM28.cis"),
-	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(0, "LINKSYS", "PCMLM28", 0xf7cb0b07, 0x66881874, "PCMLM28.cis"),
+	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(0, "PCMCIA", "EN2218-LAN/MODEM", 0x281f1c5d, 0x570f348e, "cis/PCMLM28.cis"),
+	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(0, "PCMCIA", "UE2218-LAN/MODEM", 0x281f1c5d, 0x6fdcacee, "cis/PCMLM28.cis"),
+	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(0, "Psion Dacom", "Gold Card V34 Ethernet", 0xf5f025c2, 0x338e8155, "cis/PCMLM28.cis"),
+	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(0, "Psion Dacom", "Gold Card V34 Ethernet GSM", 0xf5f025c2, 0x4ae85d35, "cis/PCMLM28.cis"),
+	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(0, "LINKSYS", "PCMLM28", 0xf7cb0b07, 0x66881874, "cis/PCMLM28.cis"),
 	PCMCIA_MFC_DEVICE_CIS_PROD_ID12(0, "DAYNA COMMUNICATIONS", "LAN AND MODEM MULTIFUNCTION", 0x8fdf8f89, 0xdd5ed9e8, "DP83903.cis"),
 	PCMCIA_MFC_DEVICE_CIS_PROD_ID4(0, "NSC MF LAN/Modem", 0x58fc6056, "DP83903.cis"),
 	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(0, 0x0175, 0x0000, "DP83903.cis"),
diff -uprN linux-2.6.31.orig/drivers/serial/serial_cs.c linux-2.6.31/drivers/serial/serial_cs.c
--- linux-2.6.31.orig/drivers/serial/serial_cs.c	2009-09-10 07:13:59.000000000 +0900
+++ linux-2.6.31/drivers/serial/serial_cs.c	2009-09-12 20:02:33.000000000 +0900
@@ -868,11 +868,11 @@ static struct pcmcia_device_id serial_id
 	PCMCIA_DEVICE_PROD_ID12("PCMCIA   ", "C336MX     ", 0x99bcafe9, 0xaa25bcab),
 	PCMCIA_DEVICE_PROD_ID12("Quatech Inc", "PCMCIA Dual RS-232 Serial Port Card", 0xc4420b35, 0x92abc92f),
 	PCMCIA_DEVICE_PROD_ID12("Quatech Inc", "Dual RS-232 Serial Port PC Card", 0xc4420b35, 0x031a380d),
-	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(1, "PCMCIA", "EN2218-LAN/MODEM", 0x281f1c5d, 0x570f348e, "PCMLM28.cis"),
-	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(1, "PCMCIA", "UE2218-LAN/MODEM", 0x281f1c5d, 0x6fdcacee, "PCMLM28.cis"),
-	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(1, "Psion Dacom", "Gold Card V34 Ethernet", 0xf5f025c2, 0x338e8155, "PCMLM28.cis"),
-	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(1, "Psion Dacom", "Gold Card V34 Ethernet GSM", 0xf5f025c2, 0x4ae85d35, "PCMLM28.cis"),
-	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(1, "LINKSYS", "PCMLM28", 0xf7cb0b07, 0x66881874, "PCMLM28.cis"),
+	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(1, "PCMCIA", "EN2218-LAN/MODEM", 0x281f1c5d, 0x570f348e, "cis/PCMLM28.cis"),
+	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(1, "PCMCIA", "UE2218-LAN/MODEM", 0x281f1c5d, 0x6fdcacee, "cis/PCMLM28.cis"),
+	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(1, "Psion Dacom", "Gold Card V34 Ethernet", 0xf5f025c2, 0x338e8155, "cis/PCMLM28.cis"),
+	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(1, "Psion Dacom", "Gold Card V34 Ethernet GSM", 0xf5f025c2, 0x4ae85d35, "cis/PCMLM28.cis"),
+	PCMCIA_PFC_DEVICE_CIS_PROD_ID12(1, "LINKSYS", "PCMLM28", 0xf7cb0b07, 0x66881874, "cis/PCMLM28.cis"),
 	PCMCIA_MFC_DEVICE_CIS_PROD_ID12(1, "DAYNA COMMUNICATIONS", "LAN AND MODEM MULTIFUNCTION", 0x8fdf8f89, 0xdd5ed9e8, "DP83903.cis"),
 	PCMCIA_MFC_DEVICE_CIS_PROD_ID4(1, "NSC MF LAN/Modem", 0x58fc6056, "DP83903.cis"),
 	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(1, 0x0101, 0x0556, "cis/3CCFEM556.cis"),
@@ -883,10 +883,10 @@ static struct pcmcia_device_id serial_id
 	PCMCIA_DEVICE_CIS_MANF_CARD(0x0192, 0x0710, "SW_7xx_SER.cis"),	/* Sierra Wireless AC710/AC750 GPRS Network Adapter R1 */
 	PCMCIA_DEVICE_CIS_MANF_CARD(0x0192, 0xa555, "SW_555_SER.cis"),  /* Sierra Aircard 555 CDMA 1xrtt Modem -- pre update */
 	PCMCIA_DEVICE_CIS_MANF_CARD(0x013f, 0xa555, "SW_555_SER.cis"),  /* Sierra Aircard 555 CDMA 1xrtt Modem -- post update */
-	PCMCIA_DEVICE_CIS_PROD_ID12("MultiTech", "PCMCIA 56K DataFax", 0x842047ee, 0xc2efcf03, "MT5634ZLX.cis"),
+	PCMCIA_DEVICE_CIS_PROD_ID12("MultiTech", "PCMCIA 56K DataFax", 0x842047ee, 0xc2efcf03, "cis/MT5634ZLX.cis"),
 	PCMCIA_DEVICE_CIS_PROD_ID12("ADVANTECH", "COMpad-32/85B-4", 0x96913a85, 0xcec8f102, "COMpad4.cis"),
 	PCMCIA_DEVICE_CIS_PROD_ID123("ADVANTECH", "COMpad-32/85", "1.0", 0x96913a85, 0x8fbe92ae, 0x0877b627, "COMpad2.cis"),
-	PCMCIA_DEVICE_CIS_PROD_ID2("RS-COM 2P", 0xad20b156, "RS-COM-2P.cis"),
+	PCMCIA_DEVICE_CIS_PROD_ID2("RS-COM 2P", 0xad20b156, "cis/RS-COM-2P.cis"),
 	PCMCIA_DEVICE_CIS_MANF_CARD(0x0013, 0x0000, "GLOBETROTTER.cis"),
 	PCMCIA_DEVICE_PROD_ID12("ELAN DIGITAL SYSTEMS LTD, c1997.","SERIAL CARD: SL100  1.00.",0x19ca78af,0xf964f42b),
 	PCMCIA_DEVICE_PROD_ID12("ELAN DIGITAL SYSTEMS LTD, c1997.","SERIAL CARD: SL100",0x19ca78af,0x71d98e83),
diff -uprN linux-2.6.31.orig/firmware/cis/MT5634ZLX.cis.ihex linux-2.6.31/firmware/cis/MT5634ZLX.cis.ihex
--- linux-2.6.31.orig/firmware/cis/MT5634ZLX.cis.ihex	1970-01-01 09:00:00.000000000 +0900
+++ linux-2.6.31/firmware/cis/MT5634ZLX.cis.ihex	2009-09-12 19:58:04.000000000 +0900
@@ -0,0 +1,11 @@
+:100000000101FF152204014D756C74695465636824
+:100010000050434D4349412035364B2044617461C3
+:10002000466178000000FF20040002010021020266
+:10003000001A05012780FF671B0FCF418B01550177
+:10004000550155AA60F80307281B08970108AA6004
+:10005000F802071B089F0108AA60E803071B08A70E
+:0B0060000108AA60E802071400FF007E
+:00000001FF
+#
+# Replacement CIS for Multitech MT5634ZLX modems
+#
diff -uprN linux-2.6.31.orig/firmware/cis/PCMLM28.cis.ihex linux-2.6.31/firmware/cis/PCMLM28.cis.ihex
--- linux-2.6.31.orig/firmware/cis/PCMLM28.cis.ihex	1970-01-01 09:00:00.000000000 +0900
+++ linux-2.6.31/firmware/cis/PCMLM28.cis.ihex	2009-09-12 19:57:29.000000000 +0900
@@ -0,0 +1,18 @@
+:1000000001030000FF151504014C494E4B53595391
+:100010000050434D4C4D3238000000FF2004430196
+:10002000ABC0210200001A05012FF803031B10E4E6
+:1000300001190155E06100031FF8020730FFFF1BA3
+:100040000BA50108E06120031FF802071B0BA601A6
+:1000500008E06140031FF802071B0BA70108E061DD
+:1000600060031FF802071B0BA80108E06100031FD3
+:10007000E803071B0BA90108E06120031FE8030741
+:100080001B0BAA0108E06140031FE803071B0BAB31
+:100090000108E06160031FE803071B0BAC0108E0E7
+:1000A0006100031FE802071B0BAD0108E06120039C
+:1000B0001FE802071B0BAE0108E06140031FE802C6
+:1000C000071B0BAF0108E06160031FE80207140083
+:0200D000FF002F
+:00000001FF
+#
+# The on-card CIS says it is MFC-compliant, but it is not
+#
diff -uprN linux-2.6.31.orig/firmware/cis/RS-COM-2P.cis.ihex linux-2.6.31/firmware/cis/RS-COM-2P.cis.ihex
--- linux-2.6.31.orig/firmware/cis/RS-COM-2P.cis.ihex	1970-01-01 09:00:00.000000000 +0900
+++ linux-2.6.31/firmware/cis/RS-COM-2P.cis.ihex	2009-09-12 19:58:12.000000000 +0900
@@ -0,0 +1,10 @@
+:1000000001030000FF1516040150434D4349410010
+:1000100052532D434F4D203250000000FF21020269
+:10002000011A0501030001011B0EC18118AA61E834
+:100030000307E8020730B89E1B0B820108AA615033
+:1000400002075802071B0B830108AA6160020768B8
+:0600500002071400FF008E
+:00000001FF
+#
+# Replacement CIS for dual-serial-port IO card
+#
diff -uprN linux-2.6.31.orig/firmware/Makefile linux-2.6.31/firmware/Makefile
--- linux-2.6.31.orig/firmware/Makefile	2009-09-10 07:13:59.000000000 +0900
+++ linux-2.6.31/firmware/Makefile	2009-09-12 20:12:11.000000000 +0900
@@ -47,9 +47,10 @@ fw-shipped-$(CONFIG_DVB_TTUSB_BUDGET) +=
 fw-shipped-$(CONFIG_E100) += e100/d101m_ucode.bin e100/d101s_ucode.bin \
 			     e100/d102e_ucode.bin
 fw-shipped-$(CONFIG_MYRI_SBUS) += myricom/lanai.bin
-fw-shipped-$(CONFIG_PCMCIA_PCNET) += cis/LA-PCM.cis
+fw-shipped-$(CONFIG_PCMCIA_PCNET) += cis/LA-PCM.cis cis/PCMLM28.cis
 fw-shipped-$(CONFIG_PCMCIA_3C589) += cis/3CXEM556.cis
 fw-shipped-$(CONFIG_PCMCIA_3C574) += cis/3CCFEM556.cis
+fw-shipped-$(CONFIG_SERIAL_8250_CS) += cis/MT5634ZLX.cis cis/RS-COM-2P.cis
 fw-shipped-$(CONFIG_PCMCIA_SMC91C92) += ositech/Xilinx7OD.bin
 fw-shipped-$(CONFIG_SCSI_ADVANSYS) += advansys/mcode.bin advansys/38C1600.bin \
 				      advansys/3550.bin advansys/38C0800.bin
diff -uprN linux-2.6.31.orig/firmware/WHENCE linux-2.6.31/firmware/WHENCE
--- linux-2.6.31.orig/firmware/WHENCE	2009-09-10 07:13:59.000000000 +0900
+++ linux-2.6.31/firmware/WHENCE	2009-09-12 20:09:40.000000000 +0900
@@ -579,6 +579,7 @@ Found in hex form in kernel source.
 Driver: PCMCIA_PCNET - NE2000 compatible PCMCIA adapter
 
 File: cis/LA-PCM.cis
+      cis/PCMLM28.cis
 
 Licence: GPL
 
@@ -606,6 +607,17 @@ Originally developed by the pcmcia-cs pr
 
 --------------------------------------------------------------------------
 
+Driver: SERIAL_8250_CS - Serial PCMCIA adapter
+
+File: cis/MT5634ZLX.cis
+      cis/RS-COM-2P.cis
+
+Licence: GPL
+
+Originally developed by the pcmcia-cs project
+
+--------------------------------------------------------------------------
+
 Driver: PCMCIA_SMC91C92 - SMC 91Cxx PCMCIA
 
 File: ositech/Xilinx7OD.bin

