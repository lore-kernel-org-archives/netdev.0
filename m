From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] atm - set socket owner field
Date: Fri, 29 Aug 2003 11:37:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030829113758.6970f039.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chas Williams <chas@cmf.nrl.navy.mil>,
   "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

All sockets created by a protocol need to have owner field set
to prevent problems with orphaned sockets during module unload.

Patch for 2.6.0-test4

diff -Nru a/net/atm/common.c b/net/atm/common.c
--- a/net/atm/common.c	Fri Aug 29 11:24:19 2003
+++ b/net/atm/common.c	Fri Aug 29 11:24:19 2003
@@ -279,6 +279,7 @@
 	if (!sk)
 		return -ENOMEM;
 	sock_init_data(sock, sk);
+	sk_set_owner(sk, THIS_MODULE);
 	sk->sk_state_change = vcc_def_wakeup;
 	sk->sk_write_space = vcc_write_space;
 
