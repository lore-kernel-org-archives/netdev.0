From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] switchdev: fix return value of switchdev_port_fdb_dump in case of error
Date: Thu,  3 Sep 2015 14:04:17 +0200
Message-ID: <1441281857-613-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sridhar.samudrala@intel.com, sfeldma@gmail.com,
	Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:36096 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754003AbbICMEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 08:04:20 -0400
Received: by wibz8 with SMTP id z8so96419461wib.1
        for <netdev@vger.kernel.org>; Thu, 03 Sep 2015 05:04:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

switchdev_port_fdb_dump is used as .ndo_fdb_dump. Its return value is
idx, so we cannot return errval.

Fixes: 45d4122ca7cd ("switchdev: add support for fdb add/del/dump via switchdev_port_obj ops.")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/switchdev/switchdev.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 16c1c43..fda38f8 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -853,12 +853,8 @@ int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 		.cb = cb,
 		.idx = idx,
 	};
-	int err;
-
-	err = switchdev_port_obj_dump(dev, &dump.obj);
-	if (err)
-		return err;
 
+	switchdev_port_obj_dump(dev, &dump.obj);
 	return dump.idx;
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_dump);
-- 
1.9.3
