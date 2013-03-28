From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH net-next] bridge: remove unused variable ifm
Date: Fri, 29 Mar 2013 00:21:22 +0800
Message-ID: <1364487682-5839-1-git-send-email-honkiko@gmail.com>
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:55720 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756886Ab3C1QVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 12:21:39 -0400
Received: by mail-pa0-f54.google.com with SMTP id fa10so2752739pad.27
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 09:21:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
---
 net/bridge/br_netlink.c |   12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index b96e02e..8e3abf5 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -352,17 +352,14 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 /* Change state and parameters on port. */
 int br_setlink(struct net_device *dev, struct nlmsghdr *nlh)
 {
-	struct ifinfomsg *ifm;
 	struct nlattr *protinfo;
 	struct nlattr *afspec;
 	struct net_bridge_port *p;
 	struct nlattr *tb[IFLA_BRPORT_MAX + 1];
 	int err = 0;
 
-	ifm = nlmsg_data(nlh);
-
-	protinfo = nlmsg_find_attr(nlh, sizeof(*ifm), IFLA_PROTINFO);
-	afspec = nlmsg_find_attr(nlh, sizeof(*ifm), IFLA_AF_SPEC);
+	protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_PROTINFO);
+	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
 	if (!protinfo && !afspec)
 		return 0;
 
@@ -411,14 +408,11 @@ out:
 /* Delete port information */
 int br_dellink(struct net_device *dev, struct nlmsghdr *nlh)
 {
-	struct ifinfomsg *ifm;
 	struct nlattr *afspec;
 	struct net_bridge_port *p;
 	int err;
 
-	ifm = nlmsg_data(nlh);
-
-	afspec = nlmsg_find_attr(nlh, sizeof(*ifm), IFLA_AF_SPEC);
+	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
 	if (!afspec)
 		return 0;
 
-- 
1.7.10.4
