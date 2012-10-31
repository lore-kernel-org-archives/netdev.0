From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH] bonding: fix off-by-one error
Date: Wed, 31 Oct 2012 15:42:51 +0100
Message-ID: <1351694571-26369-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54273 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422981Ab2JaOpZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2012 10:45:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix off-by-one error because IFNAMSIZ == 16 and when this
code gets executed we stick a NULL byte where we should not.

How to reproduce:
 with CONFIG_CC_STACKPROTECTOR=y (otherwise it may pass by silently)
 modprobe bonding; echo 1 > /sys/class/net/bond0/bonding/mode;
 echo "AAAAAAAAAAAAAAAA" > /sys/class/net/bond0/bonding/primary;

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_sysfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index dc15d24..238d9b3 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1060,7 +1060,7 @@ static ssize_t bonding_store_primary(struct device *d,
 		goto out;
 	}
 
-	sscanf(buf, "%16s", ifname); /* IFNAMSIZ */
+	sscanf(buf, "%15s", ifname); /* IFNAMSIZ */
 
 	/* check to see if we are clearing primary */
 	if (!strlen(ifname) || buf[0] == '\n') {
-- 
1.7.11.4
