From: Amine Kherbouche <amine.kherbouche@6wind.com>
Subject: [PATCH v5 1/2] mpls: export mpls_forward()
Date: Thu, 28 Sep 2017 18:34:38 +0200
Message-ID: <1c741aad9bd9516d99a46192f561125d18b28fa4.1506616215.git.amine.kherbouche@6wind.com>
References: <cover.1506616214.git.amine.kherbouche@6wind.com>
Cc: amine.kherbouche@6wind.com, equinox@diac24.net
To: netdev@vger.kernel.org, davem@davemloft.net, xeb@mail.ru,
        roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:53529 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751963AbdI1QfI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 12:35:08 -0400
Received: by mail-wm0-f54.google.com with SMTP id q132so3425538wmd.2
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 09:35:07 -0700 (PDT)
In-Reply-To: <cover.1506616214.git.amine.kherbouche@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Exporting mpls_forward() function to be able to be called from elsewhere
such as MPLSoverGRE in the next commit.

Signed-off-by: Amine Kherbouche <amine.kherbouche@6wind.com>
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/linux/mpls.h | 4 ++++
 net/mpls/af_mpls.c   | 5 +++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/mpls.h b/include/linux/mpls.h
index 384fb22..b0579ab 100644
--- a/include/linux/mpls.h
+++ b/include/linux/mpls.h
@@ -2,10 +2,14 @@
 #define _LINUX_MPLS_H
 
 #include <uapi/linux/mpls.h>
+#include <linux/netdevice.h>
 
 #define MPLS_TTL_MASK		(MPLS_LS_TTL_MASK >> MPLS_LS_TTL_SHIFT)
 #define MPLS_BOS_MASK		(MPLS_LS_S_MASK >> MPLS_LS_S_SHIFT)
 #define MPLS_TC_MASK		(MPLS_LS_TC_MASK >> MPLS_LS_TC_SHIFT)
 #define MPLS_LABEL_MASK		(MPLS_LS_LABEL_MASK >> MPLS_LS_LABEL_SHIFT)
 
+int mpls_forward(struct sk_buff *skb, struct net_device *dev,
+		 struct packet_type *pt, struct net_device *orig_dev);
+
 #endif  /* _LINUX_MPLS_H */
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index c5b9ce4..36ea2ad 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -307,8 +307,8 @@ static bool mpls_egress(struct net *net, struct mpls_route *rt,
 	return success;
 }
 
-static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
-			struct packet_type *pt, struct net_device *orig_dev)
+int mpls_forward(struct sk_buff *skb, struct net_device *dev,
+		 struct packet_type *pt, struct net_device *orig_dev)
 {
 	struct net *net = dev_net(dev);
 	struct mpls_shim_hdr *hdr;
@@ -442,6 +442,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	kfree_skb(skb);
 	return NET_RX_DROP;
 }
+EXPORT_SYMBOL(mpls_forward);
 
 static struct packet_type mpls_packet_type __read_mostly = {
 	.type = cpu_to_be16(ETH_P_MPLS_UC),
-- 
2.1.4
