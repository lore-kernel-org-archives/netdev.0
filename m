From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/5] switchdev: Support parent ID comparison for stacked devices
Date: Thu, 25 Aug 2016 18:42:36 +0200
Message-ID: <1472143360-15796-2-git-send-email-jiri@resnulli.us>
References: <1472143360-15796-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        gospo@cumulusnetworks.com, ast@plumgrid.com, edumazet@google.com,
        f.fainelli@gmail.com, dsa@cumulusnetworks.com,
        daniel@iogearbox.net, vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35843 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757810AbcHYQnx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 12:43:53 -0400
Received: by mail-wm0-f66.google.com with SMTP id i138so8133900wmf.3
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 09:42:44 -0700 (PDT)
In-Reply-To: <1472143360-15796-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

switchdev_port_same_parent_id() currently expects port netdevs, but we
need it to support stacked devices in the next patch, so drop the
NO_RECURSE flag.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/switchdev/switchdev.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 9e90129..2c683f2 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -1292,12 +1292,10 @@ bool switchdev_port_same_parent_id(struct net_device *a,
 	struct switchdev_attr a_attr = {
 		.orig_dev = a,
 		.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
-		.flags = SWITCHDEV_F_NO_RECURSE,
 	};
 	struct switchdev_attr b_attr = {
 		.orig_dev = b,
 		.id = SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
-		.flags = SWITCHDEV_F_NO_RECURSE,
 	};
 
 	if (switchdev_port_attr_get(a, &a_attr) ||
-- 
2.5.5
