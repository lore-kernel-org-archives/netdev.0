From: sainath.grandhi@intel.com
Subject: [PATCH RFC v1 1/3] net: Adding API to parse IFLA_LINKINFO attribute
Date: Wed,  6 Sep 2017 17:34:25 -0700
Message-ID: <1504744467-79590-2-git-send-email-sainath.grandhi@intel.com>
References: <1504744467-79590-1-git-send-email-sainath.grandhi@intel.com>
Cc: davem@davemloft.net, Sainath Grandhi <sainath.grandhi@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:52065 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751985AbdIGAhz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 20:37:55 -0400
In-Reply-To: <1504744467-79590-1-git-send-email-sainath.grandhi@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sainath Grandhi <sainath.grandhi@intel.com>

Adding rtnl_nla_parse_ifla_info as an exported symbol in rtnetlink.c helps
other modules to parse IFLA_LINKINFO attribute

Signed-off-by: Sainath Grandhi <sainath.grandhi@intel.com>
---
 include/net/rtnetlink.h | 3 +++
 net/core/rtnetlink.c    | 8 ++++++++
 2 files changed, 11 insertions(+)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 21837ca..cb15ddb 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -170,6 +170,9 @@ int rtnl_configure_link(struct net_device *dev, const struct ifinfomsg *ifm);
 int rtnl_nla_parse_ifla(struct nlattr **tb, const struct nlattr *head, int len,
 			struct netlink_ext_ack *exterr);
 
+int rtnl_nla_parse_ifla_info(struct nlattr **tb, const struct nlattr *head,
+			     int len, struct netlink_ext_ack *exterr);
+
 #define MODULE_ALIAS_RTNL_LINK(kind) MODULE_ALIAS("rtnl-link-" kind)
 
 #endif
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a78fd61..0784b7d 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1688,6 +1688,14 @@ int rtnl_nla_parse_ifla(struct nlattr **tb, const struct nlattr *head, int len,
 }
 EXPORT_SYMBOL(rtnl_nla_parse_ifla);
 
+int rtnl_nla_parse_ifla_info(struct nlattr **tb, const struct nlattr *head,
+			     int len, struct netlink_ext_ack *exterr)
+{
+	return nla_parse(tb, IFLA_INFO_MAX, head, len, ifla_info_policy,
+			 exterr);
+}
+EXPORT_SYMBOL(rtnl_nla_parse_ifla_info);
+
 struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[])
 {
 	struct net *net;
-- 
2.7.4
