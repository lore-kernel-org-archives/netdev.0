From: akpm@linux-foundation.org
Subject: [patch 1/4] hisax: timeout off by one in waitrecmsg()
Date: Tue, 02 Feb 2010 14:43:44 -0800
Message-ID: <201002022243.o12MhiOo019211@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	roel.kluin@gmail.com
To: isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:42508 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757072Ab0BBWoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 17:44:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>

With `while (timeout++ < maxdelay)' timeout reaches maxdelay + 1 after the
loop This is probably unlikely a problem in practice.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
Cc: Karsten Keil <isdn@linux-pingi.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/hisax/isar.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/isdn/hisax/isar.c~hisax-timeout-off-by-one-in-waitrecmsg drivers/isdn/hisax/isar.c
--- a/drivers/isdn/hisax/isar.c~hisax-timeout-off-by-one-in-waitrecmsg
+++ a/drivers/isdn/hisax/isar.c
@@ -138,7 +138,7 @@ waitrecmsg(struct IsdnCardState *cs, u_c
 	while((!(cs->BC_Read_Reg(cs, 0, ISAR_IRQBIT) & ISAR_IRQSTA)) &&
 		(timeout++ < maxdelay))
 		udelay(1);
-	if (timeout >= maxdelay) {
+	if (timeout > maxdelay) {
 		printk(KERN_WARNING"isar recmsg IRQSTA timeout\n");
 		return(0);
 	}
_
