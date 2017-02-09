From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/4] devlink: use nla_put_failure goto label instead of out
Date: Thu,  9 Feb 2017 15:54:35 +0100
Message-ID: <1486652076-20756-4-git-send-email-jiri@resnulli.us>
References: <1486652076-20756-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, ogerlitz@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34920 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752320AbdBIO41 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 09:56:27 -0500
Received: by mail-wm0-f65.google.com with SMTP id u63so3250411wmu.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 06:54:42 -0800 (PST)
In-Reply-To: <1486652076-20756-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Be aligned with the rest of the code and use label named nla_put_failure.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/core/devlink.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/core/devlink.c b/net/core/devlink.c
index f361924..7f88cc8 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -1408,29 +1408,29 @@ static int devlink_nl_eswitch_fill(struct sk_buff *msg, struct devlink *devlink,
 
 	err = devlink_nl_put_handle(msg, devlink);
 	if (err)
-		goto out;
+		goto nla_put_failure;
 
 	err = ops->eswitch_mode_get(devlink, &mode);
 	if (err)
-		goto out;
+		goto nla_put_failure;
 	err = nla_put_u16(msg, DEVLINK_ATTR_ESWITCH_MODE, mode);
 	if (err)
-		goto out;
+		goto nla_put_failure;
 
 	if (ops->eswitch_inline_mode_get) {
 		err = ops->eswitch_inline_mode_get(devlink, &inline_mode);
 		if (err)
-			goto out;
+			goto nla_put_failure;
 		err = nla_put_u8(msg, DEVLINK_ATTR_ESWITCH_INLINE_MODE,
 				 inline_mode);
 		if (err)
-			goto out;
+			goto nla_put_failure;
 	}
 
 	genlmsg_end(msg, hdr);
 	return 0;
 
-out:
+nla_put_failure:
 	genlmsg_cancel(msg, hdr);
 	return err;
 }
-- 
2.7.4
