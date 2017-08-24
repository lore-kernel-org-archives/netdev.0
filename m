From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/12] devlink: Add IPv4 header for dpipe
Date: Thu, 24 Aug 2017 08:40:00 +0200
Message-ID: <20170824064010.1646-3-jiri@resnulli.us>
References: <20170824064010.1646-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:37953 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751768AbdHXGkS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 02:40:18 -0400
Received: by mail-wr0-f195.google.com with SMTP id 94so946731wri.5
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 23:40:17 -0700 (PDT)
In-Reply-To: <20170824064010.1646-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

This will be used by the IPv4 host table which will be introduced in the
following patches. This header is global and can be reused by many
drivers.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/devlink.h        |  1 +
 include/uapi/linux/devlink.h |  5 +++++
 net/core/devlink.c           | 17 +++++++++++++++++
 3 files changed, 23 insertions(+)

diff --git a/include/net/devlink.h b/include/net/devlink.h
index ddb8b52..8ff8a6f 100644
--- a/include/net/devlink.h
+++ b/include/net/devlink.h
@@ -329,6 +329,7 @@ int devlink_dpipe_action_put(struct sk_buff *skb,
 int devlink_dpipe_match_put(struct sk_buff *skb,
 			    struct devlink_dpipe_match *match);
 extern struct devlink_dpipe_header devlink_dpipe_header_ethernet;
+extern struct devlink_dpipe_header devlink_dpipe_header_ipv4;
 
 #else
 
diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index a855f8d..6c17254 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -230,8 +230,13 @@ enum devlink_dpipe_field_ethernet_id {
 	DEVLINK_DPIPE_FIELD_ETHERNET_DST_MAC,
 };
 
+enum devlink_dpipe_field_ipv4_id {
+	DEVLINK_DPIPE_FIELD_IPV4_DST_IP,
+};
+
 enum devlink_dpipe_header_id {
 	DEVLINK_DPIPE_HEADER_ETHERNET,
+	DEVLINK_DPIPE_HEADER_IPV4,
 };
 
 #endif /* _UAPI_LINUX_DEVLINK_H_ */
diff --git a/net/core/devlink.c b/net/core/devlink.c
index 4f6f3d6..fcf5dd6 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -46,6 +46,23 @@ struct devlink_dpipe_header devlink_dpipe_header_ethernet = {
 };
 EXPORT_SYMBOL(devlink_dpipe_header_ethernet);
 
+static struct devlink_dpipe_field devlink_dpipe_fields_ipv4[] = {
+	{
+		.name = "destination ip",
+		.id = DEVLINK_DPIPE_FIELD_IPV4_DST_IP,
+		.bitwidth = 32,
+	},
+};
+
+struct devlink_dpipe_header devlink_dpipe_header_ipv4 = {
+	.name = "ipv4",
+	.id = DEVLINK_DPIPE_HEADER_IPV4,
+	.fields = devlink_dpipe_fields_ipv4,
+	.fields_count = ARRAY_SIZE(devlink_dpipe_fields_ipv4),
+	.global = true,
+};
+EXPORT_SYMBOL(devlink_dpipe_header_ipv4);
+
 EXPORT_TRACEPOINT_SYMBOL_GPL(devlink_hwmsg);
 
 static LIST_HEAD(devlink_list);
-- 
2.9.3
