From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 2/4] net: wan: add missing virt_to_bus dependencies
Date: Wed, 28 Jan 2015 15:15:02 +0100
Message-ID: <1422454504-439085-3-git-send-email-arnd@arndb.de>
References: <1422454504-439085-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, linux-pcmcia@lists.infradead.org,
 jeffrey.t.kirsher@intel.com, kas@fi.muni.cz, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org>
In-Reply-To: <1422454504-439085-1-git-send-email-arnd@arndb.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-pcmcia>,
 <mailto:linux-pcmcia-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-pcmcia/>
List-Post: <mailto:linux-pcmcia@lists.infradead.org>
List-Help: <mailto:linux-pcmcia-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-pcmcia>,
 <mailto:linux-pcmcia-request@lists.infradead.org?subject=subscribe>
Sender: "linux-pcmcia" <linux-pcmcia-bounces@lists.infradead.org>
Errors-To: linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

The cosa driver is rather outdated and does not get built on most
platforms because it requires the ISA_DMA_API symbol. However
there are some ARM platforms that have ISA_DMA_API but no virt_to_bus,
and they get this build error when enabling the ltpc driver.

drivers/net/wan/cosa.c: In function 'tx_interrupt':
drivers/net/wan/cosa.c:1768:3: error: implicit declaration of function 'virt_to_bus'
   unsigned long addr = virt_to_bus(cosa->txbuf);
   ^

The same problem exists for the Hostess SV-11 and Sealevel Systems 4021
drivers.

This adds another dependency in Kconfig to avoid that configuration.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/wan/Kconfig | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
index 94e234975c61..a2fdd15f285a 100644
--- a/drivers/net/wan/Kconfig
+++ b/drivers/net/wan/Kconfig
@@ -25,7 +25,7 @@ if WAN
 # There is no way to detect a comtrol sv11 - force it modular for now.
 config HOSTESS_SV11
 	tristate "Comtrol Hostess SV-11 support"
-	depends on ISA && m && ISA_DMA_API && INET && HDLC
+	depends on ISA && m && ISA_DMA_API && INET && HDLC && VIRT_TO_BUS
 	help
 	  Driver for Comtrol Hostess SV-11 network card which
 	  operates on low speed synchronous serial links at up to
@@ -37,7 +37,7 @@ config HOSTESS_SV11
 # The COSA/SRP driver has not been tested as non-modular yet.
 config COSA
 	tristate "COSA/SRP sync serial boards support"
-	depends on ISA && m && ISA_DMA_API && HDLC
+	depends on ISA && m && ISA_DMA_API && HDLC && VIRT_TO_BUS
 	---help---
 	  Driver for COSA and SRP synchronous serial boards.
 
@@ -87,7 +87,7 @@ config LANMEDIA
 # There is no way to detect a Sealevel board. Force it modular
 config SEALEVEL_4021
 	tristate "Sealevel Systems 4021 support"
-	depends on ISA && m && ISA_DMA_API && INET && HDLC
+	depends on ISA && m && ISA_DMA_API && INET && HDLC && VIRT_TO_BUS
 	help
 	  This is a driver for the Sealevel Systems ACB 56 serial I/O adapter.
 
-- 
2.1.0.rc2
