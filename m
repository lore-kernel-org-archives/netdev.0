From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v2 3/3] bridge: send query as soon as leave is received
Date: Tue, 30 Apr 2013 11:41:10 +0800
Message-ID: <1367293270-26256-3-git-send-email-amwang@redhat.com>
References: <1367293270-26256-1-git-send-email-amwang@redhat.com>
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17487 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758266Ab3D3Dls (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Apr 2013 23:41:48 -0400
In-Reply-To: <1367293270-26256-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Continue sending queries when leave is received if the user marks
it as a querier.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Adam Baker <linux@baker-net.org.uk>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
v2: only send query to the port received leave

 net/bridge/br_multicast.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index bab3d5a..b1879c8 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1250,6 +1250,13 @@ static void br_multicast_leave_group(struct net_bridge *br,
 	if (!mp)
 		goto out;
 
+	if (br->multicast_querier) {
+		if (port)
+			__br_multicast_enable_port(port);
+		else
+			mod_timer(&br->multicast_query_timer, jiffies);
+	}
+
 	if (port && (port->flags & BR_MULTICAST_FAST_LEAVE)) {
 		struct net_bridge_port_group __rcu **pp;
 
-- 
1.7.7.6
