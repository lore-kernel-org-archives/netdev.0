From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 01/24] net, diet: Reduce netdev name hash table for CONFIG_BASE_SMALL
Date: Mon,  5 May 2014 15:25:50 -0700
Message-ID: <1399328773-6531-2-git-send-email-andi@firstfloor.org>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com,
	Andi Kleen <ak@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:48062 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756898AbaEEW22 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2014 18:28:28 -0400
In-Reply-To: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <ak@linux.intel.com>

Small systems typically only have two network devices, so use
hash shift 2.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 include/net/net_namespace.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 5f9eb26..d2b8c6c 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -37,7 +37,11 @@ struct sock;
 struct netns_ipvs;
 
 
+#ifdef CONFIG_BASE_SMALL
+#define NETDEV_HASHBITS    2
+#else
 #define NETDEV_HASHBITS    8
+#endif
 #define NETDEV_HASHENTRIES (1 << NETDEV_HASHBITS)
 
 struct net {
-- 
1.9.0
