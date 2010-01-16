From: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Subject: [PATH 2.6.33 2/3] net: Kconfig change for Micrel KSZ884X driver
Date: Fri, 15 Jan 2010 19:04:39 -0800
Message-ID: <14385191E87B904DBD836449AA30269D021A4B@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758602Ab0APDEo@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tristram Ha <Tristram.Ha@micrel.com>

Add Micrel KSZ8841/KSZ8842 PCI Ethernet chip support.

Some users like to use KSZ8842 switch to run Spanning Tree Protocol.  As a result a hardware STP support was implemented so that the host does not waste CPU time forwarding each and every packet.

Signed-off-by: Tristram Ha <Tristram.Ha@micrel.com>
---
diff -uprN linux-2.6.33-rc3.old/drivers/net/Kconfig linux-2.6.33-rc3.new/drivers/net/Kconfig
--- linux-2.6.33-rc3.old/drivers/net/Kconfig	2010-01-05 16:02:46.000000000 -0800
+++ linux-2.6.33-rc3.new/drivers/net/Kconfig	2010-01-13 12:17:42.000000000 -0800
@@ -1368,6 +1368,27 @@ config AC3200
 	  To compile this driver as a module, choose M here. The module
 	  will be called ac3200.
 
+config KSZ884X_PCI
+	tristate "Micrel KSZ8841/2 PCI"
+	depends on NET_PCI && PCI
+	select MII
+	select CRC32
+	help
+	  This PCI driver is for Micrel KSZ8841/KSZ8842 PCI Ethernet chip.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called ksz884x.
+
+config KSZ8842_STP
+	bool "STP support"
+	depends on KSZ884X_PCI && EXPERIMENTAL
+	help
+	  This enables a feature to aid KSZ8842 running Spanning Tree Protocol.
+	  To actually use it pass the stp=1 parameter to the driver.
+
+	  This feature is experimental and may not work correctly compared to
+	  the Linux bridge using STP.
+
 config APRICOT
 	tristate "Apricot Xen-II on board Ethernet"
 	depends on NET_PCI && ISA
