From: akpm@osdl.org
Subject: [patch 1/1] err1-67: lapb_unregister() locking fix
Date: Fri, 02 Jul 2004 01:30:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407020831.i628VmG20814@mail.osdl.org>
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Fix deadlock identified by the Stanford locking checker.

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/net/lapb/lapb_iface.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN net/lapb/lapb_iface.c~err1-67-lapb_unregister-locking-fix net/lapb/lapb_iface.c
--- 25/net/lapb/lapb_iface.c~err1-67-lapb_unregister-locking-fix	2004-07-02 01:29:50.645438240 -0700
+++ 25-akpm/net/lapb/lapb_iface.c	2004-07-02 01:29:55.717667144 -0700
@@ -176,7 +176,7 @@ int lapb_unregister(struct net_device *d
 	struct lapb_cb *lapb;
 	int rc = LAPB_BADTOKEN;
 
-	write_unlock_bh(&lapb_list_lock);
+	write_lock_bh(&lapb_list_lock);
 	lapb = __lapb_devtostruct(dev);
 	if (!lapb)
 		goto out;
_
