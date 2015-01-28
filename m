From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 3/4] net: lance,ni64: don't build for ARM
Date: Wed, 28 Jan 2015 15:15:03 +0100
Message-ID: <1422454504-439085-4-git-send-email-arnd@arndb.de>
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

The ni65 and lance ethernet drivers manually program the ISA DMA
controller that is only available on x86 PCs and a few compatible
systems. Trying to build it on ARM results in this error:

ni65.c: In function 'ni65_probe1':
ni65.c:496:62: error: 'DMA1_STAT_REG' undeclared (first use in this function)
     ((inb(DMA1_STAT_REG) >> 4) & 0x0f)
                                                              ^
ni65.c:496:62: note: each undeclared identifier is reported only once for each function it appears in
ni65.c:497:63: error: 'DMA2_STAT_REG' undeclared (first use in this function)
     | (inb(DMA2_STAT_REG) & 0xf0);

The DMA1_STAT_REG and DMA2_STAT_REG registers are only defined for
alpha, mips, parisc, powerpc and x86, although it is not clear
which subarchitectures actually have them at the correct location.

This patch for now just disables it for ARM, to avoid randconfig
build errors. We could also decide to limit it to the set of
architectures on which it does compile, but that might look more
deliberate than guessing based on where the drivers build.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/amd/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/Kconfig b/drivers/net/ethernet/amd/Kconfig
index 5d3b5202327c..c638c85f3954 100644
--- a/drivers/net/ethernet/amd/Kconfig
+++ b/drivers/net/ethernet/amd/Kconfig
@@ -45,7 +45,7 @@ config AMD8111_ETH
 
 config LANCE
 	tristate "AMD LANCE and PCnet (AT1500 and NE2100) support"
-	depends on ISA && ISA_DMA_API
+	depends on ISA && ISA_DMA_API && !ARM
 	---help---
 	  If you have a network (Ethernet) card of this type, say Y and read
 	  the Ethernet-HOWTO, available from
@@ -142,7 +142,7 @@ config PCMCIA_NMCLAN
 
 config NI65
 	tristate "NI6510 support"
-	depends on ISA && ISA_DMA_API
+	depends on ISA && ISA_DMA_API && !ARM
 	---help---
 	  If you have a network (Ethernet) card of this type, say Y and read
 	  the Ethernet-HOWTO, available from
-- 
2.1.0.rc2
