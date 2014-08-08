From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net] rtnetlink: fix VF info size
Date: Fri,  8 Aug 2014 16:44:32 +0200
Message-ID: <8491096ac8f0e7cc7745411c0af87fb5a146d44e.1407509058.git.jbenc@redhat.com>
Cc: Rony Efraim <ronye@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30424 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756967AbaHHOpI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2014 10:45:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 1d8faf48c74b8 ("net/core: Add VF link state control") added new
attribute to IFLA_VF_INFO group in rtnl_fill_ifinfo but did not adjust size
of the allocated memory in if_nlmsg_size/rtnl_vfinfo_size. As the result, we
may trigger warnings in rtnl_getlink and similar functions when many VF
links are enabled, as the information does not fit into the allocated skb.

Fixes: 1d8faf48c74b8 ("net/core: Add VF link state control")
Reported-by: Yulong Pei <ypei@redhat.com>
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/core/rtnetlink.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 8d39071f32d7..f0493e3b7471 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -804,7 +804,8 @@ static inline int rtnl_vfinfo_size(const struct net_device *dev,
 			(nla_total_size(sizeof(struct ifla_vf_mac)) +
 			 nla_total_size(sizeof(struct ifla_vf_vlan)) +
 			 nla_total_size(sizeof(struct ifla_vf_spoofchk)) +
-			 nla_total_size(sizeof(struct ifla_vf_rate)));
+			 nla_total_size(sizeof(struct ifla_vf_rate)) +
+			 nla_total_size(sizeof(struct ifla_vf_link_state)));
 		return size;
 	} else
 		return 0;
-- 
1.8.3.1
