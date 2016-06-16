From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 5/8] isdn: eicon: fix old-style declarations
Date: Thu, 16 Jun 2016 15:52:12 +0200
Message-ID: <20160616135245.3198419-5-arnd@arndb.de>
References: <20160616135020.3154461-1-arnd@arndb.de>
 <20160616135245.3198419-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Armin Schindler <mac@melware.de>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.73]:59959 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754312AbcFPNwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 09:52:35 -0400
In-Reply-To: <20160616135245.3198419-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Modern C standards expect the '__inline__' keyword to come before the return
type in a declaration, and we get many warnings for this with "make W=1"
because the eicon driver has this in a header file:

eicon/divasmain.c:448:1: error: '__inline__' is not at beginning of declaration [-Werror=old-style-declaration]
eicon/divasmain.c:453:1: error: '__inline__' is not at beginning of declaration [-Werror=old-style-declaration]
eicon/divasmain.c:458:1: error: '__inline__' is not at beginning of declaration [-Werror=old-style-declaration]
eicon/divasmain.c:463:1: error: '__inline__' is not at beginning of declaration [-Werror=old-style-declaration]
eicon/divasmain.c:468:1: error: '__inline__' is not at beginning of declaration [-Werror=old-style-declaration]
eicon/divasmain.c:473:1: error: '__inline__' is not at beginning of declaration [-Werror=old-style-declaration]
eicon/platform.h:274:1: error: '__inline__' is not at beginning of declaration [-Werror=old-style-declaration]
eicon/platform.h:280:1: error: '__inline__' is not at beginning of declaration [-Werror=old-style-declaration]

A similar warning gets printed for the diva_os_register_io_port()
declaration, because 'register' is interpreted as a keyword instead
of a variable name:

In file included from eicon/diva_didd.c:21:0:
eicon/platform.h:206:1: error: 'register' is not at beginning of declaration [-Werror=old-style-declaration]

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/isdn/hardware/eicon/divasmain.c | 12 ++++++------
 drivers/isdn/hardware/eicon/platform.h  |  6 +++---
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/divasmain.c b/drivers/isdn/hardware/eicon/divasmain.c
index a2e0ed6c9a4d..32f34511c416 100644
--- a/drivers/isdn/hardware/eicon/divasmain.c
+++ b/drivers/isdn/hardware/eicon/divasmain.c
@@ -445,32 +445,32 @@ void divasa_unmap_pci_bar(void __iomem *bar)
 /*********************************************************
  ** I/O port access
  *********************************************************/
-byte __inline__ inpp(void __iomem *addr)
+inline byte inpp(void __iomem *addr)
 {
 	return (inb((unsigned long) addr));
 }
 
-word __inline__ inppw(void __iomem *addr)
+inline word inppw(void __iomem *addr)
 {
 	return (inw((unsigned long) addr));
 }
 
-void __inline__ inppw_buffer(void __iomem *addr, void *P, int length)
+inline void inppw_buffer(void __iomem *addr, void *P, int length)
 {
 	insw((unsigned long) addr, (word *) P, length >> 1);
 }
 
-void __inline__ outppw_buffer(void __iomem *addr, void *P, int length)
+inline void outppw_buffer(void __iomem *addr, void *P, int length)
 {
 	outsw((unsigned long) addr, (word *) P, length >> 1);
 }
 
-void __inline__ outppw(void __iomem *addr, word w)
+inline void outppw(void __iomem *addr, word w)
 {
 	outw(w, (unsigned long) addr);
 }
 
-void __inline__ outpp(void __iomem *addr, word p)
+inline void outpp(void __iomem *addr, word p)
 {
 	outb(p, (unsigned long) addr);
 }
diff --git a/drivers/isdn/hardware/eicon/platform.h b/drivers/isdn/hardware/eicon/platform.h
index b2edb7590dda..62e2073c3690 100644
--- a/drivers/isdn/hardware/eicon/platform.h
+++ b/drivers/isdn/hardware/eicon/platform.h
@@ -203,7 +203,7 @@ void PCIread(byte bus, byte func, int offset, void *data, int length, void *pci_
 /*
 **  I/O Port utilities
 */
-int diva_os_register_io_port(void *adapter, int register, unsigned long port,
+int diva_os_register_io_port(void *adapter, int reg, unsigned long port,
 			     unsigned long length, const char *name, int id);
 /*
 **  I/O port access abstraction
@@ -271,13 +271,13 @@ void diva_os_get_time(dword *sec, dword *usec);
 **  atomic operation, fake because we use threads
 */
 typedef int diva_os_atomic_t;
-static diva_os_atomic_t __inline__
+static inline diva_os_atomic_t
 diva_os_atomic_increment(diva_os_atomic_t *pv)
 {
 	*pv += 1;
 	return (*pv);
 }
-static diva_os_atomic_t __inline__
+static inline diva_os_atomic_t
 diva_os_atomic_decrement(diva_os_atomic_t *pv)
 {
 	*pv -= 1;
-- 
2.9.0
