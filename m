From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next v10 02/11] ipv6: move ip6_local_out into core kernel
Date: Wed, 28 Aug 2013 13:22:50 +0800
Message-ID: <1377667379-2315-3-git-send-email-amwang@redhat.com>
References: <1377667379-2315-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59690 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753253Ab3H1FXc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 01:23:32 -0400
In-Reply-To: <1377667379-2315-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

It will be used the vxlan kernel module.

Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/ipv6/ip6_output.c  |   25 -------------------------
 net/ipv6/output_core.c |   26 ++++++++++++++++++++++++++
 2 files changed, 26 insertions(+), 25 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 6e3ddf8..dd08cfd 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -56,31 +56,6 @@
 #include <net/checksum.h>
 #include <linux/mroute6.h>
 
-int __ip6_local_out(struct sk_buff *skb)
-{
-	int len;
-
-	len = skb->len - sizeof(struct ipv6hdr);
-	if (len > IPV6_MAXPLEN)
-		len = 0;
-	ipv6_hdr(skb)->payload_len = htons(len);
-
-	return nf_hook(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL,
-		       skb_dst(skb)->dev, dst_output);
-}
-
-int ip6_local_out(struct sk_buff *skb)
-{
-	int err;
-
-	err = __ip6_local_out(skb);
-	if (likely(err == 1))
-		err = dst_output(skb);
-
-	return err;
-}
-EXPORT_SYMBOL_GPL(ip6_local_out);
-
 static int ip6_finish_output2(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index ab92a36..c1c741e 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -75,3 +75,29 @@ int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
 	return offset;
 }
 EXPORT_SYMBOL(ip6_find_1stfragopt);
+
+int __ip6_local_out(struct sk_buff *skb)
+{
+	int len;
+
+	len = skb->len - sizeof(struct ipv6hdr);
+	if (len > IPV6_MAXPLEN)
+		len = 0;
+	ipv6_hdr(skb)->payload_len = htons(len);
+
+	return nf_hook(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL,
+		       skb_dst(skb)->dev, dst_output);
+}
+EXPORT_SYMBOL_GPL(__ip6_local_out);
+
+int ip6_local_out(struct sk_buff *skb)
+{
+	int err;
+
+	err = __ip6_local_out(skb);
+	if (likely(err == 1))
+		err = dst_output(skb);
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(ip6_local_out);
-- 
1.7.7.6
