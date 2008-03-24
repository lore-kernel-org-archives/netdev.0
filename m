From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 8/11 net-2.6.26] [NETNS]: Process netfilter hooks in initial namespace only.
Date: Mon, 24 Mar 2008 17:36:09 +0300
Message-ID: <1206369372-27711-8-git-send-email-den@openvz.org>
References: <1206369185.23705.7.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, xemul@openvz.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:62428 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758684AbYCXOfv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2008 10:35:51 -0400
In-Reply-To: <1206369185.23705.7.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There were no packets in the namespace other than initial previously. This
will be changed in the neareast future. Netfilters are not namespace aware
and should be processed in the initial namespace only for now.

Signed-off-by: Denis V. Lunev <den@openvz.org>
CC: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/core.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index c4065b8..ec05684 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -165,6 +165,14 @@ int nf_hook_slow(int pf, unsigned int hook, struct sk_buff *skb,
 	unsigned int verdict;
 	int ret = 0;
 
+#ifdef CONFIG_NET_NS
+	struct net *net;
+
+	net = indev == NULL ? outdev->nd_net : indev->nd_net;
+	if (net != &init_net)
+		return 1;
+#endif
+
 	/* We may already have this, but read-locks nest anyway */
 	rcu_read_lock();
 
-- 
1.5.3.rc5

