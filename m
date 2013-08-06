From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 2/3] net: phy: mdio: add missing __iomem annotation
Date: Tue, 06 Aug 2013 17:32:58 +0900
Message-ID: <000201ce927f$8e339490$aa9abdb0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Timur Tabi' <timur@freescale.com>,
	Jingoo Han <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:34677 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609Ab3HFIc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 04:32:59 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MR30090FP0VWCE0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Tue, 06 Aug 2013 17:32:58 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added missing __iomem annotation in order to fix the following
sparse warnings:

drivers/net/phy/mdio-mux-mmioreg.c:51:27: warning: incorrect type in initializer (different address spaces)
drivers/net/phy/mdio-mux-mmioreg.c:51:27:    expected void *p
drivers/net/phy/mdio-mux-mmioreg.c:51:27:    got void [noderef] <asn:2>*
drivers/net/phy/mdio-mux-mmioreg.c:57:21: warning: incorrect type in argument 1 (different address spaces)
drivers/net/phy/mdio-mux-mmioreg.c:57:21:    expected void const volatile [noderef] <asn:2>*addr
drivers/net/phy/mdio-mux-mmioreg.c:57:21:    got void *p
drivers/net/phy/mdio-mux-mmioreg.c:60:25: warning: incorrect type in argument 2 (different address spaces)
drivers/net/phy/mdio-mux-mmioreg.c:60:25:    expected void volatile [noderef] <asn:2>*addr
drivers/net/phy/mdio-mux-mmioreg.c:60:25:    got void *p
drivers/net/phy/mdio-mux-mmioreg.c:64:25: warning: incorrect type in argument 1 (different address spaces)
drivers/net/phy/mdio-mux-mmioreg.c:64:25:    expected void volatile [noderef] <asn:2>*addr
drivers/net/phy/mdio-mux-mmioreg.c:64:25:    got void *p

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/phy/mdio-mux-mmioreg.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/mdio-mux-mmioreg.c b/drivers/net/phy/mdio-mux-mmioreg.c
index 9733bd2..f8e305d 100644
--- a/drivers/net/phy/mdio-mux-mmioreg.c
+++ b/drivers/net/phy/mdio-mux-mmioreg.c
@@ -48,7 +48,7 @@ static int mdio_mux_mmioreg_switch_fn(int current_child, int desired_child,
 	struct mdio_mux_mmioreg_state *s = data;
 
 	if (current_child ^ desired_child) {
-		void *p = ioremap(s->phys, 1);
+		void __iomem *p = ioremap(s->phys, 1);
 		uint8_t x, y;
 
 		if (!p)
-- 
1.7.10.4
