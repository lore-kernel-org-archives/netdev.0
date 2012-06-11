From: Weiping Pan <wpan@redhat.com>
Subject: [PATCH net 3/3] bonding:force to use primary slave
Date: Mon, 11 Jun 2012 17:00:22 +0800
Message-ID: <19a50a970bfa4eab890a39293fa505f90fbfc5e4.1339404887.git.wpan@redhat.com>
References: <cover.1339404887.git.wpan@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16505 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752465Ab2FKIzu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 04:55:50 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q5B8tnMX026599
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 04:55:50 -0400
Received: from localhost.localdomain.com (dhcp-16-141.nay.redhat.com [10.66.16.141] (may be forged))
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q5B8thXS012130
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 04:55:49 -0400
In-Reply-To: <cover.1339404887.git.wpan@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we set primary slave with module parameters, bond will always use this
primary slave as active slave.

But when we modify primary slave via sysfs, it will call
bond_should_change_active() and take into account primary_reselect.

And I think we should use the new primary slave as the new active slave
regardless of the value of primary_reselect.
Thus the behavior is the same with module parameters and meets the
administrator's expectation.

Signed-off-by: Weiping Pan <wpan@redhat.com>
---
 drivers/net/bonding/bond_sysfs.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 1b0f3cd..7256ae4 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1077,6 +1077,7 @@ static ssize_t bonding_store_primary(struct device *d,
 				bond->dev->name, slave->dev->name);
 			bond->primary_slave = slave;
 			strcpy(bond->params.primary, slave->dev->name);
+			bond->force_primary = true;
 			bond_select_active_slave(bond);
 			goto out;
 		}
-- 
1.7.4
