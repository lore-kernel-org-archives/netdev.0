From: Milos Vyletel <milos.vyletel@sde.cz>
Subject: [PATCH] bonding: unset primary slave via sysfs
Date: Mon, 28 Jan 2013 12:20:52 -0500
Message-ID: <1359393652-2804-1-git-send-email-milos.vyletel@sde.cz>
Cc: fubar@us.ibm.com, andy@greyhouse.net,
	Milos Vyletel <milos.vyletel@sde.cz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.sde.cz ([85.93.125.197]:44972 "EHLO sde.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756247Ab3A1RVP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 12:21:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When bonding module is loaded with primary parameter and one decides to unset
primary slave using sysfs these settings are not preserved during bond device
restart. Primary slave is only unset once and it's not remembered in
bond->params structure.

Signed-off-by: Milos Vyletel <milos.vyletel@sde.cz>
---
 drivers/net/bonding/bond_sysfs.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index ef8d2a0..155f3b4 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1067,6 +1067,7 @@ static ssize_t bonding_store_primary(struct device *d,
 		pr_info("%s: Setting primary slave to None.\n",
 			bond->dev->name);
 		bond->primary_slave = NULL;
+		memset(bond->params.primary, 0, sizeof(bond->params.primary));
 		bond_select_active_slave(bond);
 		goto out;
 	}
-- 
1.7.1
