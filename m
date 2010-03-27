From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 2.6.34-rc2] pcnet_cs: add new id
Date: Sun, 28 Mar 2010 05:55:37 +0900
Message-ID: <20100328055537.13ef6c01.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	<20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	<20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	<20091004073257.52a6624b.ken_kawasaki@spring.nifty.jp>
	<20091221205849.dae4e929.ken_kawasaki@spring.nifty.jp>
	<20091223171004.77316fa5.ken_kawasaki@spring.nifty.jp>
	<20100123065625.db751a12.ken_kawasaki@spring.nifty.jp>
	<20100228083420.9ca8e285.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg506.nifty.com ([202.248.238.86]:44841 "EHLO
	userg506.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753949Ab0C0U4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 16:56:04 -0400
Received: from localhost.localdomain (eaoska167177.adsl.ppp.infoweb.ne.jp [219.116.16.177])by userg506.nifty.com with SMTP id o2RKtmcU012370
	for <netdev@vger.kernel.org>; Sun, 28 Mar 2010 05:55:48 +0900
In-Reply-To: <20100228083420.9ca8e285.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


pcnet_cs:
 *add new id (Allied Telesis LM33-PCM-T Lan&Modem multifunction card)
 *use PROD_ID for LA-PCM.(because LA-PCM and LM33-PCM-T use the same MANF_ID).

Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-2.6.34-rc2/drivers/net/pcmcia/pcnet_cs.c.orig	2010-03-21 20:39:59.000000000 +0900
+++ linux-2.6.34-rc2/drivers/net/pcmcia/pcnet_cs.c	2010-03-27 14:42:34.000000000 +0900
@@ -1549,6 +1549,7 @@ static struct pcmcia_device_id pcnet_ids
 	PCMCIA_PFC_DEVICE_MANF_CARD(0, 0x021b, 0x0101),
 	PCMCIA_PFC_DEVICE_MANF_CARD(0, 0x08a1, 0xc0ab),
 	PCMCIA_PFC_DEVICE_PROD_ID12(0, "AnyCom", "Fast Ethernet + 56K COMBO", 0x578ba6e7, 0xb0ac62c4),
+	PCMCIA_PFC_DEVICE_PROD_ID12(0, "ATKK", "LM33-PCM-T", 0xba9eb7e2, 0x077c174e),
 	PCMCIA_PFC_DEVICE_PROD_ID12(0, "D-Link", "DME336T", 0x1a424a1c, 0xb23897ff),
 	PCMCIA_PFC_DEVICE_PROD_ID12(0, "Grey Cell", "GCS3000", 0x2a151fac, 0x48b932ae),
 	PCMCIA_PFC_DEVICE_PROD_ID12(0, "Linksys", "EtherFast 10&100 + 56K PC Card (PCMLM56)", 0x0733cc81, 0xb3765033),
@@ -1740,7 +1741,7 @@ static struct pcmcia_device_id pcnet_ids
 	PCMCIA_MFC_DEVICE_CIS_PROD_ID12(0, "DAYNA COMMUNICATIONS", "LAN AND MODEM MULTIFUNCTION", 0x8fdf8f89, 0xdd5ed9e8, "cis/DP83903.cis"),
 	PCMCIA_MFC_DEVICE_CIS_PROD_ID4(0, "NSC MF LAN/Modem", 0x58fc6056, "cis/DP83903.cis"),
 	PCMCIA_MFC_DEVICE_CIS_MANF_CARD(0, 0x0175, 0x0000, "cis/DP83903.cis"),
-	PCMCIA_DEVICE_CIS_MANF_CARD(0xc00f, 0x0002, "cis/LA-PCM.cis"),
+	PCMCIA_DEVICE_CIS_PROD_ID12("Allied Telesis,K.K", "Ethernet LAN Card", 0x2ad62f3c, 0x9fd2f0a2, "cis/LA-PCM.cis"),
 	PCMCIA_DEVICE_CIS_PROD_ID12("KTI", "PE520 PLUS", 0xad180345, 0x9d58d392, "cis/PE520.cis"),
 	PCMCIA_DEVICE_CIS_PROD_ID12("NDC", "Ethernet", 0x01c43ae1, 0x00b2e941, "cis/NE2K.cis"),
 	PCMCIA_DEVICE_CIS_PROD_ID12("PMX   ", "PE-200", 0x34f3f1c8, 0x10b59f8c, "cis/PE-200.cis"),
--- linux-2.6.34-rc2/drivers/serial/serial_cs.c.orig	2010-03-22 06:53:31.000000000 +0900
+++ linux-2.6.34-rc2/drivers/serial/serial_cs.c	2010-03-27 14:42:53.000000000 +0900
@@ -745,6 +745,7 @@ static struct pcmcia_device_id serial_id
 	PCMCIA_PFC_DEVICE_PROD_ID13(1, "Xircom", "REM10", 0x2e3ee845, 0x76df1d29),
 	PCMCIA_PFC_DEVICE_PROD_ID13(1, "Xircom", "XEM5600", 0x2e3ee845, 0xf1403719),
 	PCMCIA_PFC_DEVICE_PROD_ID12(1, "AnyCom", "Fast Ethernet + 56K COMBO", 0x578ba6e7, 0xb0ac62c4),
+	PCMCIA_PFC_DEVICE_PROD_ID12(1, "ATKK", "LM33-PCM-T", 0xba9eb7e2, 0x077c174e),
 	PCMCIA_PFC_DEVICE_PROD_ID12(1, "D-Link", "DME336T", 0x1a424a1c, 0xb23897ff),
 	PCMCIA_PFC_DEVICE_PROD_ID12(1, "Gateway 2000", "XJEM3336", 0xdd9989be, 0x662c394c),
 	PCMCIA_PFC_DEVICE_PROD_ID12(1, "Grey Cell", "GCS3000", 0x2a151fac, 0x48b932ae),
