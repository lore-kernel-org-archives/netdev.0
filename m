From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 netdev-2.6 4/6] delay may be too small
Date: Sat, 21 Feb 2004 23:25:39 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0402212315490.1228-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* msec_delay macro wouldn't delay at all if x < 10, and 
  wouldn't delay enough for x = 10.  Not a concern for
  2.6 (HZ=1000) but is for 2.4 (HZ=100).

----------

diff -Naurp netdev-2.6/drivers/net/e1000/e1000_osdep.h netdev-2.6/drivers/net/e1000.mod/e1000_osdep.h
--- netdev-2.6/drivers/net/e1000/e1000_osdep.h	2004-02-20 14:07:27.000000000 -0800
+++ netdev-2.6/drivers/net/e1000.mod/e1000_osdep.h	2004-02-20 14:07:56.000000000 -0800
@@ -47,7 +47,7 @@
 	                	BUG(); \
 			} else { \
 				set_current_state(TASK_UNINTERRUPTIBLE); \
-				schedule_timeout((x * HZ)/1000); \
+				schedule_timeout((x * HZ)/1000 + 2); \
 			} } while(0)
 #endif
 
