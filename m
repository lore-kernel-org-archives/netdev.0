From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next 2/3] mpls: consistently use u8 to store number of labels
Date: Tue, 11 Aug 2015 14:45:47 -0700
Message-ID: <1439329548-50935-3-git-send-email-roopa@cumulusnetworks.com>
Cc: ebiederm@xmission.com, rshearma@brocade.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:33970 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753564AbbHKVp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 17:45:56 -0400
Received: by pdbfa8 with SMTP id fa8so47578031pdb.1
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 14:45:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

change all types representing number of labels to u8
to be consistent.

This also changes labels to u8 in the light weight
mpls_tunnel_encap structure. This is because the
light weight mpls iptunnel code shares some of the label
encoding functions like nla_get/put_labels with the af_mpls
code.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/net/mpls_iptunnel.h |    2 +-
 net/mpls/af_mpls.c          |   10 +++++-----
 net/mpls/internal.h         |    2 +-
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/mpls_iptunnel.h b/include/net/mpls_iptunnel.h
index 4757997..179253f 100644
--- a/include/net/mpls_iptunnel.h
+++ b/include/net/mpls_iptunnel.h
@@ -18,7 +18,7 @@
 
 struct mpls_iptunnel_encap {
 	u32	label[MAX_NEW_LABELS];
-	u32	labels;
+	u8	labels;
 };
 
 static inline struct mpls_iptunnel_encap *mpls_lwtunnel_encap(struct lwtunnel_state *lwtstate)
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index cf86e9d..eb089ef 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -243,11 +243,11 @@ static const struct nla_policy rtm_mpls_policy[RTA_MAX+1] = {
 struct mpls_route_config {
 	u32			rc_protocol;
 	u32			rc_ifindex;
-	u16			rc_via_table;
-	u16			rc_via_alen;
+	u8			rc_via_table;
+	u8			rc_via_alen;
 	u8			rc_via[MAX_VIA_ALEN];
+	u8			rc_output_labels;
 	u32			rc_label;
-	u32			rc_output_labels;
 	u32			rc_output_label[MAX_NEW_LABELS];
 	u32			rc_nlflags;
 	enum mpls_payload_type	rc_payload_type;
@@ -751,7 +751,7 @@ int nla_put_labels(struct sk_buff *skb, int attrtype,
 EXPORT_SYMBOL_GPL(nla_put_labels);
 
 int nla_get_labels(const struct nlattr *nla,
-		   u32 max_labels, u32 *labels, u32 label[])
+		   u32 max_labels, u8 *labels, u32 label[])
 {
 	unsigned len = nla_len(nla);
 	unsigned nla_labels;
@@ -859,7 +859,7 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 			break;
 		case RTA_DST:
 		{
-			u32 label_count;
+			u8 label_count;
 			if (nla_get_labels(nla, 1, &label_count,
 					   &cfg->rc_label))
 				goto errout;
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index f05e2e8..f5dafcaf 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -87,7 +87,7 @@ static inline struct mpls_entry_decoded mpls_entry_decode(struct mpls_shim_hdr *
 
 int nla_put_labels(struct sk_buff *skb, int attrtype,  u8 labels,
 		   const u32 label[]);
-int nla_get_labels(const struct nlattr *nla, u32 max_labels, u32 *labels,
+int nla_get_labels(const struct nlattr *nla, u32 max_labels, u8 *labels,
 		   u32 label[]);
 bool mpls_output_possible(const struct net_device *dev);
 unsigned int mpls_dev_mtu(const struct net_device *dev);
-- 
1.7.10.4
