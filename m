From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v3 14/19] net: renesas: slight optimization of addr
 compare
Date: Mon, 30 Dec 2013 15:41:17 +0800
Message-ID: <52C1239D.1040409@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:30104 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754511Ab3L3HlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 02:41:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use possibly more efficient ether_addr_equal
to instead of memcmp.

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/ethernet/renesas/sh_eth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index ca742e1..2d00bce 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2207,7 +2207,7 @@ static int sh_eth_tsu_find_entry(struct net_device *ndev, const u8 *addr)
 
 	for (i = 0; i < SH_ETH_TSU_CAM_ENTRIES; i++, reg_offset += 8) {
 		sh_eth_tsu_read_entry(reg_offset, c_addr);
-		if (memcmp(addr, c_addr, ETH_ALEN) == 0)
+		if (ether_addr_equal(addr, c_addr))
 			return i;
 	}
 
-- 
1.8.0
