From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 17/26] bonding: set inactive flags on release
Date: Tue,  1 Dec 2015 14:48:55 +0100
Message-ID: <1448977744-17930-18-git-send-email-jiri@resnulli.us>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:37803 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756244AbbLANt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 08:49:29 -0500
Received: by wmww144 with SMTP id w144so14077984wmw.0
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 05:49:28 -0800 (PST)
In-Reply-To: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Be correct and symmetric to enslave and set inactive flags during release.
That gives LAG offload drivers - lower state change listeners - possibility
to do proper cleanup.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/bonding/bond_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e153a87..ec66f3e 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1830,6 +1830,8 @@ static int __bond_release_one(struct net_device *bond_dev,
 		return -EINVAL;
 	}
 
+	bond_set_slave_inactive_flags(slave, BOND_SLAVE_NOTIFY_NOW);
+
 	bond_sysfs_slave_del(slave);
 
 	/* recompute stats just before removing the slave */
-- 
1.9.3
