From: chas williams (contractor) <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: refcount atm sockets
Date: Thu, 15 Jan 2004 22:05:08 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401160305.i0G356Rr017388@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

missed this during conversion of atm to a module -- please apply to 2.4

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1164  -> 1.1165 
#	    net/atm/common.c	1.35    -> 1.36   
# --------------------------------------------
# 03/11/25	chas@relax.cmf.nrl.navy.mil	1.1165
# [ATM]: refcount atm sockets
# --------------------------------------------
#
diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Thu Jan 15 14:42:31 2004
+++ b/net/atm/common.c	Thu Jan 15 14:42:31 2004
@@ -246,6 +246,8 @@
 		printk(KERN_DEBUG "vcc_sock_destruct: wmem leakage (%d bytes) detected.\n", atomic_read(&sk->wmem_alloc));
 
 	kfree(sk->protinfo.af_atm);
+
+	MOD_DEC_USE_COUNT;
 }
 
 static void vcc_def_wakeup(struct sock *sk)
@@ -316,6 +318,9 @@
 	vcc->atm_options = vcc->aal_options = 0;
 	sk->destruct = vcc_sock_destruct;
 	sock->sk = sk;
+
+	MOD_INC_USE_COUNT;
+
 	return 0;
 }
 
