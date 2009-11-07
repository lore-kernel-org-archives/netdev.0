From: Martin Michlmayr <tbm@cyrius.com>
Subject: hisax: remove bad udelay call to fix build error on ARM
Date: Sat, 7 Nov 2009 00:52:34 +0000
Message-ID: <20091107005234.GA1678@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	Tilman Schmidt <tilman@imap.cc>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sorrow.cyrius.com ([65.19.161.204]:51512 "EHLO
	sorrow.cyrius.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757742AbZKGBPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 20:15:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hisax ISDN driver fails to build on ARM with CONFIG_HISAX_ELSA:

| drivers/built-in.o: In function `modem_set_dial':
| drivers/isdn/hisax/elsa_ser.c:535: undefined reference to `__bad_udelay'
| drivers/isdn/hisax/elsa_ser.c:544: undefined reference to `__bad_udelay'
| drivers/built-in.o: In function `modem_set_init':
| drivers/isdn/hisax/elsa_ser.c:486: undefined reference to `__bad_udelay'
| [...]

According to the comment in arch/arm/include/asm/delay.h, __bad_udelay
is specifically designed on ARM to produce a build failure when udelay
is called with a value > 2000.

Signed-off-by: Martin Michlmayr <tbm@cyrius.com>

diff --git a/drivers/isdn/hisax/elsa_ser.c b/drivers/isdn/hisax/elsa_ser.c
index f181db4..1657bba 100644
--- a/drivers/isdn/hisax/elsa_ser.c
+++ b/drivers/isdn/hisax/elsa_ser.c
@@ -477,62 +477,62 @@ static void
 modem_set_init(struct IsdnCardState *cs) {
 	int timeout;
 
-#define RCV_DELAY 20000	
+#define RCV_DELAY 20
 	modem_write_cmd(cs, MInit_1, strlen(MInit_1));
 	timeout = 1000;
 	while(timeout-- && cs->hw.elsa.transcnt)
 		udelay(1000);
 	debugl1(cs, "msi tout=%d", timeout);
-	udelay(RCV_DELAY);
+	mdelay(RCV_DELAY);
 	modem_write_cmd(cs, MInit_2, strlen(MInit_2));
 	timeout = 1000;
 	while(timeout-- && cs->hw.elsa.transcnt)
 		udelay(1000);
 	debugl1(cs, "msi tout=%d", timeout);
-	udelay(RCV_DELAY);
+	mdelay(RCV_DELAY);
 	modem_write_cmd(cs, MInit_3, strlen(MInit_3));
 	timeout = 1000;
 	while(timeout-- && cs->hw.elsa.transcnt)
 		udelay(1000);
 	debugl1(cs, "msi tout=%d", timeout);
-	udelay(RCV_DELAY);
+	mdelay(RCV_DELAY);
 	modem_write_cmd(cs, MInit_4, strlen(MInit_4));
 	timeout = 1000;
 	while(timeout-- && cs->hw.elsa.transcnt)
 		udelay(1000);
 	debugl1(cs, "msi tout=%d", timeout);
-	udelay(RCV_DELAY );
+	mdelay(RCV_DELAY);
 	modem_write_cmd(cs, MInit_5, strlen(MInit_5));
 	timeout = 1000;
 	while(timeout-- && cs->hw.elsa.transcnt)
 		udelay(1000);
 	debugl1(cs, "msi tout=%d", timeout);
-	udelay(RCV_DELAY);
+	mdelay(RCV_DELAY);
 	modem_write_cmd(cs, MInit_6, strlen(MInit_6));
 	timeout = 1000;
 	while(timeout-- && cs->hw.elsa.transcnt)
 		udelay(1000);
 	debugl1(cs, "msi tout=%d", timeout);
-	udelay(RCV_DELAY);
+	mdelay(RCV_DELAY);
 	modem_write_cmd(cs, MInit_7, strlen(MInit_7));
 	timeout = 1000;
 	while(timeout-- && cs->hw.elsa.transcnt)
 		udelay(1000);
 	debugl1(cs, "msi tout=%d", timeout);
-	udelay(RCV_DELAY);
+	mdelay(RCV_DELAY);
 }
 
 static void
 modem_set_dial(struct IsdnCardState *cs, int outgoing) {
 	int timeout;
-#define RCV_DELAY 20000	
+#define RCV_DELAY 20
 
 	modem_write_cmd(cs, MInit_speed28800, strlen(MInit_speed28800));
 	timeout = 1000;
 	while(timeout-- && cs->hw.elsa.transcnt)
 		udelay(1000);
 	debugl1(cs, "msi tout=%d", timeout);
-	udelay(RCV_DELAY);
+	mdelay(RCV_DELAY);
 	if (outgoing)
 		modem_write_cmd(cs, MInit_dialout, strlen(MInit_dialout));
 	else
@@ -541,7 +541,7 @@ modem_set_dial(struct IsdnCardState *cs, int outgoing) {
 	while(timeout-- && cs->hw.elsa.transcnt)
 		udelay(1000);
 	debugl1(cs, "msi tout=%d", timeout);
-	udelay(RCV_DELAY);
+	mdelay(RCV_DELAY);
 }
 
 static void

-- 
Martin Michlmayr
http://www.cyrius.com/
