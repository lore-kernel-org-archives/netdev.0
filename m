From: Weiping Pan <wpan@redhat.com>
Subject: [PATCH net 2/3] bonding:check mode when modify primary_reselect
Date: Mon, 11 Jun 2012 17:00:21 +0800
Message-ID: <5cef8fed5c7fbb9e7f18e61a2c9a47b45f87ca0d.1339404887.git.wpan@redhat.com>
References: <cover.1339404887.git.wpan@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48026 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752265Ab2FKIzt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 04:55:49 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q5B8tm2x027376
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 04:55:48 -0400
Received: from localhost.localdomain.com (dhcp-16-141.nay.redhat.com [10.66.16.141] (may be forged))
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q5B8thXR012130
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 04:55:47 -0400
In-Reply-To: <cover.1339404887.git.wpan@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using a primary_reselect only makes sense in active backup, TLB or ALB modes.

Signed-off-by: Weiping Pan <wpan@redhat.com>
---
 drivers/net/bonding/bond_sysfs.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 485bedb..1b0f3cd 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1123,6 +1123,13 @@ static ssize_t bonding_store_primary_reselect(struct device *d,
 	if (!rtnl_trylock())
 		return restart_syscall();
 
+	if (!USES_PRIMARY(bond->params.mode)) {
+		pr_err("%s: Unable to set primary_reselect; %s is in mode %d\n",
+			bond->dev->name, bond->dev->name, bond->params.mode);
+		ret = -EINVAL;
+		goto out;
+	}
+
 	new_value = bond_parse_parm(buf, pri_reselect_tbl);
 	if (new_value < 0)  {
 		pr_err("%s: Ignoring invalid primary_reselect value %.*s.\n",
-- 
1.7.4
