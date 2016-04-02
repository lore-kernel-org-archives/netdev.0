From: Quentin Armitage <quentin@armitage.org.uk>
Subject: [PATCH v2] net: remove unimplemented RTNH_F_PERVASIVE
Date: Sat,  2 Apr 2016 17:51:28 +0100
Message-ID: <1459615888-456-1-git-send-email-quentin@armitage.org.uk>
References: <56FFED8B.7010701@cogentembedded.com>
Cc: Quentin Armitage <quentin@armitage.org.uk>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host-92-27-6-192.static.as13285.net ([92.27.6.192]:52022 "EHLO
	nabal.armitage.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751229AbcDBQvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2016 12:51:43 -0400
In-Reply-To: <56FFED8B.7010701@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linux 2.1.68 introduced RTNH_F_PERVASIVE, but it had no implementation
and couldn't be enabled since the required config parameter wasn't in
any Kconfig file (see commit d088dde7b196 ("ipv4: obsolete config in
kernel source (IP_ROUTE_PERVASIVE)")).

This commit removes all remaining references to RTNH_F_PERVASIVE.
Although this will cause userspace applications that were using the
flag to fail to build, they will be alerted to the fact that using
RTNH_F_PERVASIVE was not achieving anything.

Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>
---
 include/uapi/linux/rtnetlink.h |    2 +-
 net/decnet/dn_fib.c            |    2 +-
 net/ipv4/fib_semantics.c       |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index ca764b5..58e6ba0 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -339,7 +339,7 @@ struct rtnexthop {
 /* rtnh_flags */
 
 #define RTNH_F_DEAD		1	/* Nexthop is dead (used by multipath)	*/
-#define RTNH_F_PERVASIVE	2	/* Do recursive gateway lookup	*/
+					/* 2 was RTNH_F_PERVASIVE (never implemented) */
 #define RTNH_F_ONLINK		4	/* Gateway is forced on link	*/
 #define RTNH_F_OFFLOAD		8	/* offloaded route */
 #define RTNH_F_LINKDOWN		16	/* carrier-down on nexthop */
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index df48034..c53aa74 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -243,7 +243,7 @@ out:
 	} else {
 		struct net_device *dev;
 
-		if (nh->nh_flags&(RTNH_F_PERVASIVE|RTNH_F_ONLINK))
+		if (nh->nh_flags & RTNH_F_ONLINK)
 			return -EINVAL;
 
 		dev = __dev_get_by_index(&init_net, nh->nh_oif);
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index d97268e..3883860 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -803,7 +803,7 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 	} else {
 		struct in_device *in_dev;
 
-		if (nh->nh_flags & (RTNH_F_PERVASIVE | RTNH_F_ONLINK))
+		if (nh->nh_flags & RTNH_F_ONLINK)
 			return -EINVAL;
 
 		rcu_read_lock();
-- 
1.7.7.6
