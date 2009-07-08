From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH] pcnet_cs: add odd location support for write_asic function
Date: Wed, 8 Jul 2009 21:09:24 +0900
Message-ID: <20090708210924.2a486a84.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg500.nifty.com ([202.248.238.80]:25193 "EHLO
	userg500.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753275AbZGHMKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 08:10:04 -0400
Received: from localhost.localdomain (eaoska167022.adsl.ppp.infoweb.ne.jp [219.116.16.22])by userg500.nifty.com with SMTP id n68C9hXG019990
	for <netdev@vger.kernel.org>; Wed, 8 Jul 2009 21:09:43 +0900
In-Reply-To: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-2.6.31-rc1/drivers/net/pcmcia/pcnet_cs.c.orig	2009-06-27 10:15:47.000000000 +0900
+++ linux-2.6.31-rc1/drivers/net/pcmcia/pcnet_cs.c	2009-07-04 10:32:44.000000000 +0900
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
