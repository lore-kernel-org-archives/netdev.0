From: <y@shlinux1.ap.freescale.net>
Subject: [Patch net-next 08/11] net:fec: change FEC alignment to 64 bytes for ARM platform
Date: Thu, 4 Sep 2014 04:34:43 +0800
Message-ID: <47133.3366389901$1409778685@news.gmane.org>
References: <1409776486-1403-1-git-send-email-y>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	<devicetree@vger.kernel.org>, Fugang Duan <B38611@freescale.com>,
	Frank Li <Frank.Li@freescale.com>
To: <b38611@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0053.outbound.protection.outlook.com ([157.56.110.53]:3709
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756391AbaICVLB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 17:11:01 -0400
In-Reply-To: <1409776486-1403-1-git-send-email-y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <B38611@freescale.com>

Since enet-avb has 64 bytes alignment limitation for rx DMA transfer.
The previous enet IP for ARM platform has 16 bytes alignment for tx
DMA transfer. 64 is the an integral number of 16, so change alignment
to 64 bytes for all ARM platform, which don't impact the performance
of previous platform.

Signed-off-by: Fugang Duan <B38611@freescale.com>
Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index a232245..b388e29f 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -65,7 +65,7 @@
 static void set_multicast_list(struct net_device *ndev);
 
 #if defined(CONFIG_ARM)
-#define FEC_ALIGNMENT	0xf
+#define FEC_ALIGNMENT	0x3f
 #else
 #define FEC_ALIGNMENT	0x3
 #endif
-- 
1.9.1
