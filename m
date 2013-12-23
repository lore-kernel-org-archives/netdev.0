From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 21/21] ppp: slight optimization of addr compare
Date: Mon, 23 Dec 2013 13:11:38 +0800
Message-ID: <52B7C60A.6050501@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Michal Ostrowski <mostrows@earthlink.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the recently added and possibly more efficient
ether_addr_equal_unaligned to instead of memcmp.

Cc: Michal Ostrowski <mostrows@earthlink.net>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/ppp/pppoe.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index 82ee6ed..01f6527 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -131,12 +131,13 @@ static inline struct pppoe_net *pppoe_pernet(struct net *net)
 
 static inline int cmp_2_addr(struct pppoe_addr *a, struct pppoe_addr *b)
 {
-	return a->sid == b->sid && !memcmp(a->remote, b->remote, ETH_ALEN);
+	return a->sid == b->sid && ether_addr_equal_unaligned(a->remote,
+							      b->remote);
 }
 
 static inline int cmp_addr(struct pppoe_addr *a, __be16 sid, char *addr)
 {
-	return a->sid == sid && !memcmp(a->remote, addr, ETH_ALEN);
+	return a->sid == sid && ether_addr_equal_unaligned(a->remote, addr);
 }
 
 #if 8 % PPPOE_HASH_BITS
-- 
1.8.0
