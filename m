From: Nicolai Stange <nicstange@gmail.com>
Subject: [PATCH] isdn: disable HiSax NetJet driver on microblaze arch
Date: Wed, 17 Jun 2015 03:05:02 +0200
Message-ID: <87pp4vw3ep.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
CC: Karsten Keil <isdn@linux-pingi.de>
CC: Jean Delvare <jdelvare@suse.de>
CC: "David S. Miller" <davem@davemloft.net>
CC: Nicolai Stange <nicstange@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix an allmodconfig compilation failer on microblaze due to big endian
architectures being apparently unsupported by the NetJet code:
  drivers/isdn/hisax/nj_s.c: In function 'setup_netjet_s':
  drivers/isdn/hisax/nj_s.c:265:2:
      error: #error "not running on big endian machines now"

Modify the relevant Kconfig such that the NetJet code is not built on
microblaze anymore.

Note that endianess on microblaze is not determined through Kconfig,
but by means of a compiler provided CPP macro, namely __MICROBLAZEEL__.
However, gcc defaults to big endianess on that platform.

Signed-off-by: Nicolai Stange <nicstange@gmail.com>
---
 The maintainer tree listed under "ISDN SUBSYSTEM" in MAINTAINERS does
 not exist anymore. I created the diff against the Linus tree.

 drivers/isdn/hisax/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hisax/Kconfig b/drivers/isdn/hisax/Kconfig
index 97465ac..eb83d94 100644
--- a/drivers/isdn/hisax/Kconfig
+++ b/drivers/isdn/hisax/Kconfig
@@ -237,7 +237,7 @@ config HISAX_MIC
 
 config HISAX_NETJET
 	bool "NETjet card"
-	depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN)))
+	depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN) || MICROBLAZE))
 	depends on VIRT_TO_BUS
 	help
 	  This enables HiSax support for the NetJet from Traverse
@@ -249,7 +249,7 @@ config HISAX_NETJET
 
 config HISAX_NETJET_U
 	bool "NETspider U card"
-	depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN)))
+	depends on PCI && (BROKEN || !(PPC || PARISC || M68K || (MIPS && !CPU_LITTLE_ENDIAN) || FRV || (XTENSA && !CPU_LITTLE_ENDIAN) || MICROBLAZE))
 	depends on VIRT_TO_BUS
 	help
 	  This enables HiSax support for the Netspider U interface ISDN card
-- 
2.4.3
