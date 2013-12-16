From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 5/6] pppoe: slight optimization of addr compare
Date: Mon, 16 Dec 2013 16:24:45 +0800
Message-ID: <52AEB8CD.8010407@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Michal Ostrowski <mostrows@earthlink.net>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>, Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:23314 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843Ab3LPIY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 03:24:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches add ether_addr_equal_unaligned to test if
possibly unaligned to u16 Ethernet addresses are equal.

If CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is set, this uses
the slightly faster generic routine ether_addr_equal,
otherwise this uses memcmp.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/ppp/pppoe.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index 82ee6ed..baed1ef 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -131,12 +131,13 @@ static inline struct pppoe_net *pppoe_pernet(struct net *net)
 
 static inline int cmp_2_addr(struct pppoe_addr *a, struct pppoe_addr *b)
 {
-	return a->sid == b->sid && !memcmp(a->remote, b->remote, ETH_ALEN);
+	return a->sid == b->sid &&
+		ether_addr_equal_unaligned(a->remote, b->remote);
 }
 
 static inline int cmp_addr(struct pppoe_addr *a, __be16 sid, char *addr)
 {
-	return a->sid == sid && !memcmp(a->remote, addr, ETH_ALEN);
+	return a->sid == sid && ether_addr_equal_unaligned(a->remote, addr);
 }
 
 #if 8 % PPPOE_HASH_BITS
-- 
1.8.0
