From: Pankaj Dubey <pankaj.dubey@samsung.com>
Subject: [PATCH v2] drivers: net: silence compiler warning.
Date: Sat, 11 Jan 2014 18:00:59 +0900
Message-ID: <1389430859-4726-1-git-send-email-pankaj.dubey@samsung.com>
Cc: davem@davemloft.net, jg1.han@samsung.com, netdev@vger.kernel.org,
	Pankaj Dubey <pankaj.dubey@samsung.com>
To: linux-samsung-soc@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:9239 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbaAKIqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jan 2014 03:46:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If used 64 bit compiler GCC warns that:

drivers/net/ethernet/smsc/smc91x.c:1897:7:
warning: cast from pointer to integer of different
size [-Wpointer-to-int-cast]

This patch fixes this by changing typecast from "unsigned int" to "unsigned long"

Signed-off-by: Pankaj Dubey <pankaj.dubey@samsung.com>
---
Changes since v2:
Fix typo in commit message

 drivers/net/ethernet/smsc/smc91x.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 0c9b5d9..42e79b4 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -1894,7 +1894,7 @@ static int smc_probe(struct net_device *dev, void __iomem *ioaddr,
 	SMC_SELECT_BANK(lp, 1);
 	val = SMC_GET_BASE(lp);
 	val = ((val & 0x1F00) >> 3) << SMC_IO_SHIFT;
-	if (((unsigned int)ioaddr & (0x3e0 << SMC_IO_SHIFT)) != val) {
+	if (((unsigned long)ioaddr & (0x3e0 << SMC_IO_SHIFT)) != val) {
 		netdev_warn(dev, "%s: IOADDR %p doesn't match configuration (%x).\n",
 			    CARDNAME, ioaddr, val);
 	}
-- 
1.7.10.4
