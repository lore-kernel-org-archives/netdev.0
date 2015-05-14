From: roopa@cumulusnetworks.com
Subject: [PATCH net] rename RTNH_F_EXTERNAL to RTNH_F_OFFLOAD
Date: Wed, 13 May 2015 21:17:41 -0700
Message-ID: <1431577061-12517-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, sfeldma@gmail.com, jiri@resnulli.us,
	gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:34882 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbbENERs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 00:17:48 -0400
Received: by pdbqd1 with SMTP id qd1so72276672pdb.2
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 21:17:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

RTNH_F_EXTERNAL today is printed as "offload" in iproute2 output.

This patch renames the flag to be consistent with what the user sees.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
RTNH_F_EXTERNAL was introduced in 4.1 and is not out in 4.0 kernel.

 include/uapi/linux/rtnetlink.h |    2 +-
 net/ipv4/fib_trie.c            |    2 +-
 net/switchdev/switchdev.c      |    6 +++---
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 974db03..17fb02f 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -337,7 +337,7 @@ struct rtnexthop {
 #define RTNH_F_DEAD		1	/* Nexthop is dead (used by multipath)	*/
 #define RTNH_F_PERVASIVE	2	/* Do recursive gateway lookup	*/
 #define RTNH_F_ONLINK		4	/* Gateway is forced on link	*/
-#define RTNH_F_EXTERNAL		8	/* Route installed externally	*/
+#define RTNH_F_OFFLOAD		8	/* offloaded route */
 
 /* Macros to handle hexthops */
 
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index e13fcc6..64c2076 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1764,7 +1764,7 @@ void fib_table_flush_external(struct fib_table *tb)
 			/* record local slen */
 			slen = fa->fa_slen;
 
-			if (!fi || !(fi->fib_flags & RTNH_F_EXTERNAL))
+			if (!fi || !(fi->fib_flags & RTNH_F_OFFLOAD))
 				continue;
 
 			netdev_switch_fib_ipv4_del(n->key,
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 46568b8..055453d 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -338,7 +338,7 @@ int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 					      fi, tos, type, nlflags,
 					      tb_id);
 		if (!err)
-			fi->fib_flags |= RTNH_F_EXTERNAL;
+			fi->fib_flags |= RTNH_F_OFFLOAD;
 	}
 
 	return err;
@@ -364,7 +364,7 @@ int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 	const struct swdev_ops *ops;
 	int err = 0;
 
-	if (!(fi->fib_flags & RTNH_F_EXTERNAL))
+	if (!(fi->fib_flags & RTNH_F_OFFLOAD))
 		return 0;
 
 	dev = netdev_switch_get_dev_by_nhs(fi);
@@ -376,7 +376,7 @@ int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 		err = ops->swdev_fib_ipv4_del(dev, htonl(dst), dst_len,
 					      fi, tos, type, tb_id);
 		if (!err)
-			fi->fib_flags &= ~RTNH_F_EXTERNAL;
+			fi->fib_flags &= ~RTNH_F_OFFLOAD;
 	}
 
 	return err;
-- 
1.7.10.4
