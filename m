From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH] pcnet_cs: add cis(firmware) of the Allied Telesis LA-PCM
Date: Sun, 19 Apr 2009 08:44:44 +0900
Message-ID: <20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg502.nifty.com ([202.248.238.82]:35987 "EHLO
	userg502.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752367AbZDRXp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2009 19:45:27 -0400
Received: from localhost.localdomain (eaoska169086.adsl.ppp.infoweb.ne.jp [219.116.18.86])by userg502.nifty.com with SMTP id n3INj7Zo003724
	for <netdev@vger.kernel.org>; Sun, 19 Apr 2009 08:45:08 +0900
In-Reply-To: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


pcnet_cs: add cis(firmware) of the Allied Telesis LA-PCM


Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

diff -uprN linux-2.6.30-rc2.orig/drivers/net/pcmcia/pcnet_cs.c linux-2.6.30-rc2/drivers/net/pcmcia/pcnet_cs.c
--- linux-2.6.30-rc2.orig/drivers/net/pcmcia/pcnet_cs.c	2009-04-12 20:42:39.000000000 +0900
+++ linux-2.6.30-rc2/drivers/net/pcmcia/pcnet_cs.c	2009-04-12 20:29:09.000000000 +0900
@@ -1758,7 +1758,7 @@ static struct pcmcia_device_id pcnet_ids
 	PCMCIA_MFC_DEVICE_CIS_PROD_ID12(0, "DAYNA COMMUNICATIONS", "LAN AND MODEM MULTIFUNCTION", 0x8fdf8f89, 0xdd5ed9e8, "DP83903.cis"),
 	PCMCIA_MFC_DEVICE_CIS_PROD_ID4(0, "NSC MF LAN/Modem", 0x58fc6056, "DP83903.cis"),
 	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(0, 0x0175, 0x0000, "DP83903.cis"),
-	PCMCIA_DEVICE_CIS_MANF_CARD(0xc00f, 0x0002, "LA-PCM.cis"),
+	PCMCIA_DEVICE_CIS_MANF_CARD(0xc00f, 0x0002, "cis/LA-PCM.cis"),
 	PCMCIA_DEVICE_CIS_PROD_ID12("KTI", "PE520 PLUS", 0xad180345, 0x9d58d392, "PE520.cis"),
 	PCMCIA_DEVICE_CIS_PROD_ID12("NDC", "Ethernet", 0x01c43ae1, 0x00b2e941, "NE2K.cis"),
 	PCMCIA_DEVICE_CIS_PROD_ID12("PMX   ", "PE-200", 0x34f3f1c8, 0x10b59f8c, "PE-200.cis"),
diff -uprN linux-2.6.30-rc2.orig/firmware/cis/LA-PCM.cis.ihex linux-2.6.30-rc2/firmware/cis/LA-PCM.cis.ihex
--- linux-2.6.30-rc2.orig/firmware/cis/LA-PCM.cis.ihex	1970-01-01 09:00:00.000000000 +0900
+++ linux-2.6.30-rc2/firmware/cis/LA-PCM.cis.ihex	2009-04-12 20:23:44.000000000 +0900
@@ -0,0 +1,20 @@
+:100000000105D4F953E9FF17035338FF20040FC04B
+:1000100002002102060315390401416C6C69656414
+:100020002054656C657369732C4B2E4B00457468C6
+:1000300065726E6574204C414E20436172640043CA
+:10004000656E747265434F4D004C412D50434D0019
+:10005000FF1A0602100000020B1B08810108E06075
+:1000600000021F1B08820108E06020021F1B08839A
+:100070000108E06040021F1B08840108E060600284
+:100080001F1B08850108E06080021F1B088601080D
+:10009000E060A0021F1B08870108E060C0021F1B70
+:1000A00008880108E060E0021F1B08890108E06081
+:1000B00000031F1B088A0108E06020031F1B088B38
+:1000C0000108E06040031F1B088C0108E06060032A
+:1000D0001F1B088D0108E06080031F1B088E0108AC
+:1000E000E060A0031F1B088F0108E060C0031F1B16
+:0D00F00008900108E060E0031F1400FF000D
+:00000001FF
+#
+# Replacement CIS for Allied Telesis LA-PCM
+#

diff -uprN linux-2.6.30-rc2.orig/firmware/Makefile linux-2.6.30-rc2/firmware/Makefile
--- linux-2.6.30-rc2.orig/firmware/Makefile	2009-04-18 08:52:15.000000000 +0900
+++ linux-2.6.30-rc2/firmware/Makefile	2009-04-18 09:39:49.000000000 +0900
@@ -46,6 +46,7 @@ fw-shipped-$(CONFIG_DVB_TTUSB_BUDGET) +=
 fw-shipped-$(CONFIG_E100) += e100/d101m_ucode.bin e100/d101s_ucode.bin \
 			     e100/d102e_ucode.bin
 fw-shipped-$(CONFIG_MYRI_SBUS) += myricom/lanai.bin
+fw-shipped-$(CONFIG_PCMCIA_PCNET) += cis/LA-PCM.cis
 fw-shipped-$(CONFIG_PCMCIA_SMC91C92) += ositech/Xilinx7OD.bin
 fw-shipped-$(CONFIG_SCSI_ADVANSYS) += advansys/mcode.bin advansys/38C1600.bin \
 				      advansys/3550.bin advansys/38C0800.bin
diff -uprN linux-2.6.30-rc2.orig/firmware/WHENCE linux-2.6.30-rc2/firmware/WHENCE
--- linux-2.6.30-rc2.orig/firmware/WHENCE	2009-04-18 08:52:15.000000000 +0900
+++ linux-2.6.30-rc2/firmware/WHENCE	2009-04-18 09:39:12.000000000 +0900
@@ -576,6 +576,16 @@ Found in hex form in kernel source.
 
 --------------------------------------------------------------------------
 
+Driver: PCMCIA_PCNET - NE2000 compatible PCMCIA adapter
+
+File: cis/LA-PCM.cis
+
+Licence: GPL
+
+Originally developed by the pcmcia-cs project
+
+--------------------------------------------------------------------------
+
 Driver: PCMCIA_SMC91C92 - SMC 91Cxx PCMCIA
 
 File: ositech/Xilinx7OD.bin

