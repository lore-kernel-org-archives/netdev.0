From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/4] net: Tag the network flow with the network namespace
	it is in (v2)
Date: Fri, 30 Nov 2007 19:07:29 +0300
Message-ID: <20071130160729.GA10153@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@openvz.org, netdev@vger.kernel.org, davem@davemloft.net
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:51952 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752608AbXK3QGf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 11:06:35 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As well as marking flows this indirectly marks the ipv4 routing cache
as every routing entry contains a flow.

It is useful to add the network namespace into flows as frequently
the routing information for ingoing and outgoing network packets is
collected into a flow structure which is then used for several functions
as it sorts out what is going on.

Changes from v1:
- remove flow.h dependency from net_namespace.h

Signed-off-by: Denis V. Lunev <den@openvz.org>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/flow.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index af59fa5..9590bbe 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -10,7 +10,9 @@
 #include <linux/in6.h>
 #include <asm/atomic.h>
 
+struct net;
 struct flowi {
+	struct net *fl_net;
 	int	oif;
 	int	iif;
 	__u32	mark;
-- 
1.5.3.rc5

