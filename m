From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.6.6-rc1] pcnet32 transmit performance fix
Date: Thu, 15 Apr 2004 13:55:33 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404152055.i3FKtXT04354@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When the pcnet32 adapter is installed in a system with long PCI latency
and the read burst bit is not set, performance on transmission is very
low (under 20Mbit on a 100Mbit link).  This patch against 2.6.6-rc1 will
make sure that read and write bursts are enabled.  Tested on ppc64 and
ia32.

--- linux-2.6.6-rc1/drivers/net/orig.pcnet32.c	Thu Apr 15 11:18:09 2004
+++ linux-2.6.6-rc1/drivers/net/pcnet32.c	Thu Apr 15 11:47:00 2004
@@ -1022,10 +1022,11 @@
      *	starting until the packet is loaded. Strike one for reliability, lose
      *	one for latency - although on PCI this isnt a big loss. Older chips
      *	have FIFO's smaller than a packet, so you can't do this.
+     *	Turn on BCR18:BurstRdEn and BCR18:BurstWrEn.
      */
 
     if (fset) {
-	a->write_bcr(ioaddr, 18, (a->read_bcr(ioaddr, 18) | 0x0800));
+	a->write_bcr(ioaddr, 18, (a->read_bcr(ioaddr, 18) | 0x0860));
 	a->write_csr(ioaddr, 80, (a->read_csr(ioaddr, 80) & 0x0C00) | 0x0c00);
 	dxsuflo = 1;
 	ltint = 1;

-- 
Don Fry
brazilnut@us.ibm.com
