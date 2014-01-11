From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 2/2] net: 3com: fix warning for incorrect type in
 argument
Date: Sat, 11 Jan 2014 16:23:37 +0800
Message-ID: <52D0FF89.2020206@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Joe Perches <joe@perches.com>,
	Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:26227 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbaAKIXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jan 2014 03:23:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit c466a9b2b329f7d9982c14eedc83a923d3bc711c
(net: 3com: slight optimization of addr compare)
cause a warning: "passing argument 1 of 'ether_addr_equal'
from incompatible pointer type", so fix it.

I think julia will convert ether_addr_equal to ether_addr_equal_64bits later.

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/ethernet/3com/3c509.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
index 9142b47..c53384d 100644
--- a/drivers/net/ethernet/3com/3c509.c
+++ b/drivers/net/ethernet/3com/3c509.c
@@ -252,7 +252,7 @@ static int el3_isa_id_sequence(__be16 *phys_addr)
 		for (i = 0; i < el3_cards; i++) {
 			struct el3_private *lp = netdev_priv(el3_devs[i]);
 			if (lp->type == EL3_PNP &&
-			    ether_addr_equal(phys_addr, el3_devs[i]->dev_addr)) {
+			    ether_addr_equal((u8 *)phys_addr, el3_devs[i]->dev_addr)) {
 				if (el3_debug > 3)
 					pr_debug("3c509 with address %02x %02x %02x %02x %02x %02x was found by ISAPnP\n",
 						phys_addr[0] & 0xff, phys_addr[0] >> 8,
-- 
1.8.0
