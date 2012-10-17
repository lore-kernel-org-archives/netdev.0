From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] ixgbe: convert to use simple_open()
Date: Wed, 17 Oct 2012 16:26:46 +0800
Message-ID: <CAPgLHd9sFav1MKPCdHNjXM37ZEitiJJYFkH_Kv-8LsSr2t4TYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:33576 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871Ab2JQI0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2012 04:26:47 -0400
Received: by mail-qc0-f174.google.com with SMTP id o22so1861295qcr.19
        for <netdev@vger.kernel.org>; Wed, 17 Oct 2012 01:26:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

This removes an open coded simple_open() function and
replaces file operations references to the function
with simple_open() instead.

dpatch engine is used to auto generate this patch.
(https://github.com/weiyj/dpatch)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
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
