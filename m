From: fgao@ikuai8.com
Subject: [PATCH net-next v2 1/1] driver: ipvlan: Use NF_IP_PRI_LAST as hook priority instead of INT_MAX
Date: Sun, 27 Nov 2016 19:18:02 +0800
Message-ID: <1480245482-10357-1-git-send-email-fgao@ikuai8.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, maheshb@google.com, edumazet@google.com,
        netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg291.qq.com ([113.108.11.223]:55304 "EHLO smtpbg291.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753640AbcK0LSo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Nov 2016 06:18:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

It is better to use NF_IP_PRI_LAST instead of INT_MAX as hook priority.
The former is good at readability and easier to maintain.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v2: Add the lost header file. It is added in local but not in v1 patch
 v1: Inital patch

 drivers/net/ipvlan/ipvlan_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index ab90b22..01c7446 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -7,6 +7,7 @@
  *
  */
 
+#include "linux/netfilter_ipv4.h"
 #include "ipvlan.h"
 
 static u32 ipvl_nf_hook_refcnt = 0;
@@ -16,13 +17,13 @@
 		.hook     = ipvlan_nf_input,
 		.pf       = NFPROTO_IPV4,
 		.hooknum  = NF_INET_LOCAL_IN,
-		.priority = INT_MAX,
+		.priority = NF_IP_PRI_LAST,
 	},
 	{
 		.hook     = ipvlan_nf_input,
 		.pf       = NFPROTO_IPV6,
 		.hooknum  = NF_INET_LOCAL_IN,
-		.priority = INT_MAX,
+		.priority = NF_IP_PRI_LAST,
 	},
 };
 
-- 
1.9.1
