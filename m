From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/6] devlink: remove implicit type set in port register
Date: Fri,  8 Apr 2016 19:11:20 +0200
Message-ID: <1460135485-16095-2-git-send-email-jiri@resnulli.us>
References: <1460135485-16095-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33520 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758570AbcDHRLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 13:11:30 -0400
Received: by mail-wm0-f65.google.com with SMTP id y144so5799977wmd.0
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 10:11:29 -0700 (PDT)
In-Reply-To: <1460135485-16095-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

As we rely on caller zeroing or correctly set the struct before the call,
this implicit type set is either no-op (DEVLINK_PORT_TYPE_NOTSET is 0)
or it rewrites wanted value. So remove this.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/core/devlink.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/devlink.c b/net/core/devlink.c
index 590fa56..44f880d 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -630,7 +630,6 @@ int devlink_port_register(struct devlink *devlink,
 	}
 	devlink_port->devlink = devlink;
 	devlink_port->index = port_index;
-	devlink_port->type = DEVLINK_PORT_TYPE_NOTSET;
 	devlink_port->registered = true;
 	list_add_tail(&devlink_port->list, &devlink->port_list);
 	mutex_unlock(&devlink_port_mutex);
-- 
2.5.5
