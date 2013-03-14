From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] isdn: hisax: netjet requires VIRT_TO_BUS
Date: Thu, 14 Mar 2013 22:56:41 +0100
Message-ID: <1363298204-8014-4-git-send-email-arnd@arndb.de>
References: <1363298204-8014-1-git-send-email-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363298204-8014-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Disabling CONFIG_VIRT_TO_BUS on ARM showed that the hisax netjet
driver depends on this deprecated functionality but is not
marked so in Kconfig.

Rather than adding ARM to the already long list of architectures
that this driver is broken on, this patch adds 'depends on
VIRT_TO_BUS' and removes the dependency on !SPARC, which is
also implied by that.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: netdev@vger.kernel.org
---
Please apply for 3.9 or 3.10, this one is not urgent

 drivers/isdn/hisax/Kconfig | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hisax/Kconfig b/drivers/isdn/hisax/Kconfig
index 5313c9e..d9edcc9 100644
--- a/drivers/isdn/hisax/Kconfig
+++ b/drivers/isdn/hisax/Kconfig
@@ -237,7 +237,8 @@ config HISAX_MIC
 
 config HISAX_NETJET
 	bool "NETjet card"
-	depends on PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN)))
+	depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN)))
+	depends on VIRT_TO_BUS
 	help
 	  This enables HiSax support for the NetJet from Traverse
 	  Technologies.
@@ -248,7 +249,8 @@ config HISAX_NETJET
 
 config HISAX_NETJET_U
 	bool "NETspider U card"
-	depends on PCI && (BROKEN || !(SPARC || PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN)))
+	depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN)))
+	depends on VIRT_TO_BUS
 	help
 	  This enables HiSax support for the Netspider U interface ISDN card
 	  from Traverse Technologies.
-- 
1.8.1.2
