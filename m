From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] netns: return RTM_NEWNSID instead of RTM_GETNSID on a get
Date: Mon, 11 May 2015 15:57:31 +0200
Message-ID: <1431352651-31921-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:46837 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754131AbbEKN5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 09:57:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Usually, RTM_NEWxxx is returned on a get (same as a dump).

Fixes: 0c7aecd4bde4 ("netns: add rtnl cmd to add and get peer netns ids")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

David, FYI, this patch will conflict with my last series on net-next.
The prototype of rtnl_net_fill() has changed. In any problem, please let me
know.

 net/core/net_namespace.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 78fc04ad36fc..572af0011997 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -601,7 +601,7 @@ static int rtnl_net_getid(struct sk_buff *skb, struct nlmsghdr *nlh)
 	}
 
 	err = rtnl_net_fill(msg, NETLINK_CB(skb).portid, nlh->nlmsg_seq, 0,
-			    RTM_GETNSID, net, peer, -1);
+			    RTM_NEWNSID, net, peer, -1);
 	if (err < 0)
 		goto err_out;
 
-- 
2.2.2
