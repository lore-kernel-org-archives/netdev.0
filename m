From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH net-next] bridge: avoid br_ifinfo_notify when nothing changed
Date: Sat, 23 Mar 2013 13:14:13 +0800
Message-ID: <1364015653-7322-1-git-send-email-honkiko@gmail.com>
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	stephen@networkplumber.org, herbert@gondor.hengli.com.au,
	zhiguo.hong@emc.com, Hong Zhiguo <honkiko@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:50405 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755544Ab3CWFOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Mar 2013 01:14:31 -0400
Received: by mail-pb0-f42.google.com with SMTP id xb4so3378080pbc.29
        for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 22:14:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When neither IFF_BRIDGE_PORT or IFF_BRIDGE_PORT is set,
and afspec == NULL but  protinfo != NULL, we run into
"if (err == 0) br_ifinfo_notify(RTM_NEWLINK, p);" with
random value in ret.

Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
---
 net/bridge/br_netlink.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 84c3b7d..b96e02e 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -357,7 +357,7 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh)
 	struct nlattr *afspec;
 	struct net_bridge_port *p;
 	struct nlattr *tb[IFLA_BRPORT_MAX + 1];
-	int err;
+	int err = 0;
 
 	ifm = nlmsg_data(nlh);
 
@@ -370,7 +370,7 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh)
 	/* We want to accept dev as bridge itself if the AF_SPEC
 	 * is set to see if someone is setting vlan info on the brigde
 	 */
-	if (!p && ((dev->priv_flags & IFF_EBRIDGE) && !afspec))
+	if (!p && !afspec)
 		return -EINVAL;
 
 	if (p && protinfo) {
-- 
1.7.10.4
