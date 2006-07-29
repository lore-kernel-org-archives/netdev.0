From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 15/20] [PATCH] [XFRM] STATE: Add Mobile IPv6 route optimization protocols to netlink interface.
Date: Sat, 29 Jul 2006 18:38:57 +0900
Message-ID: <11541659372139-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:49795 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1422722AbWG2Ji5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:38:57 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add Mobile IPv6 route optimization protocols to netlink interface.
Route optimization states carry care-of address.
Based on MIPL2 kernel patch.
---
 net/xfrm/xfrm_user.c |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index cf62208..e45d25f 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -27,6 +27,9 @@ #include <net/sock.h>
 #include <net/xfrm.h>
 #include <net/netlink.h>
 #include <asm/uaccess.h>
+#ifdef CONFIG_IPV6_MIP6
+#include <linux/in6.h>
+#endif
 
 static int verify_one_alg(struct rtattr **xfrma, enum xfrm_attr_type_t type)
 {
@@ -171,7 +174,26 @@ #endif
 			goto out;
 		break;
 
+#ifdef CONFIG_IPV6_MIP6
+	case IPPROTO_DSTOPTS:
+	case IPPROTO_ROUTING:
+#ifdef CONFIG_XFRM_ADVANCED
+		if (xfrma[XFRMA_ALG_COMP-1]	||
+		    xfrma[XFRMA_ALG_AUTH-1]	||
+		    xfrma[XFRMA_ALG_CRYPT-1]	||
+		    xfrma[XFRMA_ENCAP-1]	||
+		    xfrma[XFRMA_SEC_CTX - 1]	||
+		    !xfrma[XFRMA_ADDR-1])
+			goto out;
+		break;
+#else
+		err = -ENOSYS;
+		goto out;
+#endif
+#endif
+
 	default:
+		err = -EPROTONOSUPPORT;
 		goto out;
 	};
 
-- 
1.4.1

