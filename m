From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH] bonding: fix second off-by-one error
Date: Wed, 31 Oct 2012 17:03:52 +0100
Message-ID: <1351699432-27602-1-git-send-email-nikolay@redhat.com>
References: <1351694571-26369-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8222 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935754Ab2JaQGM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2012 12:06:12 -0400
In-Reply-To: <1351694571-26369-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix off-by-one error because IFNAMSIZ == 16 and when this
code gets executed we stick a NULL byte where we should not.

How to reproduce:
 with CONFIG_CC_STACKPROTECTOR=y (otherwise it may pass by silently)
 modprobe bonding; echo 1 > /sys/class/net/bond0/bonding/mode;
 echo "AAAAAAAAAAAAAAAA" > /sys/class/net/bond0/bonding/active_slave;

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Note: Sorry for the second patch but I missed this one while checking
      the file. You can squash them into one patch.
---
 drivers/net/bonding/bond_sysfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 238d9b3..ef8d2a0 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1237,7 +1237,7 @@ static ssize_t bonding_store_active_slave(struct device *d,
 		goto out;
 	}
 
-	sscanf(buf, "%16s", ifname); /* IFNAMSIZ */
+	sscanf(buf, "%15s", ifname); /* IFNAMSIZ */
 
 	/* check to see if we are clearing active */
 	if (!strlen(ifname) || buf[0] == '\n') {
-- 
1.7.11.4
