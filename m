From: Jon Mason <jon.mason@intel.com>
Subject: [PATCH 06/21] NTB: use simple_open for debugfs
Date: Sat, 19 Jan 2013 02:02:20 -0700
Message-ID: <1358586155-23322-7-git-send-email-jon.mason@intel.com>
References: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:52702 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751970Ab3ASJDF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Jan 2013 04:03:05 -0500
In-Reply-To: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use simple_open for debugfs instead of recreating it in the NTB driver.
Caught by coccicheck.

Signed-off-by: Jon Mason <jon.mason@intel.com>
---
 drivers/ntb/ntb_transport.c |    8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/ntb/ntb_transport.c b/drivers/ntb/ntb_transport.c
index bf7ade1..c0eca02 100644
--- a/drivers/ntb/ntb_transport.c
+++ b/drivers/ntb/ntb_transport.c
@@ -364,12 +364,6 @@ void ntb_unregister_client(struct ntb_client *drv)
 }
 EXPORT_SYMBOL_GPL(ntb_unregister_client);
 
-static int debugfs_open(struct inode *inode, struct file *filp)
-{
-	filp->private_data = inode->i_private;
-	return 0;
-}
-
 static ssize_t debugfs_read(struct file *filp, char __user *ubuf, size_t count,
 			    loff_t *offp)
 {
@@ -425,7 +419,7 @@ static ssize_t debugfs_read(struct file *filp, char __user *ubuf, size_t count,
 
 static const struct file_operations ntb_qp_debugfs_stats = {
 	.owner = THIS_MODULE,
-	.open = debugfs_open,
+	.open = simple_open,
 	.read = debugfs_read,
 };
 
-- 
1.7.9.5
