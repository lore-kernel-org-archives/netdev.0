From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next 3/3] bridge: send query as soon as leave is received
Date: Mon, 29 Apr 2013 15:26:32 +0800
Message-ID: <1367220392-17496-3-git-send-email-amwang@redhat.com>
References: <1367220392-17496-1-git-send-email-amwang@redhat.com>
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17224 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751429Ab3D2H1W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Apr 2013 03:27:22 -0400
In-Reply-To: <1367220392-17496-1-git-send-email-amwang@redhat.com>
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
 net/bridge/br_multicast.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index a821a4e..03a8f2b 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1246,6 +1246,17 @@ static void br_multicast_leave_group(struct net_bridge *br,
 	if (!mp)
 		goto out;
 
+	if (br->multicast_querier) {
+		mod_timer(&br->multicast_query_timer, jiffies);
+		list_for_each_entry(port, &br->port_list, list) {
+			if (port->state == BR_STATE_DISABLED ||
+			    port->state == BR_STATE_BLOCKING)
+				continue;
+
+			__br_multicast_enable_port(port);
+		}
+	}
+
 	if (port && (port->flags & BR_MULTICAST_FAST_LEAVE)) {
 		struct net_bridge_port_group __rcu **pp;
 
-- 
1.7.7.6
