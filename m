From: "Dmitry V. Levin" <ldv@altlinux.org>
Subject: [PATCH] uapi: fix linux/ip6_tunnel.h userspace compilation errors
Date: Thu, 23 Feb 2017 01:38:03 +0300
Message-ID: <20170222223803.GA14311@altlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vmicros1.altlinux.org ([194.107.17.57]:45944 "EHLO
        vmicros1.altlinux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933008AbdBVWiM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 17:38:12 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Include <linux/if.h> and <linux/in6.h> to fix the following
linux/ip6_tunnel.h userspace compilation errors:

/usr/include/linux/ip6_tunnel.h:23:12: error: 'IFNAMSIZ' undeclared here (not in a function)
  char name[IFNAMSIZ]; /* name of tunnel device */
/usr/include/linux/ip6_tunnel.h:30:18: error: field 'laddr' has incomplete type
  struct in6_addr laddr; /* local tunnel end-point address */

Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
---
 include/uapi/linux/ip6_tunnel.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/uapi/linux/ip6_tunnel.h b/include/uapi/linux/ip6_tunnel.h
index 48af63c..425926c 100644
--- a/include/uapi/linux/ip6_tunnel.h
+++ b/include/uapi/linux/ip6_tunnel.h
@@ -2,6 +2,8 @@
 #define _IP6_TUNNEL_H
 
 #include <linux/types.h>
+#include <linux/if.h>		/* For IFNAMSIZ. */
+#include <linux/in6.h>		/* For struct in6_addr. */
 
 #define IPV6_TLV_TNL_ENCAP_LIMIT 4
 #define IPV6_DEFAULT_TNL_ENCAP_LIMIT 4
-- 
ldv
