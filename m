From: Ralf Baechle <ralf@linux-mips.org>
Subject: [IOC3] IP27: Really set PCI64_ATTR_VIRTUAL, not PCI64_ATTR_PREC.
Date: Sat, 17 Jun 2006 18:57:39 +0100
Message-ID: <20060617175738.GA4346@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:65468 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S1750754AbWFQR5r
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Jun 2006 13:57:47 -0400
Received: from localhost.localdomain ([127.0.0.1]:20451 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S8134150AbWFQR5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2006 18:57:44 +0100
To: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IOC3's homegrown DMA mapping functions that are used to optimize things
a little on IP27 set the wrong bit.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index ae71ed5..e76e6e7 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -145,7 +145,7 @@ static inline struct sk_buff * ioc3_allo
 static inline unsigned long ioc3_map(void *ptr, unsigned long vdev)
 {
 #ifdef CONFIG_SGI_IP27
-	vdev <<= 58;   /* Shift to PCI64_ATTR_VIRTUAL */
+	vdev <<= 57;   /* Shift to PCI64_ATTR_VIRTUAL */
 
 	return vdev | (0xaUL << PCI64_ATTR_TARG_SHFT) | PCI64_ATTR_PREF |
 	       ((unsigned long)ptr & TO_PHYS_MASK);
