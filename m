From: Amine Kherbouche <amine.kherbouche@6wind.com>
Subject: [PATCH 1/2] mpls: expose stack entry function
Date: Thu, 21 Sep 2017 11:25:23 +0200
Message-ID: <1505985924-12479-2-git-send-email-amine.kherbouche@6wind.com>
References: <1505985924-12479-1-git-send-email-amine.kherbouche@6wind.com>
Cc: amine.kherbouche@6wind.com, equinox@diac24.net
To: netdev@vger.kernel.org, xeb@mail.ru, roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f174.google.com ([209.85.128.174]:45272 "EHLO
        mail-wr0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751786AbdIUJZ7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 05:25:59 -0400
Received: by mail-wr0-f174.google.com with SMTP id m18so4057198wrm.2
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 02:25:59 -0700 (PDT)
In-Reply-To: <1505985924-12479-1-git-send-email-amine.kherbouche@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Exposing mpls_forward() function to be able to be called from elsewhere
such as MPLS over GRE in the next commit.

Signed-off-by: Amine Kherbouche <amine.kherbouche@6wind.com>
---
 include/linux/mpls.h | 3 +++
 net/mpls/af_mpls.c   | 5 +++--
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/linux/mpls.h b/include/linux/mpls.h
index 384fb22..d5c7599 100644
--- a/include/linux/mpls.h
+++ b/include/linux/mpls.h
@@ -2,10 +2,13 @@
 #define _LINUX_MPLS_H
 
 #include <uapi/linux/mpls.h>
+#include <linux/netdevice.h>
 
 #define MPLS_TTL_MASK		(MPLS_LS_TTL_MASK >> MPLS_LS_TTL_SHIFT)
 #define MPLS_BOS_MASK		(MPLS_LS_S_MASK >> MPLS_LS_S_SHIFT)
 #define MPLS_TC_MASK		(MPLS_LS_TC_MASK >> MPLS_LS_TC_SHIFT)
 #define MPLS_LABEL_MASK		(MPLS_LS_LABEL_MASK >> MPLS_LS_LABEL_SHIFT)
 
+int mpls_forward(struct sk_buff *skb, struct net_device *dev,
+		 struct packet_type *pt, struct net_device *orig_dev);
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
