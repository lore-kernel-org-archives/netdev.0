From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] devlink: Prevent port_type_set() callback when it's not needed
Date: Sun, 23 Oct 2016 17:43:05 +0200
Message-ID: <1477237385-1991-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34353 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753174AbcJWPnJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2016 11:43:09 -0400
Received: by mail-wm0-f67.google.com with SMTP id d199so6180527wmd.1
        for <netdev@vger.kernel.org>; Sun, 23 Oct 2016 08:43:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

When a port_type_set() is been called and the new port type set is the same
as the old one, just return success.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/core/devlink.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/devlink.c b/net/core/devlink.c
index 1b50630..d2fd736 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -608,6 +608,8 @@ static int devlink_port_type_set(struct devlink *devlink,
 	if (devlink->ops && devlink->ops->port_type_set) {
 		if (port_type == DEVLINK_PORT_TYPE_NOTSET)
 			return -EINVAL;
+		if (port_type == devlink_port->type)
+			return 0;
 		err = devlink->ops->port_type_set(devlink_port, port_type);
 		if (err)
 			return err;
-- 
2.5.5
