From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] Propagate error from sctp_proc_init
Date: Wed, 14 Apr 2004 15:41:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040414134148.GC16591@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="OXfL5xGRrasGEqWY"
Cc: lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

The following patch makes sure that an error in sctp_proc_init()
causes module initialization to fail.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 

--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: attachment; filename=sctp-initfail

--- linux-2.6.4/net/sctp/protocol.c.initfail	2004-02-19 11:36:37.000000000 +0100
+++ linux-2.6.4/net/sctp/protocol.c	2004-04-14 15:36:19.000000000 +0200
@@ -1001,7 +1001,9 @@
 		goto err_init_mibs;
 
 	/* Initialize proc fs directory.  */
-	sctp_proc_init();
+	status = sctp_proc_init();
+	if (status)
+		goto err_init_proc;
 
 	/* Initialize object count debugging.  */
 	sctp_dbg_objcnt_init();
@@ -1165,6 +1167,7 @@
 			     sizeof(struct sctp_hashbucket)));
 err_ahash_alloc:
 	sctp_dbg_objcnt_exit();
+err_init_proc:
 	sctp_proc_exit();
 	cleanup_sctp_mibs();
 err_init_mibs:

--OXfL5xGRrasGEqWY--
