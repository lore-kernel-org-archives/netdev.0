From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 01/12] devlink: Add Ethernet header for dpipe
Date: Thu, 24 Aug 2017 08:39:59 +0200
Message-ID: <20170824064010.1646-2-jiri@resnulli.us>
References: <20170824064010.1646-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:37205 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751353AbdHXGkQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 02:40:16 -0400
Received: by mail-wm0-f65.google.com with SMTP id v186so1689170wmf.4
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 23:40:16 -0700 (PDT)
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
 include/uapi/linux/devlink.h |  8 ++++++++
 net/core/devlink.c           | 17 +++++++++++++++++
 3 files changed, 26 insertions(+)

diff --git a/include/net/devlink.h b/include/net/devlink.h
index ed7687b..ddb8b52 100644
--- a/include/net/devlink.h
+++ b/include/net/devlink.h
@@ -328,6 +328,7 @@ int devlink_dpipe_action_put(struct sk_buff *skb,
 			     struct devlink_dpipe_action *action);
 int devlink_dpipe_match_put(struct sk_buff *skb,
 			    struct devlink_dpipe_match *match);
+extern struct devlink_dpipe_header devlink_dpipe_header_ethernet;
 
 #else
 
diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index b0e807a..a855f8d 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -226,4 +226,12 @@ enum devlink_dpipe_action_type {
 	DEVLINK_DPIPE_ACTION_TYPE_FIELD_MODIFY,
 };
 
+enum devlink_dpipe_field_ethernet_id {
+	DEVLINK_DPIPE_FIELD_ETHERNET_DST_MAC,
+};
+
+enum devlink_dpipe_header_id {
+	DEVLINK_DPIPE_HEADER_ETHERNET,
+};
+
 #endif /* _UAPI_LINUX_DEVLINK_H_ */
diff --git a/net/core/devlink.c b/net/core/devlink.c
index a0adfc3..4f6f3d6 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -29,6 +29,23 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/devlink.h>
 
+static struct devlink_dpipe_field devlink_dpipe_fields_ethernet[] = {
+	{
+		.name = "destination_mac",
+		.id = DEVLINK_DPIPE_FIELD_ETHERNET_DST_MAC,
+		.bitwidth = 48,
+	},
+};
+
+struct devlink_dpipe_header devlink_dpipe_header_ethernet = {
+	.name = "ethernet",
+	.id = DEVLINK_DPIPE_HEADER_ETHERNET,
+	.fields = devlink_dpipe_fields_ethernet,
+	.fields_count = ARRAY_SIZE(devlink_dpipe_fields_ethernet),
+	.global = true,
+};
+EXPORT_SYMBOL(devlink_dpipe_header_ethernet);
+
 EXPORT_TRACEPOINT_SYMBOL_GPL(devlink_hwmsg);
 
 static LIST_HEAD(devlink_list);
-- 
2.9.3
