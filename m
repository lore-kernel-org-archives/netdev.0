From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-2.6.25] [ARP] Move inet_addr_type call after simple error checks in arp_contructor.
Date: Mon, 14 Jan 2008 16:53:32 +0300
Message-ID: <1200318812-18333-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:56500 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751051AbYANNxc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 08:53:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The neighbour entry will be destroyed in the case of error, so it is pointless
to perform constly routing table lookup in this case.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/arp.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index b715ec0..49c24ff 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -235,8 +235,6 @@ static int arp_constructor(struct neighbour *neigh)
 	struct in_device *in_dev;
 	struct neigh_parms *parms;
 
-	neigh->type = inet_addr_type(&init_net, addr);
-
 	rcu_read_lock();
 	in_dev = __in_dev_get_rcu(dev);
 	if (in_dev == NULL) {
@@ -244,6 +242,8 @@ static int arp_constructor(struct neighbour *neigh)
 		return -EINVAL;
 	}
 
+	neigh->type = inet_addr_type(&init_net, addr);
+
 	parms = in_dev->arp_parms;
 	__neigh_parms_put(neigh->parms);
 	neigh->parms = neigh_parms_clone(parms);
-- 
1.5.3.rc5

