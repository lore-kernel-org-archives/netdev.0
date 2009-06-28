From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH] pcnet_cs: add new id (RIOS System PC CARD3 ETHERNET)
Date: Sun, 28 Jun 2009 09:09:39 +0900
Message-ID: <20090628090939.c04680a3.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sv1.nifty.com ([220.209.183.60]:61692 "EHLO
	defg301p.nifty.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752171AbZF1AWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jun 2009 20:22:54 -0400
Received: from userg502.nifty.com (userg502p.nifty.com [172.22.128.82])by defg301p.nifty.com with ESMTP id n5S0AKkj024932
	for <netdev@vger.kernel.org>; Sun, 28 Jun 2009 09:10:20 +0900
Received: from localhost.localdomain (eaoska192035.adsl.ppp.infoweb.ne.jp [220.145.29.35])by userg502.nifty.com with SMTP id n5S09k8e027478
	for <netdev@vger.kernel.org>; Sun, 28 Jun 2009 09:09:46 +0900
In-Reply-To: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


pcnet_cs:

(1) add new id (RIOS System PC CARD3 ETHERNET).

(2) add odd location support for write_asic function.

(3) change default setting of use_shmem to 0.
    because shared memory does not work on some PC.

Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-2.6.31-rc1/drivers/net/pcmcia/pcnet_cs.c.orig	2009-06-27 10:15:47.000000000 +0900
+++ linux-2.6.31-rc1/drivers/net/pcmcia/pcnet_cs.c	2009-06-27 10:40:34.000000000 +0900
@@ -95,7 +95,7 @@ INT_MODULE_PARM(use_big_buf,	1);	/* use 
 INT_MODULE_PARM(mem_speed,	0);	/* shared mem speed, in ns */
 INT_MODULE_PARM(delay_output,	0);	/* pause after xmit? */
 INT_MODULE_PARM(delay_time,	4);	/* in usec */
-INT_MODULE_PARM(use_shmem,	-1);	/* use shared memory? */
+INT_MODULE_PARM(use_shmem,	0);	/* use shared memory? */
 INT_MODULE_PARM(full_duplex,	0);	/* full duplex? */
 
 /* Ugh!  Let the user hardwire the hardware address for queer cards */
@@ -886,9 +886,10 @@ static void write_asic(unsigned int ioad
 		outb_p(EE_ASIC|EE_CS|EE_DI|dataval, ee_addr);
 	}
 	// sync
-	outb(EE_ASIC|EE_CS, ee_addr);
-	outb(EE_ASIC|EE_CS|EE_CK, ee_addr);
-	outb(EE_ASIC|EE_CS, ee_addr);
+	dataval = (location & 1) ? EE_DO : 0;
+	outb(EE_ASIC|EE_CS|dataval, ee_addr);
+	outb(EE_ASIC|EE_CS|dataval|EE_CK, ee_addr);
+	outb(EE_ASIC|EE_CS|dataval, ee_addr);
 
 	for (i = 15; i >= 0; i--) {
 		dataval = (asic_data & (1 << i)) ? EE_ADOT : 0;
@@ -1727,6 +1728,7 @@ static struct pcmcia_device_id pcnet_ids
 	PCMCIA_DEVICE_PROD_ID12("PRETEC", "Ethernet CompactLAN 10BaseT 3.3V", 0xebf91155, 0x7f5a4f50),
 	PCMCIA_DEVICE_PROD_ID12("Psion Dacom", "Gold Card Ethernet", 0xf5f025c2, 0x3a30e110),
 	PCMCIA_DEVICE_PROD_ID12("=RELIA==", "Ethernet", 0xcdd0644a, 0x00b2e941),
+	PCMCIA_DEVICE_PROD_ID12("RIOS Systems Co.", "PC CARD3 ETHERNET", 0x7dd33481, 0x10b41826),
 	PCMCIA_DEVICE_PROD_ID12("RP", "1625B Ethernet NE2000 Compatible", 0xe3e66e22, 0xb96150df),
 	PCMCIA_DEVICE_PROD_ID12("RPTI", "EP400 Ethernet NE2000 Compatible", 0xdc6f88fd, 0x4a7e2ae0),
 	PCMCIA_DEVICE_PROD_ID12("RPTI", "EP401 Ethernet NE2000 Compatible", 0xdc6f88fd, 0x4bcbd7fd),
