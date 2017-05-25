From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 6/6] net: mpls: minor cleanups
Date: Wed, 24 May 2017 21:54:42 -0600
Message-ID: <20170525035442.51407-7-dsahern@gmail.com>
References: <20170525035442.51407-1-dsahern@gmail.com>
Cc: roopa@cumulusnetworks.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35081 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941600AbdEYDy5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 23:54:57 -0400
Received: by mail-pf0-f194.google.com with SMTP id u26so36373917pfd.2
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 20:54:57 -0700 (PDT)
In-Reply-To: <20170525035442.51407-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noticed these doing the extack support:
- nla_get_via is only used in af_mpls.c so remove from internal.h

- err is initialized to EINVAL in mpls_nh_build_from_cfg but then
  set again before it is checked. Remove the EINVAL setting

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/mpls/af_mpls.c  | 5 +++--
 net/mpls/internal.h | 2 --
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index d0120f8c8a2c..ee468feb9e64 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -43,6 +43,9 @@ static void rtmsg_lfib(int event, u32 label, struct mpls_route *rt,
 		       struct nlmsghdr *nlh, struct net *net, u32 portid,
 		       unsigned int nlm_flags);
 
+static int nla_get_via(const struct nlattr *nla, u8 *via_alen, u8 *via_table,
+		       u8 via[], struct netlink_ext_ack *extack);
+
 static struct mpls_route *mpls_route_input_rcu(struct net *net, unsigned index)
 {
 	struct mpls_route *rt = NULL;
@@ -695,8 +698,6 @@ static int mpls_nh_build_from_cfg(struct mpls_route_config *cfg,
 	if (!nh)
 		return -ENOMEM;
 
-	err = -EINVAL;
-
 	nh->nh_labels = cfg->rc_output_labels;
 	for (i = 0; i < nh->nh_labels; i++)
 		nh->nh_label[i] = cfg->rc_output_label[i];
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index a015a6a1143b..cf65aec2e551 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -204,8 +204,6 @@ int nla_put_labels(struct sk_buff *skb, int attrtype,  u8 labels,
 		   const u32 label[]);
 int nla_get_labels(const struct nlattr *nla, u8 max_labels, u8 *labels,
 		   u32 label[], struct netlink_ext_ack *extack);
-int nla_get_via(const struct nlattr *nla, u8 *via_alen, u8 *via_table,
-		u8 via[], struct netlink_ext_ack *extack);
 bool mpls_output_possible(const struct net_device *dev);
 unsigned int mpls_dev_mtu(const struct net_device *dev);
 bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu);
-- 
2.11.0 (Apple Git-81)
