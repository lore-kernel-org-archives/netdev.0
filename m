From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] netcp: fix typo in netcp_setup_tc
Date: Mon, 22 Feb 2016 21:50:39 +0100
Message-ID: <1456174246-293822-1-git-send-email-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, Wingman Kwok <w-kwok2@ti.com>,
	Murali Karicheri <m-karicheri2@ti.com>,
	linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.135]:52502 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755468AbcBVUvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 15:51:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A change to the prototype of netcp_setup_tc() missed a '*'
character, which broke compilation of hte netcp driver:

drivers/net/ethernet/ti/netcp_core.c: In function 'netcp_setup_tc':
drivers/net/ethernet/ti/netcp_core.c:1839:31: error: invalid type argument of '->' (have 'struct tc_to_netdev')
drivers/net/ethernet/ti/netcp_core.c:1872:19: error: initialization from incompatible pointer type [-Werror=incompatible-pointer-types]

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 16e5cc647173 ("net: rework setup_tc ndo op to consume general tc operand")
---
 drivers/net/ethernet/ti/netcp_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 132caebb401a..e74e68eabd5f 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1829,7 +1829,7 @@ static u16 netcp_select_queue(struct net_device *dev, struct sk_buff *skb,
 }
 
 static int netcp_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
-			  struct tc_to_netdev tc)
+			  struct tc_to_netdev *tc)
 {
 	int i;
 
-- 
2.7.0
