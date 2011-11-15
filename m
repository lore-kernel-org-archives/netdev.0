From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH] bonding: Don't allow mode change via sysfs with slaves present
Date: Tue, 15 Nov 2011 17:44:42 +0100
Message-ID: <1321375482-8637-1-git-send-email-vfalico@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54609 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756336Ab1KOQor (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 11:44:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When changing mode via bonding's sysfs, the slaves are not initialized
correctly. Forbid to change modes with slaves present to ensure that every
slave is initialized correctly via bond_enslave().

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_sysfs.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 5a20804..4ef7e2f 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -319,6 +319,13 @@ static ssize_t bonding_store_mode(struct device *d,
 		goto out;
 	}
 
+	if (bond->slave_cnt > 0) {
+		pr_err("unable to update mode of %s because it has slaves.\n",
+			bond->dev->name);
+		ret = -EPERM;
+		goto out;
+	}
+
 	new_value = bond_parse_parm(buf, bond_mode_tbl);
 	if (new_value < 0)  {
 		pr_err("%s: Ignoring invalid mode value %.*s.\n",
-- 
1.7.6.4
