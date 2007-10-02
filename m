From: akpm@linux-foundation.org
Subject: [patch 04/13] Avoid possible NULL pointer deref in 3c359 driver
Date: Tue, 02 Oct 2007 14:11:37 -0700
Message-ID: <200710022111.l92LBbO8022485@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jesper.juhl@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36412 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752745AbXJBVMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 17:12:17 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jesper.juhl@gmail.com>

In xl_freemem(), if dev_if is NULL, the line

  struct xl_private *xl_priv =(struct xl_private *)dev->priv;

will cause a NULL pointer dereference.

(akpm: don't try to fix it: just delete the pointless test-for-null)

Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/tokenring/3c359.c |    5 -----
 1 file changed, 5 deletions(-)

diff -puN drivers/net/tokenring/3c359.c~avoid-possible-null-pointer-deref-in-3c359-driver drivers/net/tokenring/3c359.c
--- a/drivers/net/tokenring/3c359.c~avoid-possible-null-pointer-deref-in-3c359-driver
+++ a/drivers/net/tokenring/3c359.c
@@ -1045,11 +1045,6 @@ static irqreturn_t xl_interrupt(int irq,
 	u8 __iomem * xl_mmio = xl_priv->xl_mmio ; 
 	u16 intstatus, macstatus  ;
 
-	if (!dev) { 
-		printk(KERN_WARNING "Device structure dead, aaahhhh !\n") ;
-		return IRQ_NONE; 
-	}
-
 	intstatus = readw(xl_mmio + MMIO_INTSTATUS) ;  
 
 	if (!(intstatus & 1)) /* We didn't generate the interrupt */
_
