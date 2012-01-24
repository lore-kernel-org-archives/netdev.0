From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipip: Fix bug added to ipip_tunnel_xmit().
Date: Tue, 24 Jan 2012 18:18:38 -0500 (EST)
Message-ID: <20120124.181838.1470195215432711102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43075 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751978Ab2AXXSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 18:18:40 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id q0ONIcHW025650
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 24 Jan 2012 15:18:39 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We can remove the rt_gateway == 0 check but we shouldn't
remove the 'dst' initialization too.

Noticed by Eric Dumazet.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ipip.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 87c63b6..f84ebff 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -454,6 +454,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 			dev->stats.tx_fifo_errors++;
 			goto tx_error;
 		}
+		dst = rt->rt_gateway;
 	}
 
 	rt = ip_route_output_ports(dev_net(dev), &fl4, NULL,
-- 
1.7.7.6
