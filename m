From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 1/2] add rtnl_lock_interruptible()
Date: Sun, 9 Jan 2005 13:14:07 +0100
Message-ID: <20050109121407.GA19599@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net, jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--- 1.47/include/linux/rtnetlink.h	2004-11-03 23:00:25 +01:00
+++ edited/include/linux/rtnetlink.h	2005-01-09 12:49:58 +01:00
@@ -806,6 +806,7 @@
 		        } while(0)
 
 extern void rtnl_lock(void);
+extern int rtnl_lock_interruptible(void);
 extern void rtnl_unlock(void);
 extern void rtnetlink_init(void);
 
--- 1.30/net/core/rtnetlink.c	2004-12-01 07:04:20 +01:00
+++ edited/net/core/rtnetlink.c	2005-01-09 12:53:33 +01:00
@@ -57,6 +57,11 @@
 {
 	rtnl_shlock();
 }
+
+int rtnl_lock_interruptible(void)
+{
+	return down_interruptible(&rtnl_sem);
+}
  
 void rtnl_unlock(void)
 {
@@ -696,5 +701,6 @@
 EXPORT_SYMBOL(rtnetlink_put_metrics);
 EXPORT_SYMBOL(rtnl);
 EXPORT_SYMBOL(rtnl_lock);
+EXPORT_SYMBOL(rtnl_lock_interruptible);
 EXPORT_SYMBOL(rtnl_sem);
 EXPORT_SYMBOL(rtnl_unlock);
