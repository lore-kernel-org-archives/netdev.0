From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2/5] 2.4.27-pre3 pcnet32 avoid hard hang with some chip variants.
Date: Fri, 21 May 2004 13:57:20 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405212057.i4LKvK210266@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch fixes a hard hang with 79C975 and 79C976 chip variants when
dumping BCR register #34.

--- linux-2.4.27-pre3/drivers/net/static.pcnet32.c	Fri May 21 12:36:44 2004
+++ linux-2.4.27-pre3/drivers/net/pcnet32.c	Fri May 21 12:36:56 2004
@@ -895,7 +895,7 @@
     *buff++ = a->read_csr(ioaddr, 114);
 
     for (i = 0; i <= 35; i++) {
-	*buff++ = a->read_bcr(ioaddr, i);
+	*buff++ = (i == 34) ? 0xdead : a->read_bcr(ioaddr, i);
     }
 
     if (!(csr0 & 0x0004)) {	/* If not stopped */

-- 
Don Fry
brazilnut@us.ibm.com
