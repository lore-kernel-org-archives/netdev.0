From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] nets: Introduce read_pnet() and write_pnet()  helpers
Date: Wed, 12 Nov 2008 07:20:46 +0100
Message-ID: <491A75BE.1010907@cosmosbay.com>
References: <20081110.164424.167225199.davem@davemloft.net>	<20081111110847.GC3665@x200.localdomain>	<20081111111946.GD3665@x200.localdomain> <20081111.164554.143409564.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080503060008040409080805"
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:44408 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086AbYKLGUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 01:20:55 -0500
In-Reply-To: <20081111.164554.143409564.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080503060008040409080805
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

So in this version I splited the patches to make them clear

I removed the DECLARE_PNET since it was apparently using too
many capital letters :)

Thanks

[PATCH] nets: Introduce read_pnet() and write_pnet() helpers

This patch introduces two helpers that deal with reading and writing
struct net pointers in various network structures.

Their implementation depends on CONFIG_NET_NS

For symmetry, both functions work with "struct net **pnet".

Their usage should reduce the number of #ifdef CONFIG_NET_NS,
without adding many helpers for each network structure
that hold a "struct net *pointer"

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/net/net_namespace.h |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+)


--------------080503060008040409080805
Content-Type: text/plain;
 name="pnet.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pnet.patch"

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 700c53a..3195577 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -192,6 +192,24 @@ static inline void release_net(struct net *net)
 }
 #endif
 
+#ifdef CONFIG_NET_NS
+
+static inline void write_pnet(struct net **pnet, struct net *net)
+{
+	*pnet = net;
+}
+
+static inline struct net *read_pnet(struct net * const *pnet)
+{
+	return *pnet;
+}
+
+#else
+
+#define write_pnet(pnet, net)	do { (void)(net);} while (0)
+#define read_pnet(pnet)		(&init_net)
+
+#endif
 
 #define for_each_net(VAR)				\
 	list_for_each_entry(VAR, &net_namespace_list, list)

--------------080503060008040409080805--
