From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 19/28] bonding: set inactive flags on release
Date: Wed,  2 Dec 2015 21:07:42 +0100
Message-ID: <1449086871-19911-20-git-send-email-jiri@resnulli.us>
References: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:37552 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755327AbbLBUIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 15:08:19 -0500
Received: by wmww144 with SMTP id w144so72468533wmw.0
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 12:08:18 -0800 (PST)
In-Reply-To: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
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
