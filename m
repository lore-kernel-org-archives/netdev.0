From: Randy Dunlap <rdunlap@xenotime.net>
Subject: [PATCH -next] asm-generic/iomap.h: add stubs for pci iomap/iounmap
Date: Mon, 18 Jul 2011 09:55:57 -0700
Message-ID: <20110718095557.cd70fa01.rdunlap@xenotime.net>
References: <20110718203501.232bd176e83ff65f056366e6@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	davem@davemloft.net, Jonas Bonn <jonas@southpole.se>,
	Arnd Bergmann <arnd@arndb.de>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110718203501.232bd176e83ff65f056366e6@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

When CONFIG_PCI is not enabled, CONFIG_EISA=y, and CONFIG_GENERIC_IOMAP=y,
drivers/net/3c59x.c build fails due to a recent small change to
<asm-generic/iomap.h> that surrounds pci_iomap() and pci_iounmap()
with #ifdef CONFIG_PCI/#endif.  Since that patch to iomap.h looks
correct, add stubs for pci_iomap() and pci_iounmap() with CONFIG_PCI
is not enabled to fix the build errors.

drivers/net/3c59x.c:1026: error: implicit declaration of function 'pci_iomap'
drivers/net/3c59x.c:1038: error: implicit declaration of function 'pci_iounmap'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
Cc: Jonas Bonn <jonas@southpole.se>
Cc: Arnd Bergmann <arnd@arndb.de>
---
 include/asm-generic/iomap.h |    8 ++++++++
 1 file changed, 8 insertions(+)

--- linux-next-20110718.orig/include/asm-generic/iomap.h
+++ linux-next-20110718/include/asm-generic/iomap.h
@@ -71,6 +71,14 @@ extern void ioport_unmap(void __iomem *)
 struct pci_dev;
 extern void __iomem *pci_iomap(struct pci_dev *dev, int bar, unsigned long max);
 extern void pci_iounmap(struct pci_dev *dev, void __iomem *);
+#else
+struct pci_dev;
+static inline void __iomem *pci_iomap(struct pci_dev *dev, int bar, unsigned long max)
+{
+	return NULL;
+}
+static inline void pci_iounmap(struct pci_dev *dev, void __iomem *addr)
+{ }
 #endif
 
 #endif
