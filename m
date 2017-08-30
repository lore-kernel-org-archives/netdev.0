From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/8] devlink: Add IPv6 header for dpipe
Date: Wed, 30 Aug 2017 14:02:59 +0200
Message-ID: <20170830120306.6128-2-jiri@resnulli.us>
References: <20170830120306.6128-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33200 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751375AbdH3MDL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 08:03:11 -0400
Received: by mail-wm0-f67.google.com with SMTP id m85so1057931wma.0
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 05:03:11 -0700 (PDT)
In-Reply-To: <20170830120306.6128-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

This will be used by the IPv6 host table which will be introduced in the
following patches. The fields in the header are added per-use. This header
is global and can be reused by many drivers.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/devlink.h        |  1 +
 include/uapi/linux/devlink.h |  5 +++++
 net/core/devlink.c           | 17 +++++++++++++++++
 3 files changed, 23 insertions(+)

diff --git a/include/net/devlink.h b/include/net/devlink.h
index aaf7178..b9654e1 100644
--- a/include/net/devlink.h
+++ b/include/net/devlink.h
@@ -330,6 +330,7 @@ int devlink_dpipe_match_put(struct sk_buff *skb,
 			    struct devlink_dpipe_match *match);
 extern struct devlink_dpipe_header devlink_dpipe_header_ethernet;
 extern struct devlink_dpipe_header devlink_dpipe_header_ipv4;
+extern struct devlink_dpipe_header devlink_dpipe_header_ipv6;
 
 #else
 
diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index 6c17254..0cbca96 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -234,9 +234,14 @@ enum devlink_dpipe_field_ipv4_id {
 	DEVLINK_DPIPE_FIELD_IPV4_DST_IP,
 };
 
+enum devlink_dpipe_field_ipv6_id {
+	DEVLINK_DPIPE_FIELD_IPV6_DST_IP,
+};
+
 enum devlink_dpipe_header_id {
 	DEVLINK_DPIPE_HEADER_ETHERNET,
 	DEVLINK_DPIPE_HEADER_IPV4,
+	DEVLINK_DPIPE_HEADER_IPV6,
 };
 
 #endif /* _UAPI_LINUX_DEVLINK_H_ */
diff --git a/net/core/devlink.c b/net/core/devlink.c
index 194708a..47931a2 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -63,6 +63,23 @@ struct devlink_dpipe_header devlink_dpipe_header_ipv4 = {
 };
 EXPORT_SYMBOL(devlink_dpipe_header_ipv4);
 
+static struct devlink_dpipe_field devlink_dpipe_fields_ipv6[] = {
+	{
+		.name = "destination ip",
+		.id = DEVLINK_DPIPE_FIELD_IPV6_DST_IP,
+		.bitwidth = 128,
+	},
+};
+
+struct devlink_dpipe_header devlink_dpipe_header_ipv6 = {
+	.name = "ipv6",
+	.id = DEVLINK_DPIPE_HEADER_IPV6,
+	.fields = devlink_dpipe_fields_ipv6,
+	.fields_count = ARRAY_SIZE(devlink_dpipe_fields_ipv6),
+	.global = true,
+};
+EXPORT_SYMBOL(devlink_dpipe_header_ipv6);
+
 EXPORT_TRACEPOINT_SYMBOL_GPL(devlink_hwmsg);
 
 static LIST_HEAD(devlink_list);
-- 
2.9.3
