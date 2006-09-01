From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/8] address: Convert address deletion to new netlink api
Date: Fri, 01 Sep 2006 23:39:59 +0200
Message-ID: <20060901214014.355008764@lsx.localdomain>
References: <20060901213957.138695086@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:1169 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750975AbWIAVlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 17:41:18 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_ipv6_deladdr
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19/net/ipv6/addrconf.c
===================================================================
--- net-2.6.19.orig/net/ipv6/addrconf.c	2006-09-01 23:15:14.000000000 +0200
+++ net-2.6.19/net/ipv6/addrconf.c	2006-09-01 23:15:18.000000000 +0200
@@ -2894,22 +2894,17 @@
 static int
 inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct rtattr **rta = arg;
-	struct ifaddrmsg *ifm = NLMSG_DATA(nlh);
+	struct ifaddrmsg *ifm;
+	struct nlattr *tb[IFA_MAX+1];
 	struct in6_addr *pfx;
+	int err;
 
-	pfx = NULL;
-	if (rta[IFA_ADDRESS-1]) {
-		if (RTA_PAYLOAD(rta[IFA_ADDRESS-1]) < sizeof(*pfx))
-			return -EINVAL;
-		pfx = RTA_DATA(rta[IFA_ADDRESS-1]);
-	}
-	if (rta[IFA_LOCAL-1]) {
-		if (RTA_PAYLOAD(rta[IFA_LOCAL-1]) < sizeof(*pfx) ||
-		    (pfx && memcmp(pfx, RTA_DATA(rta[IFA_LOCAL-1]), sizeof(*pfx))))
-			return -EINVAL;
-		pfx = RTA_DATA(rta[IFA_LOCAL-1]);
-	}
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy);
+	if (err < 0)
+		return err;
+
+	ifm = nlmsg_data(nlh);
+	pfx = extract_addr(tb[IFA_ADDRESS], tb[IFA_LOCAL]);
 	if (pfx == NULL)
 		return -EINVAL;
 


-- 
VGER BF report: H 0.0599509
