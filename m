From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v3 01/19] net: 3com: slight optimization of addr
 compare
Date: Mon, 30 Dec 2013 15:40:28 +0800
Message-ID: <52C1236C.6050604@huawei.com>
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
 drivers/net/ethernet/3com/3c509.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
index ede8daa..9142b47 100644
--- a/drivers/net/ethernet/3com/3c509.c
+++ b/drivers/net/ethernet/3com/3c509.c
@@ -252,8 +252,7 @@ static int el3_isa_id_sequence(__be16 *phys_addr)
 		for (i = 0; i < el3_cards; i++) {
 			struct el3_private *lp = netdev_priv(el3_devs[i]);
 			if (lp->type == EL3_PNP &&
-			    !memcmp(phys_addr, el3_devs[i]->dev_addr,
-				    ETH_ALEN)) {
+			    ether_addr_equal(phys_addr, el3_devs[i]->dev_addr)) {
 				if (el3_debug > 3)
 					pr_debug("3c509 with address %02x %02x %02x %02x %02x %02x was found by ISAPnP\n",
 						phys_addr[0] & 0xff, phys_addr[0] >> 8,
-- 
1.8.0
