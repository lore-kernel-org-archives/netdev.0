From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH 8/17 linux-2.6.7-rc2] prism54: Fix bugs 74/75 (resend)
Date: Sat, 5 Jun 2004 14:49:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406051449.10281.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_GFcwAqf0vwOMgYR"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_GFcwAqf0vwOMgYR
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-03-22      Aurelien Alleaume <slts@free.fr>

        * oid_mgt.c, isl_ioctl.c : Minor bugfixes : #74 and #75.



--Boundary-00=_GFcwAqf0vwOMgYR
Content-Type: text/x-diff;
  charset="us-ascii";
  name="08-fix-bug-74-75.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="08-fix-bug-74-75.patch"

diff -NaurEb linux-2.6.6ct/drivers/net/wireless/prism54/isl_ioctl.c linux-2.6.6-01/drivers/net/wireless/prism54/isl_ioctl.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/isl_ioctl.c	2004-05-28 14:40:26.990455656 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/isl_ioctl.c	2004-05-28 14:43:00.926053888 +0200
@@ -1893,6 +1893,7 @@
 	struct net_device *ndev = frame->ndev;
 	enum oid_num_t n = mgt_oidtonum(frame->header->oid);
 
+	if (n != OID_NUM_LAST)
 	prism54_process_trap_helper(netdev_priv(ndev), n, frame->data);
 	islpci_mgt_release(frame);
 }
diff -NaurEb linux-2.6.6ct/drivers/net/wireless/prism54/oid_mgt.c linux-2.6.6-01/drivers/net/wireless/prism54/oid_mgt.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/oid_mgt.c	2004-05-28 14:40:27.001453984 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/oid_mgt.c	2004-05-28 14:43:00.929053432 +0200
@@ -688,13 +688,13 @@
 {
 	int i;
 
-	for (i = 0; i < OID_NUM_LAST - 1; i++)
+	for (i = 0; i < OID_NUM_LAST; i++)
 		if (isl_oid[i].oid == oid)
 			return i;
 
 	printk(KERN_DEBUG "looking for an unknown oid 0x%x", oid);
 
-	return 0;
+	return OID_NUM_LAST;
 }
 
 int

--Boundary-00=_GFcwAqf0vwOMgYR--
