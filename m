From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 6/6] PKT_SCHED: break is not enough to stop walking
Date: Fri, 29 Oct 2004 02:26:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029002628.GE12289@postel.suug.ch>
References: <20041029002113.GY12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041029002113.GY12289@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

break is not enough to escape from the walking loops, since
multiple encapsulated loops are used to traverse the hash tables.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff -Nru linux-2.6.10-rc1-bk7.orig/net/sched/cls_fw.c linux-2.6.10-rc1-bk7/net/sched/cls_fw.c
--- linux-2.6.10-rc1-bk7.orig/net/sched/cls_fw.c	2004-10-29 00:43:38.000000000 +0200
+++ linux-2.6.10-rc1-bk7/net/sched/cls_fw.c	2004-10-29 00:50:29.000000000 +0200
@@ -338,7 +338,7 @@
 			}
 			if (arg->fn(tp, (unsigned long)f, arg) < 0) {
 				arg->stop = 1;
-				break;
+				return;
 			}
 			arg->count++;
 		}
diff -Nru linux-2.6.10-rc1-bk7.orig/net/sched/cls_route.c linux-2.6.10-rc1-bk7/net/sched/cls_route.c
--- linux-2.6.10-rc1-bk7.orig/net/sched/cls_route.c	2004-10-28 22:03:29.000000000 +0200
+++ linux-2.6.10-rc1-bk7/net/sched/cls_route.c	2004-10-29 01:31:12.000000000 +0200
@@ -538,7 +538,7 @@
 					}
 					if (arg->fn(tp, (unsigned long)f, arg) < 0) {
 						arg->stop = 1;
-						break;
+						return;
 					}
 					arg->count++;
 				}
diff -Nru linux-2.6.10-rc1-bk7.orig/net/sched/cls_rsvp.h linux-2.6.10-rc1-bk7/net/sched/cls_rsvp.h
--- linux-2.6.10-rc1-bk7.orig/net/sched/cls_rsvp.h	2004-10-28 22:03:29.000000000 +0200
+++ linux-2.6.10-rc1-bk7/net/sched/cls_rsvp.h	2004-10-29 01:31:49.000000000 +0200
@@ -601,7 +601,7 @@
 					}
 					if (arg->fn(tp, (unsigned long)f, arg) < 0) {
 						arg->stop = 1;
-						break;
+						return;
 					}
 					arg->count++;
 				}
