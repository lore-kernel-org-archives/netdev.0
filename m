From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] 6lowpan: set peer_addr correctly again
Date: Tue, 28 Mar 2017 15:29:08 +0200
Message-ID: <20170328132935.382216-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Stefan Schmidt <stefan@osg.samsung.com>,
        Jukka Rissanen <jukka.rissanen@linux.intel.com>,
        Luiz Augusto von Dentz <luiz.von.dentz@intel.com>,
        Eric Dumazet <edumazet@google.com>,
        Patrik Flykt <patrik.flykt@linux.intel.com>,
        Alexander Aring <aar@pengutronix.de>,
        Glenn Ruben Bakke <glennrubenbakke@nordicsemi.no>,
        linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:63867 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755913AbdC1Nca (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 09:32:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A bugfix accidentally changed one line to return the peer_addr
from setup_header, causing it to become unused:

net/bluetooth/6lowpan.c: In function 'setup_header':
net/bluetooth/6lowpan.c:402:14: error: parameter 'peer_addr' set but not used [-Werror=unused-but-set-parameter]

The only user of the variable is a subsequent printk(), and
it is not otherwise initialized, so reverting the changed line
looks like the right fix.

Fixes: fb6f2f606ce8 ("6lowpan: Fix IID format for Bluetooth")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 net/bluetooth/6lowpan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
index 24348c8579dd..ba28c7b1557f 100644
--- a/net/bluetooth/6lowpan.c
+++ b/net/bluetooth/6lowpan.c
@@ -432,7 +432,7 @@ static int setup_header(struct sk_buff *skb, struct net_device *netdev,
 		}
 
 		daddr = peer->lladdr;
-		peer_addr = &peer->chan->dst;
+		*peer_addr = peer->chan->dst;
 		*peer_addr_type = peer->chan->dst_type;
 		lowpan_cb(skb)->chan = peer->chan;
 
-- 
2.9.0
