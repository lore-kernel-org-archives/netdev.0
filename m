From: Cong Ding <dinggnu@gmail.com>
Subject: [PATCH] ipv6: addrconf.c: remove unnecessary "if"
Date: Tue, 18 Dec 2012 23:08:56 +0100
Message-ID: <1355868536-1622-1-git-send-email-dinggnu@gmail.com>
Cc: Cong Ding <dinggnu@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

the value of err is always negative if it goes to errout, so we don't need to
check the value of err.

Signed-off-by: Cong Ding <dinggnu@gmail.com>
---
 net/ipv6/addrconf.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6fca01f..408cac4a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -534,8 +534,7 @@ void inet6_netconf_notify_devconf(struct net *net, int type, int ifindex,
 	rtnl_notify(skb, net, 0, RTNLGRP_IPV6_NETCONF, NULL, GFP_ATOMIC);
 	return;
 errout:
-	if (err < 0)
-		rtnl_set_sk_err(net, RTNLGRP_IPV6_NETCONF, err);
+	rtnl_set_sk_err(net, RTNLGRP_IPV6_NETCONF, err);
 }
 
 static const struct nla_policy devconf_ipv6_policy[NETCONFA_MAX+1] = {
-- 
1.7.10.4
