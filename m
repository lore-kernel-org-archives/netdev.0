From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH] pcnet_cs: add odd location support for write_asic function
Date: Sat, 11 Jul 2009 09:02:13 +0900
Message-ID: <20090711090213.94a771d3.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg501.nifty.com ([202.248.238.81]:61533 "EHLO
	userg501.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755769AbZGKACf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2009 20:02:35 -0400
Received: from localhost.localdomain (eaoska193189.adsl.ppp.infoweb.ne.jp [220.145.30.189])by userg501.nifty.com with SMTP id n6B02EdF021671
	for <netdev@vger.kernel.org>; Sat, 11 Jul 2009 09:02:15 +0900
In-Reply-To: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Currently, no one passes odd location to the write_asic function.
But this patch add odd location support for future usage of this
feature.


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
