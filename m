From: akpm@osdl.org
Subject: [patch 03/10] Add OMAP support to smc91x Ethernet driver
Date: Mon, 24 Jan 2005 18:57:10 -0800
Message-ID: <200501250257.j0P2vcl20252@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, tony@atomide.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Tony Lindgren <tony@atomide.com>

Following patch adds support for various OMAP boards to smc91x.

Signed-off-by: Tony Lindgren <tony@atomide.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/smc91x.h |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+)

diff -puN drivers/net/smc91x.h~add-omap-support-to-smc91x-ethernet-driver drivers/net/smc91x.h
--- 25/drivers/net/smc91x.h~add-omap-support-to-smc91x-ethernet-driver	2005-01-24 18:55:47.064142000 -0800
+++ 25-akpm/drivers/net/smc91x.h	2005-01-24 18:55:47.068141392 -0800
@@ -162,6 +162,26 @@ SMC_outw(u16 val, unsigned long ioaddr, 
 	}
 }
 
+#elif	defined(CONFIG_ARCH_OMAP)
+
+/* We can only do 16-bit reads and writes in the static memory space. */
+#define SMC_CAN_USE_8BIT	0
+#define SMC_CAN_USE_16BIT	1
+#define SMC_CAN_USE_32BIT	0
+#define SMC_IO_SHIFT		0
+#define SMC_NOWAIT		1
+
+#define SMC_inb(a, r)		readb((a) + (r))
+#define SMC_outb(v, a, r)	writeb(v, (a) + (r))
+#define SMC_inw(a, r)		readw((a) + (r))
+#define SMC_outw(v, a, r)	writew(v, (a) + (r))
+#define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
+#define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
+#define SMC_inl(a, r)		readl((a) + (r))
+#define SMC_outl(v, a, r)	writel(v, (a) + (r))
+#define SMC_insl(a, r, p, l)	readsl((a) + (r), p, l)
+#define SMC_outsl(a, r, p, l)	writesl((a) + (r), p, l)
+
 #elif	defined(CONFIG_ISA)
 
 #define SMC_CAN_USE_8BIT	1
_
