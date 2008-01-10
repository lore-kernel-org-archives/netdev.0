From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 5/6][NETNS]: Use the per-net ipv6_devconf_dflt
Date: Thu, 10 Jan 2008 17:08:24 +0300
Message-ID: <478626D8.90305@openvz.org>
References: <478623C0.7030008@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:59309 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754459AbYAJOI4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 09:08:56 -0500
In-Reply-To: <478623C0.7030008@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All its users are in net/ipv6/addrconf.c's sysctl handlers.
Since they already have the struct net to get from, the
per-net ipv6_devconf_dflt can already be used.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv6/addrconf.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3ad081e..9b96de3 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -334,7 +334,7 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 
 	rwlock_init(&ndev->lock);
 	ndev->dev = dev;
-	memcpy(&ndev->cnf, &ipv6_devconf_dflt, sizeof(ndev->cnf));
+	memcpy(&ndev->cnf, dev->nd_net->ipv6.devconf_dflt, sizeof(ndev->cnf));
 	ndev->cnf.mtu6 = dev->mtu;
 	ndev->cnf.sysctl = NULL;
 	ndev->nd_parms = neigh_parms_alloc(dev, &nd_tbl);
@@ -481,11 +481,11 @@ static void addrconf_fixup_forwarding(struct ctl_table *table, int *p, int old)
 	struct net *net;
 
 	net = (struct net *)table->extra2;
-	if (p == &ipv6_devconf_dflt.forwarding)
+	if (p == &net->ipv6.devconf_dflt->forwarding)
 		return;
 
 	if (p == &ipv6_devconf.forwarding) {
-		ipv6_devconf_dflt.forwarding = ipv6_devconf.forwarding;
+		net->ipv6.devconf_dflt->forwarding = ipv6_devconf.forwarding;
 		addrconf_forward_change(net);
 	} else if ((!*p) ^ (!old))
 		dev_forward_change((struct inet6_dev *)table->extra1);
-- 
1.5.3.4

