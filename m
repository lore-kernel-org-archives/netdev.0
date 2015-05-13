From: roopa@cumulusnetworks.com
Subject: [PATCH net-next] rename RTNH_F_EXTERNAL to RTNH_F_OFFLOAD
Date: Tue, 12 May 2015 22:27:10 -0700
Message-ID: <1431494830-4284-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, sfeldma@gmail.com, jiri@resnulli.us,
	gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35961 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbbEMF1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 01:27:17 -0400
Received: by pabsx10 with SMTP id sx10so38852144pab.3
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 22:27:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

RTNH_F_EXTERNAL today is printed as "offload" in iproute2 output.

This patch renames the flag to be consistent with what the user sees.

(I will post iproute2 patch if this gets accepted)

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
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
index 03444c6..d38aa7a 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1762,7 +1762,7 @@ void fib_table_flush_external(struct fib_table *tb)
 			/* record local slen */
 			slen = fa->fa_slen;
 
-			if (!fi || !(fi->fib_flags & RTNH_F_EXTERNAL))
+			if (!fi || !(fi->fib_flags & RTNH_F_OFFLOAD))
 				continue;
 
 			switchdev_fib_ipv4_del(n->key, KEYLENGTH - fa->fa_slen,
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 65d49d4..0457af7 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -674,7 +674,7 @@ int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 
 	err = switchdev_port_obj_add(dev, &fib_obj);
 	if (!err)
-		fi->fib_flags |= RTNH_F_EXTERNAL;
+		fi->fib_flags |= RTNH_F_OFFLOAD;
 
 	return err;
 }
@@ -710,7 +710,7 @@ int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 	struct net_device *dev;
 	int err = 0;
 
-	if (!(fi->fib_flags & RTNH_F_EXTERNAL))
+	if (!(fi->fib_flags & RTNH_F_OFFLOAD))
 		return 0;
 
 	dev = switchdev_get_dev_by_nhs(fi);
@@ -719,7 +719,7 @@ int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 
 	err = switchdev_port_obj_del(dev, &fib_obj);
 	if (!err)
-		fi->fib_flags &= ~RTNH_F_EXTERNAL;
+		fi->fib_flags &= ~RTNH_F_OFFLOAD;
 
 	return err;
 }
-- 
1.7.10.4
