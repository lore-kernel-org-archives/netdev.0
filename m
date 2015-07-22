From: Antonio Borneo <borneo.antonio@gmail.com>
Subject: [PATCH] net: via/Kconfig: GENERIC_PCI_IOMAP required if PCI not selected
Date: Thu, 23 Jul 2015 00:34:14 +0800
Message-ID: <1437582854-3320-1-git-send-email-borneo.antonio@gmail.com>
Cc: Alexey Charkov <alchark@gmail.com>,
	Antonio Borneo <borneo.antonio@gmail.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>,
	netdev@vger.kernel.org, linux-next@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:37887 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934498AbbGVQfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 12:35:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The builds of arch/sh are failing in linux-next with:

drivers/net/ethernet/via/via-rhine.c:1098:2: error: implicit declaration
of function 'pci_iomap' [-Werror=implicit-function-declaration]
drivers/net/ethernet/via/via-rhine.c:1119:2: error: implicit declaration
of function 'pci_iounmap' [-Werror=implicit-function-declaration]
cc1: some warnings being treated as errors
make[5]: *** [drivers/net/ethernet/via/via-rhine.o] Error 1

The logic in include/asm-generic/{io,iomap,pci_iomap}.h
requires GENERIC_PCI_IOMAP to inline empty pci_iomap/pci_iounmap
when PCI is not selected.

Add GENERIC_PCI_IOMAP in the dependency list for VIA_RHINE and
VIA_VELOCITY.

Reported-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Antonio Borneo <borneo.antonio@gmail.com>
---
 drivers/net/ethernet/via/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/via/Kconfig b/drivers/net/ethernet/via/Kconfig
index 9bf3ff1..96c527c 100644
--- a/drivers/net/ethernet/via/Kconfig
+++ b/drivers/net/ethernet/via/Kconfig
@@ -19,7 +19,7 @@ if NET_VENDOR_VIA
 
 config VIA_RHINE
 	tristate "VIA Rhine support"
-	depends on (PCI || OF_IRQ)
+	depends on (PCI || (OF_IRQ && GENERIC_PCI_IOMAP))
 	depends on HAS_DMA
 	select CRC32
 	select MII
@@ -44,7 +44,7 @@ config VIA_RHINE_MMIO
 
 config VIA_VELOCITY
 	tristate "VIA Velocity support"
-	depends on (PCI || (OF_ADDRESS && OF_IRQ))
+	depends on (PCI || (OF_ADDRESS && OF_IRQ && GENERIC_PCI_IOMAP))
 	depends on HAS_DMA
 	select CRC32
 	select CRC_CCITT
-- 
2.4.6
