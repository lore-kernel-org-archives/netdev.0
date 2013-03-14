From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] ethernet/tulip: DE4x5 needs VIRT_TO_BUS
Date: Thu, 14 Mar 2013 22:56:42 +0100
Message-ID: <1363298204-8014-5-git-send-email-arnd@arndb.de>
References: <1363298204-8014-1-git-send-email-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>,
	Grant Grundler <grundler@parisc-linux.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363298204-8014-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The automated ARM build tests have shown that the tulip de4x5 driver
uses the old-style virt_to_bus() interface on some architectures.

Alpha, Sparc and PowerPC did not hit this problem, because they
use a different code path, and most other architectures actually
do provide VIRT_TO_BUS.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Grant Grundler <grundler@parisc-linux.org>
Cc: netdev@vger.kernel.org
---
Please apply for 3.9 or 3.10, this one is not urgent

 drivers/net/ethernet/dec/tulip/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/dec/tulip/Kconfig b/drivers/net/ethernet/dec/tulip/Kconfig
index 0c37fb2..1df33c7 100644
--- a/drivers/net/ethernet/dec/tulip/Kconfig
+++ b/drivers/net/ethernet/dec/tulip/Kconfig
@@ -108,6 +108,7 @@ config TULIP_DM910X
 config DE4X5
 	tristate "Generic DECchip & DIGITAL EtherWORKS PCI/EISA"
 	depends on (PCI || EISA)
+	depends on VIRT_TO_BUS || ALPHA || PPC || SPARC
 	select CRC32
 	---help---
 	  This is support for the DIGITAL series of PCI/EISA Ethernet cards.
-- 
1.8.1.2
