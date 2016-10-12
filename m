From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH] net: wan: slic_ds26522: Allow driver to built if COMPILE_TEST is enabled
Date: Wed, 12 Oct 2016 16:05:59 -0300
Message-ID: <1476299159-21094-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        netdev@vger.kernel.org, Zhao Qiang <qiang.zhao@nxp.com>,
        "David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ec2-52-27-115-49.us-west-2.compute.amazonaws.com ([52.27.115.49]:49381
        "EHLO s-opensource.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754850AbcJLTHw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 15:07:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver only has runtime but no build time dependency with FSL_SOC ||
ARCH_MXC || ARCH_LAYERSCAPE.  So it can be built for testing purposes if
the COMPILE_TEST option is enabled.

This is useful to have more build coverage and make sure that the driver
is not affected by changes that could cause build regressions.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 drivers/net/wan/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
index 33ab3345d333..4e9fe75d7067 100644
--- a/drivers/net/wan/Kconfig
+++ b/drivers/net/wan/Kconfig
@@ -294,7 +294,7 @@ config FSL_UCC_HDLC
 config SLIC_DS26522
 	tristate "Slic Maxim ds26522 card support"
 	depends on SPI
-	depends on FSL_SOC || ARCH_MXC || ARCH_LAYERSCAPE
+	depends on FSL_SOC || ARCH_MXC || ARCH_LAYERSCAPE || COMPILE_TEST
 	help
 	  This module initializes and configures the slic maxim card
 	  in T1 or E1 mode.
-- 
2.7.4
