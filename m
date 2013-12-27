From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 17/20] net: ti: slight optimization of addr compare
Date: Fri, 27 Dec 2013 14:49:10 +0800
Message-ID: <52BD22E6.3090101@huawei.com>
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
 drivers/net/ethernet/ti/cpsw_ale.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw_ale.c b/drivers/net/ethernet/ti/cpsw_ale.c
index 7fa60d6..63e9819 100644
--- a/drivers/net/ethernet/ti/cpsw_ale.c
+++ b/drivers/net/ethernet/ti/cpsw_ale.c
@@ -163,7 +163,7 @@ int cpsw_ale_match_addr(struct cpsw_ale *ale, u8 *addr, u16 vid)
 		if (cpsw_ale_get_vlan_id(ale_entry) != vid)
 			continue;
 		cpsw_ale_get_addr(ale_entry, entry_addr);
-		if (memcmp(entry_addr, addr, 6) == 0)
+		if (ether_addr_equal(entry_addr, addr))
 			return idx;
 	}
 	return -ENOENT;
-- 
1.8.0
