From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK/GNU] net driver series 12
Date: Fri, 25 Oct 2002 18:50:41 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DB9CAC1.2010000@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050902010002000309090606"
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, LKML
 <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050902010002000309090606
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Marcelo,

I have pushed a tulip bug fix out to gkernel.  Please do a

        bk pull http://gkernel.bkbits.net/net-drivers-2.4

to retrieve the simple tulip patch, which is attached to this email for 
your review.  The BK repository also contains the previous 34 patches I 
sent to you yesterday, or the day before...


--------------050902010002000309090606
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.759   -> 1.760  
#	drivers/net/tulip/tulip_core.c	1.35    -> 1.36   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/10/25	jgarzik@redhat.com	1.760
# Fix tulip net driver multi-port board irq assignment
# --------------------------------------------
#
diff -Nru a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
--- a/drivers/net/tulip/tulip_core.c	Fri Oct 25 18:22:30 2002
+++ b/drivers/net/tulip/tulip_core.c	Fri Oct 25 18:22:30 2002
@@ -1482,7 +1482,6 @@
 	tp->timer.function = tulip_tbl[tp->chip_id].media_timer;
 
 	dev->base_addr = ioaddr;
-	dev->irq = irq;
 
 #ifdef CONFIG_TULIP_MWI
 	if (!force_csr0 && (tp->flags & HAS_PCI_MWI))
@@ -1655,6 +1654,7 @@
 	for (i = 0; i < 6; i++)
 		last_phys_addr[i] = dev->dev_addr[i];
 	last_irq = irq;
+	dev->irq = irq;
 
 	/* The lower four bits are the media type. */
 	if (board_idx >= 0  &&  board_idx < MAX_UNITS) {

--------------050902010002000309090606--
