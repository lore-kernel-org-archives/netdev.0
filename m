From: Ralf Baechle <ralf@linux-mips.org>
Subject: AX.25 cb lookup patch
Date: Tue, 9 Nov 2004 04:36:18 +0100
Message-ID: <20041109033617.GB621@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ax AX.25 connection is identified only by it's source and destination,
not by the device it's routed through, so fix the connection block
lookup to ignore the device of a connection.  This fixes dying connections
in case of an AX.25 routing flap.

Index: net/ax25/af_ax25.c
===================================================================
RCS file: /home/cvs/linux/net/ax25/af_ax25.c,v
retrieving revision 1.59
diff -u -r1.59 af_ax25.c
--- net/ax25/af_ax25.c	12 Oct 2004 01:45:52 -0000	1.59
+++ net/ax25/af_ax25.c	3 Nov 2004 03:23:53 -0000
@@ -207,16 +207,8 @@
 			continue;
 		if (s->ax25_dev == NULL)
 			continue;
-		if (ax25cmp(&s->source_addr, src_addr) == 0 && ax25cmp(&s->dest_addr, dest_addr) == 0 && s->ax25_dev->dev == dev) {
-			if (digi != NULL && digi->ndigi != 0) {
-				if (s->digipeat == NULL)
-					continue;
-				if (ax25digicmp(s->digipeat, digi) != 0)
-					continue;
-			} else {
-				if (s->digipeat != NULL && s->digipeat->ndigi != 0)
-					continue;
-			}
+		if (ax25cmp(&s->source_addr, src_addr) == 0 &&
+		    ax25cmp(&s->dest_addr, dest_addr) == 0) {
 			ax25_cb_hold(s);
 			spin_unlock_bh(&ax25_list_lock);
 
