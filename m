From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH] WAN drivers fix: N2, C101, PCI200SYN - quite fatal
Date: Tue, 01 Mar 2005 02:54:25 +0100
Message-ID: <m37jksi10u.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: Jeff Garzik <jgarzik@pobox.com>
To: <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=-=-=

Hi,

The last change to drivers/wan/hd6457x.c was a bit fatal to drivers
using it - the attached patch fixes NULL pointer dereference on RX.

I've updated URLs in MAINTAINERS and wan/Kconfig as well.

Please apply to 2.6.
It would be nice if it's included in 2.6.11.

Thanks.

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>
-- 
Krzysztof Halasa

--=-=-=
Content-Type: text/x-patch
Content-Disposition: inline; filename=hdlc-skb-dev.patch

--- linux/drivers/net/wan/hd6457x.c	28 Oct 2004 06:16:08 -0000	1.15
+++ linux/drivers/net/wan/hd6457x.c	1 Mar 2005 00:58:08 -0000
@@ -315,7 +315,7 @@
 #endif
 	stats->rx_packets++;
 	stats->rx_bytes += skb->len;
-	skb->dev->last_rx = jiffies;
+	dev->last_rx = jiffies;
 	skb->protocol = hdlc_type_trans(skb, dev);
 	netif_rx(skb);
 }
--- linux/drivers/net/wan/Kconfig	15 Jan 2005 23:46:55 -0000	1.25
+++ linux/drivers/net/wan/Kconfig	1 Mar 2005 00:58:08 -0000
@@ -155,7 +155,8 @@
 	  Network) card supported by this driver and you are planning to
 	  connect the box to a WAN.
 
-	  You will need supporting software from <http://hq.pm.waw.pl/hdlc/>.
+	  You will need supporting software from
+	  <http://www.kernel.org/pub/linux/utils/net/hdlc/>.
 	  Generic HDLC driver currently supports raw HDLC, Cisco HDLC, Frame
 	  Relay, synchronous Point-to-Point Protocol (PPP) and X.25.
 
@@ -225,7 +226,7 @@
 	  Driver for PCI200SYN cards by Goramo sp. j.
 
 	  If you have such a card, say Y here and see
-	  <http://hq.pm.waw.pl/hdlc/>.
+	  <http://www.kernel.org/pub/linux/utils/net/hdlc/>.
 
 	  To compile this as a module, choose M here: the
 	  module will be called pci200syn.
@@ -239,7 +240,7 @@
 	  Driver for wanXL PCI cards by SBE Inc.
 
 	  If you have such a card, say Y here and see
-	  <http://hq.pm.waw.pl/hdlc/>.
+	  <http://www.kernel.org/pub/linux/utils/net/hdlc/>.
 
 	  To compile this as a module, choose M here: the
 	  module will be called wanxl.
@@ -292,7 +293,7 @@
 	  SDL Communications Inc.
 
 	  If you have such a card, say Y here and see
-	  <http://hq.pm.waw.pl/hdlc/>.
+	  <http://www.kernel.org/pub/linux/utils/net/hdlc/>.
 
 	  Note that N2csu and N2dds cards are not supported by this driver.
 
@@ -308,7 +309,7 @@
 	  Driver for C101 SuperSync ISA cards by Moxa Technologies Co., Ltd.
 
 	  If you have such a card, say Y here and see
-	  <http://hq.pm.waw.pl/pub/hdlc/>
+	  <http://www.kernel.org/pub/linux/utils/net/hdlc/>.
 
 	  To compile this driver as a module, choose M here: the
 	  module will be called c101.
--- linux/MAINTAINERS	26 Jan 2005 16:47:14 -0000	1.332
+++ linux/MAINTAINERS	1 Mar 2005 00:58:08 -0000
@@ -910,10 +910,10 @@
 W:	http://www.icp-vortex.com/
 S:	Supported
 
-GENERIC HDLC DRIVER, N2 AND C101 DRIVERS
+GENERIC HDLC DRIVER, N2, C101, PCI200SYN and WANXL DRIVERS
 P:	Krzysztof Halasa
 M:	khc@pm.waw.pl
-W:	http://hq.pm.waw.pl/hdlc/
+W:	http://www.kernel.org/pub/linux/utils/net/hdlc/
 S:	Maintained
 
 HAYES ESP SERIAL DRIVER

--=-=-=--
