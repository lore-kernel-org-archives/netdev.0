From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 19/28] bonding: set inactive flags on release
Date: Thu,  3 Dec 2015 12:12:21 +0100
Message-ID: <1449141150-8172-20-git-send-email-jiri@resnulli.us>
References: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:34287 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760102AbbLCLNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 06:13:01 -0500
Received: by wmvv187 with SMTP id v187so21663085wmv.1
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 03:13:00 -0800 (PST)
In-Reply-To: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
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
index 2f11450..5a7de43 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1832,6 +1832,8 @@ static int __bond_release_one(struct net_device *bond_dev,
 		return -EINVAL;
 	}
 
+	bond_set_slave_inactive_flags(slave, BOND_SLAVE_NOTIFY_NOW);
+
 	bond_sysfs_slave_del(slave);
 
 	/* recompute stats just before removing the slave */
-- 
1.9.3
