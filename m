From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] Remove MOD_* from LAPB
Date: Fri, 18 Jul 2003 13:32:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030718133211.1c7ed08d.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Henner Eisen <eis@baty.hanse.de>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The MOD_INC and MOD_DEC in lapb are no longer necessary in 2.6 since
the module subsystem will not allow lapb to be unloaded as long as a module
that is referencing the symbols (lapb_register/lapb_unregister) is loaded.

The lapb parameter block does have callback's so it is up to the caller
to correctly unregister on module exit; and looking at the existing code
it does do that.

Patch is against 2.6-test1

diff -Nru a/net/lapb/lapb_iface.c b/net/lapb/lapb_iface.c
--- a/net/lapb/lapb_iface.c	Fri Jul 18 13:21:02 2003
+++ b/net/lapb/lapb_iface.c	Fri Jul 18 13:21:02 2003
@@ -43,13 +43,11 @@
 static rwlock_t lapb_list_lock = RW_LOCK_UNLOCKED;
 
 /*
- *	Free an allocated lapb control block. This is done to centralise
- *	the MOD count code.
+ *	Free an allocated lapb control block. 
  */
 static void lapb_free_cb(struct lapb_cb *lapb)
 {
 	kfree(lapb);
-	MOD_DEC_USE_COUNT;
 }
 
 static __inline__ void lapb_hold(struct lapb_cb *lapb)
@@ -126,8 +124,6 @@
 
 	if (!lapb)
 		goto out;
-
-	MOD_INC_USE_COUNT;
 
 	memset(lapb, 0x00, sizeof(*lapb));
 
