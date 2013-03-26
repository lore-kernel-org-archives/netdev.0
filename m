From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH] bonding: remove already created master sysfs link on failure
Date: Tue, 26 Mar 2013 17:43:28 +0100
Message-ID: <1364316208-1068-1-git-send-email-vfalico@redhat.com>
Cc: vfalico@redhat.com, andy@greyhouse.net, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56851 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751252Ab3CZQyr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 12:54:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If slave sysfs symlink failes to be created - we end up without removing
the master sysfs symlink. Remove it in case of failure.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_sysfs.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 1c9e09f..db103e0 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -183,6 +183,11 @@ int bond_create_slave_symlinks(struct net_device *master,
 	sprintf(linkname, "slave_%s", slave->name);
 	ret = sysfs_create_link(&(master->dev.kobj), &(slave->dev.kobj),
 				linkname);
+
+	/* free the master link created earlier in case of error */
+	if (ret)
+		sysfs_remove_link(&(slave->dev.kobj), "master");
+
 	return ret;
 
 }
-- 
1.7.1
