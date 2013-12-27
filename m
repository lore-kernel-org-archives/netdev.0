From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 14/20] net: renesas: slight optimization of addr
 compare
Date: Fri, 27 Dec 2013 14:48:58 +0800
Message-ID: <52BD22DA.5020606@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
