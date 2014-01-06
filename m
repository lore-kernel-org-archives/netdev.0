From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next] bonding: fix kstrtou8() return value verification in num_peer_notif
Date: Mon,  6 Jan 2014 11:54:40 +0100
Message-ID: <1389005680-9063-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>, sfeldma@cumulusnetworks.com,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50303 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752652AbaAFKyC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 05:54:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It returns 0 in case of success, !0 error otherwise. Fix the improper error
verification.

Fixes: 2c9839c143bbc ("bonding: add num_grat_arp attribute netlink support")
CC: sfeldma@cumulusnetworks.com
CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_sysfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 9a1ea4a..011f163 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -776,7 +776,7 @@ static ssize_t bonding_store_num_peer_notif(struct device *d,
 	int ret;
 
 	ret = kstrtou8(buf, 10, &new_value);
-	if (!ret) {
+	if (ret) {
 		pr_err("%s: invalid value %s specified.\n",
 		       bond->dev->name, buf);
 		return ret;
-- 
1.8.4
