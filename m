From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 2/6] [IPV4]: Small style cleanup of the error path in rtm_to_ifaddr.
Date: Thu, 31 Jan 2008 15:00:46 +0300
Message-ID: <1201780850-22216-2-git-send-email-den@openvz.org>
References: <47A1B835.7050600@sw.ru>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@openvz.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:62730 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1764205AbYAaMAr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 07:00:47 -0500
In-Reply-To: <47A1B835.7050600@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove error code assignment inside brackets on failure. The code looks better
if the error is assigned before condition check. Also, the compiler treats this
better.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/devinet.c |   21 ++++++++-------------
 1 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 21f71bf..9da4c68 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -492,39 +492,34 @@ static struct in_ifaddr *rtm_to_ifaddr(struct nlmsghdr *nlh)
 	struct ifaddrmsg *ifm;
 	struct net_device *dev;
 	struct in_device *in_dev;
-	int err = -EINVAL;
+	int err;
 
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv4_policy);
 	if (err < 0)
 		goto errout;
 
 	ifm = nlmsg_data(nlh);
-	if (ifm->ifa_prefixlen > 32 || tb[IFA_LOCAL] == NULL) {
-		err = -EINVAL;
+	err = -EINVAL;
+	if (ifm->ifa_prefixlen > 32 || tb[IFA_LOCAL] == NULL)
 		goto errout;
-	}
 
 	dev = __dev_get_by_index(&init_net, ifm->ifa_index);
-	if (dev == NULL) {
-		err = -ENODEV;
+	err = -ENODEV;
+	if (dev == NULL)
 		goto errout;
-	}
 
 	in_dev = __in_dev_get_rtnl(dev);
-	if (in_dev == NULL) {
-		err = -ENOBUFS;
+	err = -ENOBUFS;
+	if (in_dev == NULL)
 		goto errout;
-	}
 
 	ifa = inet_alloc_ifa();
-	if (ifa == NULL) {
+	if (ifa == NULL)
 		/*
 		 * A potential indev allocation can be left alive, it stays
 		 * assigned to its device and is destroy with it.
 		 */
-		err = -ENOBUFS;
 		goto errout;
-	}
 
 	ipv4_devconf_setall(in_dev);
 	in_dev_hold(in_dev);
-- 
1.5.3.rc5

