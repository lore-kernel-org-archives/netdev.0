From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/10] ixgbe: convert to use simple_open()
Date: Wed, 21 Nov 2012 02:47:28 -0800
Message-ID: <1353494856-12344-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1353494856-12344-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:6953 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753385Ab2KUKrl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2012 05:47:41 -0500
In-Reply-To: <1353494856-12344-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

This removes an open coded simple_open() function and
replaces file operations references to the function
with simple_open() instead.

dpatch engine is used to auto generate this patch.
(https://github.com/weiyj/dpatch)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c | 32 ++----------------------
 1 file changed, 2 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
index 8d3a218..efaf9a7 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
@@ -37,20 +37,6 @@ static struct dentry *ixgbe_dbg_root;
 static char ixgbe_dbg_reg_ops_buf[256] = "";
 
 /**
- * ixgbe_dbg_reg_ops_open - prep the debugfs pokee data item when opened
- * @inode: inode that was opened
- * @filp:  file info
- *
- * Stash the adapter pointer hiding in the inode into the file pointer where
- * we can find it later in the read and write calls
- **/
-static int ixgbe_dbg_reg_ops_open(struct inode *inode, struct file *filp)
-{
-	filp->private_data = inode->i_private;
-	return 0;
-}
-
-/**
  * ixgbe_dbg_reg_ops_read - read for reg_ops datum
  * @filp: the opened file
  * @buffer: where to write the data for the user to read
@@ -142,7 +128,7 @@ static ssize_t ixgbe_dbg_reg_ops_write(struct file *filp,
 
 static const struct file_operations ixgbe_dbg_reg_ops_fops = {
 	.owner = THIS_MODULE,
-	.open =  ixgbe_dbg_reg_ops_open,
+	.open = simple_open,
 	.read =  ixgbe_dbg_reg_ops_read,
 	.write = ixgbe_dbg_reg_ops_write,
 };
@@ -150,20 +136,6 @@ static const struct file_operations ixgbe_dbg_reg_ops_fops = {
 static char ixgbe_dbg_netdev_ops_buf[256] = "";
 
 /**
- * ixgbe_dbg_netdev_ops_open - prep the debugfs netdev_ops data item
- * @inode: inode that was opened
- * @filp: file info
- *
- * Stash the adapter pointer hiding in the inode into the file pointer
- * where we can find it later in the read and write calls
- **/
-static int ixgbe_dbg_netdev_ops_open(struct inode *inode, struct file *filp)
-{
-	filp->private_data = inode->i_private;
-	return 0;
-}
-
-/**
  * ixgbe_dbg_netdev_ops_read - read for netdev_ops datum
  * @filp: the opened file
  * @buffer: where to write the data for the user to read
@@ -238,7 +210,7 @@ static ssize_t ixgbe_dbg_netdev_ops_write(struct file *filp,
 
 static const struct file_operations ixgbe_dbg_netdev_ops_fops = {
 	.owner = THIS_MODULE,
-	.open = ixgbe_dbg_netdev_ops_open,
+	.open = simple_open,
 	.read = ixgbe_dbg_netdev_ops_read,
 	.write = ixgbe_dbg_netdev_ops_write,
 };
-- 
1.7.11.7
