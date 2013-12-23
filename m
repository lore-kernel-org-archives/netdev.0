From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 12/21] bridge: slight optimization of addr compare
Date: Mon, 23 Dec 2013 13:10:45 +0800
Message-ID: <52B7C5D5.2040202@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <stephen@networkplumber.org>, "David S. Miller"
	<davem@davemloft.net>, <bridge@lists.linux-foundation.org>, Netdev
	<netdev@vger.kernel.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Use the recently added and possibly more efficient
ether_addr_equal_unaligned to instead of memcmp.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David Miller <davem@davemloft.net>
Cc: bridge@lists.linux-foundation.org
Cc: netdev@vger.kernel.org
Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/bridge/br_stp_if.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 656a6f3..04217d1 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -229,7 +229,7 @@ bool br_stp_recalculate_bridge_id(struct net_bridge *br)
 
 	list_for_each_entry(p, &br->port_list, list) {
 		if (addr == br_mac_zero ||
-		    memcmp(p->dev->dev_addr, addr, ETH_ALEN) < 0)
+		    !ether_addr_equal_unaligned(p->dev->dev_addr, addr) < 0)
 			addr = p->dev->dev_addr;
 
 	}
-- 
1.8.0
