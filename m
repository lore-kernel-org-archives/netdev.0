From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 1/4] net: cs89x0: always build platform code if !HAS_IOPORT_MAP
Date: Wed, 28 Jan 2015 15:15:01 +0100
Message-ID: <1422454504-439085-2-git-send-email-arnd@arndb.de>
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

The cs89x0 driver can either be built as an ISA driver or a platform
driver, the choice is controlled by the CS89x0_PLATFORM Kconfig
symbol. Building the ISA driver on a system that does not have
a way to map I/O ports fails with this error:

drivers/built-in.o: In function `cs89x0_ioport_probe.constprop.1':
:(.init.text+0x4794): undefined reference to `ioport_map'
:(.init.text+0x4830): undefined reference to `ioport_unmap'

This changes the Kconfig logic to take that option away and
always force building the platform variant of this driver if
CONFIG_HAS_IOPORT_MAP is not set. This is the only correct
choice in this case, and it avoids the build error.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/cirrus/Kconfig | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cirrus/Kconfig b/drivers/net/ethernet/cirrus/Kconfig
index 7403dff8f14a..905ac5f5d9a6 100644
--- a/drivers/net/ethernet/cirrus/Kconfig
+++ b/drivers/net/ethernet/cirrus/Kconfig
@@ -32,7 +32,8 @@ config CS89x0
 	  will be called cs89x0.
 
 config CS89x0_PLATFORM
-	bool "CS89x0 platform driver support"
+	bool "CS89x0 platform driver support" if HAS_IOPORT_MAP
+	default !HAS_IOPORT_MAP
 	depends on CS89x0
 	help
 	  Say Y to compile the cs89x0 driver as a platform driver. This
-- 
2.1.0.rc2
