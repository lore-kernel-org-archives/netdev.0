From: akpm@osdl.org
Subject: [patch 6/9] X.25: Stop /proc/net/x25/route infinitely reading
Date: Thu, 28 Oct 2004 00:19:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410280721.i9S7Li908005@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, ahendry@tusc.com.au
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Andrew Hendry <ahendry@tusc.com.au>

route add --x25 0/0 eth0
cat /proc/net/x25/route
reads the single routing entry forever.

This patch makes x25_get_route_idx behave the same as x25_get_socket_idx
which works correctly.

Signed-off-by: Andrew Hendry <ahendry@tusc.com.au>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/net/x25/x25_proc.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff -puN net/x25/x25_proc.c~x25-stop-proc-net-x25-route-infinitely net/x25/x25_proc.c
--- 25/net/x25/x25_proc.c~x25-stop-proc-net-x25-route-infinitely	2004-10-28 00:17:08.225553512 -0700
+++ 25-akpm/net/x25/x25_proc.c	2004-10-28 00:17:08.228553056 -0700
@@ -32,10 +32,11 @@ static __inline__ struct x25_route *x25_
 
 	list_for_each(route_entry, &x25_route_list) {
 		rt = list_entry(route_entry, struct x25_route, node);
-		if (--pos)
-			break;
+		if (!pos--)
+			goto found;
 	}
-
+	rt = NULL;
+found:
 	return rt;
 }
 
_
