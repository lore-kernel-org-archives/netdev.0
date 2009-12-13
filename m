From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 2.6.32-git7] 3c574_cs: disable irq before calling
 el3_interrupt
Date: Sun, 13 Dec 2009 09:44:11 +0900
Message-ID: <20091213094411.18be2ff6.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	<20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	<20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from defg500.nifty.com ([202.248.238.127]:25212 "HELO
	defg500.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932206AbZLMBPm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Dec 2009 20:15:42 -0500
Received: from userg508.nifty.com (userg508p.nifty.com [172.22.128.88])by defg500.nifty.com with ESMTP id nBD0j5sP016168
	for <netdev@vger.kernel.org>; Sun, 13 Dec 2009 09:45:05 +0900
Received: from localhost.localdomain (eaoska169002.adsl.ppp.infoweb.ne.jp [219.116.18.2])by userg508.nifty.com with SMTP id nBD0iC2Y009800
	for <netdev@vger.kernel.org>; Sun, 13 Dec 2009 09:44:12 +0900
In-Reply-To: <20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


3c574_cs, 3c589_cs:
	disable irq before calling el3_interrupt
	in the media_check function.

Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-2.6.32-git7/drivers/net/pcmcia/3c574_cs.c.orig	2009-12-12 06:58:14.000000000 +0900
+++ linux-2.6.32-git7/drivers/net/pcmcia/3c574_cs.c	2009-12-13 08:50:18.000000000 +0900
@@ -912,7 +912,11 @@ static void media_check(unsigned long ar
 	if ((inw(ioaddr + EL3_STATUS) & IntLatch) && (inb(ioaddr + Timer) == 0xff)) {
 		if (!lp->fast_poll)
 			printk(KERN_INFO "%s: interrupt(s) dropped!\n", dev->name);
+
+		local_irq_save(flags);
 		el3_interrupt(dev->irq, dev);
+		local_irq_restore(flags);
+
 		lp->fast_poll = HZ;
 	}
 	if (lp->fast_poll) {
--- linux-2.6.32-git7/drivers/net/pcmcia/3c589_cs.c.orig	2009-12-12 06:58:28.000000000 +0900
+++ linux-2.6.32-git7/drivers/net/pcmcia/3c589_cs.c	2009-12-13 08:50:38.000000000 +0900
@@ -711,7 +711,11 @@ static void media_check(unsigned long ar
 	(inb(ioaddr + EL3_TIMER) == 0xff)) {
 	if (!lp->fast_poll)
 	    printk(KERN_WARNING "%s: interrupt(s) dropped!\n", dev->name);
+
+	local_irq_save(flags);
 	el3_interrupt(dev->irq, dev);
+	local_irq_restore(flags);
+
 	lp->fast_poll = HZ;
     }
     if (lp->fast_poll) {
