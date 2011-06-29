From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] net: iseries_veth: Omit check for multicast bit in netdev_for_each_mc_addr
Date: Wed, 29 Jun 2011 14:15:35 +0200
Message-ID: <1309349735-1690-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.zhaw.ch ([160.85.104.50]:40098 "EHLO mx1.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753781Ab1F2MZ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2011 08:25:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to check for the address being a multicast address in
the netdev_for_each_mc_addr loop, so remove it.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/iseries_veth.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/iseries_veth.c b/drivers/net/iseries_veth.c
index b6c296f..242bf52 100644
--- a/drivers/net/iseries_veth.c
+++ b/drivers/net/iseries_veth.c
@@ -964,11 +964,9 @@ static void veth_set_multicast_list(struct net_device *dev)
 			u8 *addr = ha->addr;
 			u64 xaddr = 0;
 
-			if (addr[0] & 0x01) {/* multicast address? */
-				memcpy(&xaddr, addr, ETH_ALEN);
-				port->mcast_addr[port->num_mcast] = xaddr;
-				port->num_mcast++;
-			}
+			memcpy(&xaddr, addr, ETH_ALEN);
+			port->mcast_addr[port->num_mcast] = xaddr;
+			port->num_mcast++;
 		}
 	}
 
-- 
1.7.5.4

