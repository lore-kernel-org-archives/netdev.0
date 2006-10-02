From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] fix bcm43xx-d80211 for inode diet
Date: Mon, 02 Oct 2006 13:14:47 +0200
Message-ID: <1159787687.2655.53.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Michael Buesch <mb@bu3sch.de>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:35750 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750823AbWJBLN7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 07:13:59 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch propagates the inode diet changes to bcm43xx-d80211.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
This patch is required for compiling bcm43xx-d80211 after pulling the
inode diet changes that went into Linus's tree into wireless-dev, since
bcm43xx-d80211 is not in mainline it wasn't fixed up along with the
changes.

I've compiled this but couldn't test because the kernel currently
doesn't boot on my powerbook, it hangs very early.

--- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c	2006-10-01 11:30:18.040555764 +0200
+++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c	2006-10-01 11:50:01.780555764 +0200
@@ -54,7 +54,7 @@ static ssize_t write_file_dummy(struct f
 
 static int open_file_generic(struct inode *inode, struct file *file)
 {
-	file->private_data = inode->u.generic_ip;
+	file->private_data = inode->i_private;
 	return 0;
 }
 

