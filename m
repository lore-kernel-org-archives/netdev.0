From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] bluetooth - set sock owner
Date: Fri, 29 Aug 2003 11:20:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030829112059.29414fc5.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Maxim Krasnyansky <maxk@qualcomm.com>,
   "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

All sockets created by a protocol need to have owner field set
to prevent problems with orphaned sockets during module unload.

diff -Nru a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
--- a/net/bluetooth/af_bluetooth.c	Fri Aug 29 11:14:03 2003
+++ b/net/bluetooth/af_bluetooth.c	Fri Aug 29 11:14:03 2003
@@ -130,6 +130,7 @@
 	}
 
 	sock_init_data(sock, sk);
+	sk_set_owner(sk, THIS_MODULE);
 	INIT_LIST_HEAD(&bt_sk(sk)->accept_q);
 	
 	sk->sk_zapped   = 0;
