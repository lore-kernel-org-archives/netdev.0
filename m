From: mathieu.poirier@linaro.org
Subject: [PATCH 8/8] drivers/net: decouple ISA and ISA_DMA_API
Date: Fri, 20 Apr 2012 14:56:16 -0600
Message-ID: <1334955376-17793-9-git-send-email-mathieu.poirier@linaro.org>
References: <1334955376-17793-1-git-send-email-mathieu.poirier@linaro.org>
Cc: arnd@arndb.de, mathieu.poirier@linaro.org
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334955376-17793-1-git-send-email-mathieu.poirier@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>

The two options are separate, and some platforms (e.g. arm pxa)
have ISA slots but no ISA dma controller, so they cannot build
drivers using the DMA API functions.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Mathieu Poirier <mathieu.poirier@linaro.org>
---
 drivers/net/tokenring/Kconfig    |    6 +++---
 drivers/net/tokenring/tms380tr.c |    6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/tokenring/Kconfig b/drivers/net/tokenring/Kconfig
index 45550d4..ef3bb13 100644
--- a/drivers/net/tokenring/Kconfig
+++ b/drivers/net/tokenring/Kconfig
@@ -98,7 +98,7 @@ config 3C359
 
 config TMS380TR
 	tristate "Generic TMS380 Token Ring ISA/PCI adapter support"
-	depends on PCI || ISA && ISA_DMA_API || MCA
+	depends on PCI || ISA || MCA
 	select FW_LOADER
 	---help---
 	  This driver provides generic support for token ring adapters
@@ -137,7 +137,7 @@ config TMSPCI
 
 config SKISA
 	tristate "SysKonnect TR4/16 ISA support"
-	depends on TMS380TR && ISA
+	depends on TMS380TR && ISA && ISA_DMA_API
 	help
 	  This tms380 module supports SysKonnect TR4/16 ISA cards.
 
@@ -149,7 +149,7 @@ config SKISA
 
 config PROTEON
 	tristate "Proteon ISA support"
-	depends on TMS380TR && ISA
+	depends on TMS380TR && ISA && ISA_DMA_API
 	help
 	  This tms380 module supports Proteon ISA cards.
 
diff --git a/drivers/net/tokenring/tms380tr.c b/drivers/net/tokenring/tms380tr.c
index be4813e..b5e0855 100644
--- a/drivers/net/tokenring/tms380tr.c
+++ b/drivers/net/tokenring/tms380tr.c
@@ -254,7 +254,7 @@ int tms380tr_open(struct net_device *dev)
 
 	/* Reset the hardware here. Don't forget to set the station address. */
 
-#ifdef CONFIG_ISA
+#if defined(CONFIG_ISA) && defined(CONFIG_ISA_DMA_API)
 	if(dev->dma > 0) 
 	{
 		unsigned long flags=claim_dma_lock();
@@ -1125,8 +1125,8 @@ int tms380tr_close(struct net_device *dev)
     
 	del_timer(&tp->timer);
 	tms380tr_disable_interrupts(dev);
-   
-#ifdef CONFIG_ISA
+
+#if defined(CONFIG_ISA) && defined(CONFIG_ISA_DMA_API)
 	if(dev->dma > 0) 
 	{
 		unsigned long flags=claim_dma_lock();
-- 
1.7.5.4
