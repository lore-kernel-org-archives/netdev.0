From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/4] devlink: fix the name of eswitch commands
Date: Thu,  9 Feb 2017 15:54:33 +0100
Message-ID: <1486652076-20756-2-git-send-email-jiri@resnulli.us>
References: <1486652076-20756-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, ogerlitz@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33973 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752248AbdBIO41 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:56:27 -0500
Received: by mail-wm0-f68.google.com with SMTP id c85so3266643wmi.1
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 06:54:40 -0800 (PST)
In-Reply-To: <1486652076-20756-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The eswitch_[gs]et command is supposed to be similar to port_[gs]et
command - for multiple eswitch attributes. However, when it was introduced
by 08f4b5918b2d ("net/devlink: Add E-Switch mode control") it was wrongly
named with the word "mode" in it. So fix this now, make the oririnal
enum value existing but obsolete.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/uapi/linux/devlink.h | 10 ++++++++--
 net/core/devlink.c           | 18 +++++++++---------
 2 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index 9014c33..0f1f3a1 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -57,8 +57,14 @@ enum devlink_command {
 	DEVLINK_CMD_SB_OCC_SNAPSHOT,
 	DEVLINK_CMD_SB_OCC_MAX_CLEAR,
 
-	DEVLINK_CMD_ESWITCH_MODE_GET,
-	DEVLINK_CMD_ESWITCH_MODE_SET,
+	DEVLINK_CMD_ESWITCH_GET,
+#define DEVLINK_CMD_ESWITCH_MODE_GET /* obsolete, never use this! */ \
+	DEVLINK_CMD_ESWITCH_GET
+
+	DEVLINK_CMD_ESWITCH_SET,
+#define DEVLINK_CMD_ESWITCH_MODE_SET /* obsolete, never use this! */ \
+	DEVLINK_CMD_ESWITCH_SET
+
 	/* add new commands above here */
 
 	__DEVLINK_CMD_MAX,
diff --git a/net/core/devlink.c b/net/core/devlink.c
index 2b5bf9e..7aa8e53 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -1435,8 +1435,8 @@ static int devlink_eswitch_fill(struct sk_buff *msg, struct devlink *devlink,
 	return err;
 }
 
-static int devlink_nl_cmd_eswitch_mode_get_doit(struct sk_buff *skb,
-						struct genl_info *info)
+static int devlink_nl_cmd_eswitch_get_doit(struct sk_buff *skb,
+					   struct genl_info *info)
 {
 	struct devlink *devlink = info->user_ptr[0];
 	const struct devlink_ops *ops = devlink->ops;
@@ -1450,7 +1450,7 @@ static int devlink_nl_cmd_eswitch_mode_get_doit(struct sk_buff *skb,
 	if (!msg)
 		return -ENOMEM;
 
-	err = devlink_eswitch_fill(msg, devlink, DEVLINK_CMD_ESWITCH_MODE_GET,
+	err = devlink_eswitch_fill(msg, devlink, DEVLINK_CMD_ESWITCH_GET,
 				   info->snd_portid, info->snd_seq, 0);
 
 	if (err) {
@@ -1461,8 +1461,8 @@ static int devlink_nl_cmd_eswitch_mode_get_doit(struct sk_buff *skb,
 	return genlmsg_reply(msg, info);
 }
 
-static int devlink_nl_cmd_eswitch_mode_set_doit(struct sk_buff *skb,
-						struct genl_info *info)
+static int devlink_nl_cmd_eswitch_set_doit(struct sk_buff *skb,
+					   struct genl_info *info)
 {
 	struct devlink *devlink = info->user_ptr[0];
 	const struct devlink_ops *ops = devlink->ops;
@@ -1629,15 +1629,15 @@ static const struct genl_ops devlink_nl_ops[] = {
 				  DEVLINK_NL_FLAG_LOCK_PORTS,
 	},
 	{
-		.cmd = DEVLINK_CMD_ESWITCH_MODE_GET,
-		.doit = devlink_nl_cmd_eswitch_mode_get_doit,
+		.cmd = DEVLINK_CMD_ESWITCH_GET,
+		.doit = devlink_nl_cmd_eswitch_get_doit,
 		.policy = devlink_nl_policy,
 		.flags = GENL_ADMIN_PERM,
 		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
 	},
 	{
-		.cmd = DEVLINK_CMD_ESWITCH_MODE_SET,
-		.doit = devlink_nl_cmd_eswitch_mode_set_doit,
+		.cmd = DEVLINK_CMD_ESWITCH_SET,
+		.doit = devlink_nl_cmd_eswitch_set_doit,
 		.policy = devlink_nl_policy,
 		.flags = GENL_ADMIN_PERM,
 		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
-- 
2.7.4
