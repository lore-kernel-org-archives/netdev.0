From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] rtnetlink: release net refcnt on error in do_setlink()
Date: Thu, 27 Nov 2014 10:16:15 +0100
Message-ID: <1417079775-9287-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:51644 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932130AbaK0JQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 04:16:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtnl_link_get_net() holds a reference on the 'struct net', we need to release
it in case of error.

CC: Eric W. Biederman <ebiederm@xmission.com>
Fixes: b51642f6d77b ("net: Enable a userns root rtnl calls that are safe for unprivilged users")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/rtnetlink.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index b9b7dfaf202b..76321ea442c3 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1498,6 +1498,7 @@ static int do_setlink(const struct sk_buff *skb,
 			goto errout;
 		}
 		if (!netlink_ns_capable(skb, net->user_ns, CAP_NET_ADMIN)) {
+			put_net(net);
 			err = -EPERM;
 			goto errout;
 		}
-- 
2.1.0
