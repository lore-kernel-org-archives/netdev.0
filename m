From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 02/21] net: freescale: slight optimization of addr compare
Date: Mon, 23 Dec 2013 13:09:44 +0800
Message-ID: <52B7C598.9010904@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Li Yang <leoli@freescale.com>, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	<linuxppc-dev@lists.ozlabs.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the recently added and possibly more efficient
ether_addr_equal_unaligned to instead of memcmp.

Cc: Li Yang <leoli@freescale.com>
Cc: netdev@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/ethernet/freescale/ucc_geth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 5548b6d..88a1525 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -437,7 +437,7 @@ static void hw_add_addr_in_hash(struct ucc_geth_private *ugeth,
 
 static inline int compare_addr(u8 **addr1, u8 **addr2)
 {
-	return memcmp(addr1, addr2, ETH_ALEN);
+	return !ether_addr_equal_unaligned(addr1, addr2);
 }
 
 #ifdef DEBUG
-- 
1.8.0
