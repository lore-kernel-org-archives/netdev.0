From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH v2] IPv6: Fix not join all-router mcast group when forwarding
 set.
Date: Tue, 06 Mar 2012 08:45:17 +0800
Message-ID: <4F555E1D.8020008@cn.fujitsu.com>
References: <4F548D59.1060600@cn.fujitsu.com> <20120305.151125.1618240418198694711.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:44030 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932433Ab2CFApW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2012 19:45:22 -0500
In-Reply-To: <20120305.151125.1618240418198694711.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When forwarding was set and a new net device is register,
we need add this device to the all-router mcast group.

Signed-off-by: Li Wei <lw@cn.fujitsu.com>
---
 net/ipv6/addrconf.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c02280a..6b8ebc5 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -434,6 +434,10 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 	/* Join all-node multicast group */
 	ipv6_dev_mc_inc(dev, &in6addr_linklocal_allnodes);
 
+	/* Join all-router multicast group if forwarding is set */
+	if (ndev->cnf.forwarding && dev && (dev->flags & IFF_MULTICAST))
+		ipv6_dev_mc_inc(dev, &in6addr_linklocal_allrouters);
+
 	return ndev;
 }
 
-- 
1.7.1
