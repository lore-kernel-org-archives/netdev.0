From: akpm@osdl.org
Subject: [patch 1/1] err2-15: ax25_rt_add() locking fix
Date: Fri, 02 Jul 2004 01:46:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407020847.i628lLG23044@mail.osdl.org>
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



It can return with the lock held.

Found by the Stanford locking checker

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/net/ax25/ax25_route.c |    1 +
 1 files changed, 1 insertion(+)

diff -puN net/ax25/ax25_route.c~err2-15-ax25_rt_add-locking-fix net/ax25/ax25_route.c
--- 25/net/ax25/ax25_route.c~err2-15-ax25_rt_add-locking-fix	2004-07-02 01:45:20.234119280 -0700
+++ 25-akpm/net/ax25/ax25_route.c	2004-07-02 01:45:37.960424472 -0700
@@ -122,6 +122,7 @@ static int ax25_rt_add(struct ax25_route
 					ax25_rt->digipeat->calls[i]    = route->digi_addr[i];
 				}
 			}
+			write_unlock(&ax25_route_lock);
 			return 0;
 		}
 		ax25_rt = ax25_rt->next;
_
