From: akpm@osdl.org
Subject: [patch 2/7] netpoll: fix null ifa_list pointer dereference
Date: Wed, 10 Nov 2004 16:02:22 -0800
Message-ID: <200411102358.iAANwC904201@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, mpm@selenic.com,
        jmoyer@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Matt Mackall <mpm@selenic.com>

This fixes a bug where netpoll can dereference a null ifa_list pointer when
not supplied an IP address at module load and the interface is up but no IP
is configured.  

Bonus: unrelated netif_running cleanup

Signed-off by: Jeff Moyer <jmoyer@redhat.com>
Signed-off by: Matt Mackall <mpm@selenic.com>

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/net/core/netpoll.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -puN net/core/netpoll.c~netpoll-fix-null-ifa_list-pointer-dereference net/core/netpoll.c
--- 25/net/core/netpoll.c~netpoll-fix-null-ifa_list-pointer-dereference	Wed Nov 10 16:00:35 2004
+++ 25-akpm/net/core/netpoll.c	Wed Nov 10 16:00:35 2004
@@ -565,7 +565,7 @@ int netpoll_setup(struct netpoll *np)
 		goto release;
 	}
 
-	if (!(ndev->flags & IFF_UP)) {
+	if (!netif_running(ndev)) {
 		unsigned short oflags;
 		unsigned long atmost, atleast;
 
@@ -611,7 +611,7 @@ int netpoll_setup(struct netpoll *np)
 		rcu_read_lock();
 		in_dev = __in_dev_get(ndev);
 
-		if (!in_dev) {
+		if (!in_dev || !in_dev->ifa_list) {
 			rcu_read_unlock();
 			printk(KERN_ERR "%s: no IP address for %s, aborting\n",
 			       np->name, np->dev_name);
_
