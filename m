From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net/appletalk: LTPC needs virt_to_bus
Date: Wed, 18 Feb 2015 20:48:54 +0100
Message-ID: <6100590.gsNqMCFyRS@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ltpc driver is rather outdated and does not get built on most
platforms because it requires the ISA_DMA_API symbol. However
there are some ARM platforms that have ISA_DMA_API but no virt_to_bus,
and they get this build error when enabling the ltpc driver.

drivers/net/appletalk/ltpc.c: In function 'handlefc':
drivers/net/appletalk/ltpc.c:380:2: error: implicit declaration of function 'virt_to_bus' [-Werror=implicit-function-declaration]
  set_dma_addr(dma,virt_to_bus(ltdmacbuf));
  ^

This adds another dependency in Kconfig to avoid that configuration.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/drivers/net/appletalk/Kconfig b/drivers/net/appletalk/Kconfig
index 4ce6ca5f3d36..dc6b78e5342f 100644
--- a/drivers/net/appletalk/Kconfig
+++ b/drivers/net/appletalk/Kconfig
@@ -40,7 +40,7 @@ config DEV_APPLETALK
 
 config LTPC
 	tristate "Apple/Farallon LocalTalk PC support"
-	depends on DEV_APPLETALK && (ISA || EISA) && ISA_DMA_API
+	depends on DEV_APPLETALK && (ISA || EISA) && ISA_DMA_API && VIRT_TO_BUS
 	help
 	  This allows you to use the AppleTalk PC card to connect to LocalTalk
 	  networks. The card is also known as the Farallon PhoneNet PC card.
