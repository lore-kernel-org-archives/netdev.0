From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 16/20] net: sun: optimization of addr compare
Date: Sat, 28 Dec 2013 14:18:08 +0800
Message-ID: <52BE6D20.4040509@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:18186 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755218Ab3L1GSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 01:18:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use possibly more efficient ether_addr_equal
to instead of memcmp.

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/ethernet/sun/sunvnet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 3df5684..1c24a8f 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -751,7 +751,7 @@ static struct vnet_mcast_entry *__vnet_mc_find(struct vnet *vp, u8 *addr)
 	struct vnet_mcast_entry *m;
 
 	for (m = vp->mcast_list; m; m = m->next) {
-		if (!memcmp(m->addr, addr, ETH_ALEN))
+		if (ether_addr_equal(m->addr, addr))
 			return m;
 	}
 	return NULL;
-- 
1.8.0
