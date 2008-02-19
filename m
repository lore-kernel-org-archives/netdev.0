From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 16/17 net-2.6.26] [NETNS]: Enable IPv4 address manipulations inside namespace.
Date: Tue, 19 Feb 2008 10:31:36 +0300
Message-ID: <1203406297-32725-16-git-send-email-den@openvz.org>
References: <1203406116.27296.1.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	devel@openvz.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:51169 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755403AbYBSHbQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 02:31:16 -0500
In-Reply-To: <1203406116.27296.1.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/devinet.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index f7e78b7..aa23d10 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -446,9 +446,6 @@ static int inet_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg
 
 	ASSERT_RTNL();
 
-	if (net != &init_net)
-		return -EINVAL;
-
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv4_policy);
 	if (err < 0)
 		goto errout;
@@ -560,9 +557,6 @@ static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg
 
 	ASSERT_RTNL();
 
-	if (net != &init_net)
-		return -EINVAL;
-
 	ifa = rtm_to_ifaddr(net, nlh);
 	if (IS_ERR(ifa))
 		return PTR_ERR(ifa);
@@ -1169,9 +1163,6 @@ static int inet_dump_ifaddr(struct sk_buff *skb, struct netlink_callback *cb)
 	struct in_ifaddr *ifa;
 	int s_ip_idx, s_idx = cb->args[0];
 
-	if (net != &init_net)
-		return 0;
-
 	s_ip_idx = ip_idx = cb->args[1];
 	idx = 0;
 	for_each_netdev(net, dev) {
-- 
1.5.3.rc5

