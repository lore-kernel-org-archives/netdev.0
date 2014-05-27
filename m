From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH] arcnet: remove check for CONFIG_SA1100_CT6001
Date: Tue, 27 May 2014 21:53:44 +0200
Message-ID: <1401220424.28714.17.camel@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A check for CONFIG_SA1100_CT6001 was added in v2.6.11. But the related
Kconfig symbol was never added to the tree. Remove this check and do
some related cleaning up.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
Entirely untested.

arcnet was new for me (as are a lot of things). So I did a rather wide
search of Red Hat's (and Fedora's) bugzilla. I got no hit that suggested
anyone, ever, used arcnet. Is there any indication that people still
care about arcnet?

 include/linux/com20020.h | 29 +++++++++++------------------
 1 file changed, 11 insertions(+), 18 deletions(-)

diff --git a/include/linux/com20020.h b/include/linux/com20020.h
index 5dcfb944b6ce..c35e864b1ada 100644
--- a/include/linux/com20020.h
+++ b/include/linux/com20020.h
@@ -35,24 +35,17 @@ extern const struct net_device_ops com20020_netdev_ops;
 #define ARCNET_TOTAL_SIZE 8
 
 /* various register addresses */
-#ifdef CONFIG_SA1100_CT6001
-#define BUS_ALIGN  2  /* 8 bit device on a 16 bit bus - needs padding */
-#else
-#define BUS_ALIGN  1
-#endif
-
-
-#define _INTMASK  (ioaddr+BUS_ALIGN*0)	/* writable */
-#define _STATUS   (ioaddr+BUS_ALIGN*0)	/* readable */
-#define _COMMAND  (ioaddr+BUS_ALIGN*1)	/* standard arcnet commands */
-#define _DIAGSTAT (ioaddr+BUS_ALIGN*1)	/* diagnostic status register */
-#define _ADDR_HI  (ioaddr+BUS_ALIGN*2)	/* control registers for IO-mapped memory */
-#define _ADDR_LO  (ioaddr+BUS_ALIGN*3)
-#define _MEMDATA  (ioaddr+BUS_ALIGN*4)	/* data port for IO-mapped memory */
-#define _SUBADR   (ioaddr+BUS_ALIGN*5)	/* the extended port _XREG refers to */
-#define _CONFIG   (ioaddr+BUS_ALIGN*6)	/* configuration register */
-#define _XREG     (ioaddr+BUS_ALIGN*7)	/* extra registers (indexed by _CONFIG
-  					or _SUBADR) */
+#define _INTMASK  (ioaddr+0)	/* writable */
+#define _STATUS   (ioaddr+0)	/* readable */
+#define _COMMAND  (ioaddr+1)	/* standard arcnet commands */
+#define _DIAGSTAT (ioaddr+1)	/* diagnostic status register */
+#define _ADDR_HI  (ioaddr+2)	/* control registers for IO-mapped memory */
+#define _ADDR_LO  (ioaddr+3)
+#define _MEMDATA  (ioaddr+4)	/* data port for IO-mapped memory */
+#define _SUBADR   (ioaddr+5)	/* the extended port _XREG refers to */
+#define _CONFIG   (ioaddr+6)	/* configuration register */
+#define _XREG     (ioaddr+7)	/* extra registers (indexed by _CONFIG
+				   or _SUBADR) */
 
 /* in the ADDR_HI register */
 #define RDDATAflag	0x80	/* next access is a read (not a write) */
-- 
1.9.3
