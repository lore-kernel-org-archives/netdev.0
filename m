From: Weiping Pan <wpan@redhat.com>
Subject: [PATCH net 1/3] bonding:record primary when modify it via sysfs
Date: Mon, 11 Jun 2012 17:00:20 +0800
Message-ID: <84a4e0e6bbdc9206baefb1454324f4759a98b80e.1339404887.git.wpan@redhat.com>
References: <cover.1339404887.git.wpan@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6204 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752272Ab2FKIzs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 04:55:48 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q5B8tl6j010159
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 04:55:47 -0400
Received: from localhost.localdomain.com (dhcp-16-141.nay.redhat.com [10.66.16.141] (may be forged))
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q5B8thXQ012130
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 04:55:46 -0400
In-Reply-To: <cover.1339404887.git.wpan@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we modify primary via sysfs and it is not a valid slave,
we should record it for future use, and this behavior is the same with
bond_check_params().

Signed-off-by: Weiping Pan <wpan@redhat.com>
---
 drivers/net/bonding/bond_sysfs.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index aef42f0..485bedb 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1082,8 +1082,12 @@ static ssize_t bonding_store_primary(struct device *d,
 		}
 	}
 
-	pr_info("%s: Unable to set %.*s as primary slave.\n",
-		bond->dev->name, (int)strlen(buf) - 1, buf);
+	strncpy(bond->params.primary, ifname, IFNAMSIZ);
+	bond->params.primary[IFNAMSIZ - 1] = 0;
+
+	pr_info("%s: Recording %s as primary, "
+		"but it has not been enslaved to %s yet.\n",
+		bond->dev->name, ifname, bond->dev->name);
 out:
 	write_unlock_bh(&bond->curr_slave_lock);
 	read_unlock(&bond->lock);
-- 
1.7.4
