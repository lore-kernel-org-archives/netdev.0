From: Quentin Armitage <quentin@armitage.org.uk>
Subject: [PATCH] net: remove unimplemented RTNH_F_PERVASIVE
Date: Sat,  2 Apr 2016 09:43:23 +0100
Message-ID: <1459586603-24006-1-git-send-email-quentin@armitage.org.uk>
Cc: Quentin Armitage <quentin@armitage.org.uk>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rslrsmtp2.opaltelecom.net ([62.24.128.202]:17344 "EHLO
	iprslrsmtp2msp.cpwnetworks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751341AbcDBIny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2016 04:43:54 -0400
Received: from [92.27.6.192] (helo=nabal.armitage.org.uk)
	by rslr-smtp-2.cpwnetworks.com with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.63)
	(envelope-from <quentin@armitage.org.uk>)
	id 1amH9o-0006HK-2h
	for netdev@vger.kernel.org; Sat, 02 Apr 2016 09:43:48 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linux 2.1.68 introduced RTNH_F_PERVASIVE, but it had no implementation
and couldn't be enabled since the required config parameter wasn't in
any Kconfig file (see commit d088dde7b).

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
index df48034..f5660c6 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -243,7 +243,7 @@ out:
 	} else {
 		struct net_device *dev;
 
-		if (nh->nh_flags&(RTNH_F_PERVASIVE|RTNH_F_ONLINK))
+		if (nh->nh_flags&RTNH_F_ONLINK)
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
