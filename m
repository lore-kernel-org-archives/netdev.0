From: Peter Robinson <pbrobinson@gmail.com>
Subject: [PATCH v2] ethernet: stmmac: make DWMAC_STM32 depend on it's associated SoC
Date: Sun, 20 Nov 2016 17:22:38 +0000
Message-ID: <20161120172238.7919-1-pbrobinson@gmail.com>
Cc: Peter Robinson <pbrobinson@gmail.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Maxime Coquelin <mcoquelin.stm32@gmail.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34942 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752209AbcKTRjl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2016 12:39:41 -0500
Received: by mail-wm0-f68.google.com with SMTP id a20so20645030wme.2
        for <netdev@vger.kernel.org>; Sun, 20 Nov 2016 09:39:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's not much point, except compile test, enabling the stmmac
platform drivers unless the STM32 SoC is enabled. It's not
useful without it.

Signed-off-by: Peter Robinson <pbrobinson@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index 3818c5e..4b78168 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -107,7 +107,7 @@ config DWMAC_STI
 config DWMAC_STM32
 	tristate "STM32 DWMAC support"
 	default ARCH_STM32
-	depends on OF && HAS_IOMEM
+	depends on OF && HAS_IOMEM && (ARCH_STM32 || COMPILE_TEST)
 	select MFD_SYSCON
 	---help---
 	  Support for ethernet controller on STM32 SOCs.
-- 
2.9.3
