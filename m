From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 18/20] net: fddi: slight optimization of addr
 compare
Date: Sat, 28 Dec 2013 14:18:16 +0800
Message-ID: <52BE6D28.20002@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:42516 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755283Ab3L1GSW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 01:18:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use possibly more efficient ether_addr_equal
to instead of memcmp.

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/fddi/skfp/fplustm.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/fddi/skfp/fplustm.c b/drivers/net/fddi/skfp/fplustm.c
index d918d8a..7d3779a 100644
--- a/drivers/net/fddi/skfp/fplustm.c
+++ b/drivers/net/fddi/skfp/fplustm.c
@@ -23,6 +23,7 @@
 #include "h/smc.h"
 #include "h/supern_2.h"
 #include <linux/bitrev.h>
+#include <linux/etherdevice.h>
 
 #ifndef	lint
 static const char ID_sccs[] = "@(#)fplustm.c	1.32 99/02/23 (C) SK " ;
@@ -1082,7 +1083,7 @@ static struct s_fpmc* mac_get_mc_table(struct s_smc *smc,
 				slot = tb ;
 			continue ;
 		}
-		if (memcmp((char *)&tb->a,(char *)own,6))
+		if (!ether_addr_equal((char *)&tb->a, (char *)own))
 			continue ;
 		return tb;
 	}
-- 
1.8.0
