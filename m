From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2.4] PKT_SCHED: break is not enough to stop walking
Date: Fri, 29 Oct 2004 02:29:58 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029002958.GF12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

break is not enough to escape from the walking loops, since
multiple encapsulated loops are used to traverse the hash tables.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.4.28-rc1-bk1.orig/net/sched/cls_fw.c	2004-10-29 01:34:19.000000000 +0200
+++ linux-2.4.28-rc1-bk1/net/sched/cls_fw.c	2004-10-29 01:36:19.000000000 +0200
@@ -292,7 +292,7 @@
 			}
 			if (arg->fn(tp, (unsigned long)f, arg) < 0) {
 				arg->stop = 1;
-				break;
+				return;
 			}
 			arg->count++;
 		}
--- linux-2.4.28-rc1-bk1.orig/net/sched/cls_route.c	2004-10-29 01:34:19.000000000 +0200
+++ linux-2.4.28-rc1-bk1/net/sched/cls_route.c	2004-10-29 01:36:31.000000000 +0200
@@ -541,7 +541,7 @@
 					}
 					if (arg->fn(tp, (unsigned long)f, arg) < 0) {
 						arg->stop = 1;
-						break;
+						return;
 					}
 					arg->count++;
 				}
--- linux-2.4.28-rc1-bk1.orig/net/sched/cls_rsvp.h	2004-10-29 01:34:19.000000000 +0200
+++ linux-2.4.28-rc1-bk1/net/sched/cls_rsvp.h	2004-10-29 01:55:09.000000000 +0200
@@ -604,7 +604,7 @@
 					}
 					if (arg->fn(tp, (unsigned long)f, arg) < 0) {
 						arg->stop = 1;
-						break;
+						return;
 					}
 					arg->count++;
 				}
