From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] bluetooth protocol module aliases
Date: Wed, 10 Dec 2003 16:00:38 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031210160038.53f44b29.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Maxim Krasnyansky <maxk@qualcomm.com>,
        "David S. Miller"
 <davem@redhat.com>,
        Rusty Russell <rusty@rustcorp.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Simple extension of rusty's network protocol aliases to handle the bluetooth
protocols as well.  This can hold off till after 2.6.0

diff -Nru a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
--- a/include/net/bluetooth/bluetooth.h	Wed Dec 10 15:55:23 2003
+++ b/include/net/bluetooth/bluetooth.h	Wed Dec 10 15:55:23 2003
@@ -179,4 +179,7 @@
 
 int  bt_err(__u16 code);
 
+#define MODULE_ALIAS_BTPROTO(proto) \
+	MODULE_ALIAS("bt-proto-" __stringify(proto))
+
 #endif /* __BLUETOOTH_H */
diff -Nru a/net/bluetooth/bnep/sock.c b/net/bluetooth/bnep/sock.c
--- a/net/bluetooth/bnep/sock.c	Wed Dec 10 15:55:23 2003
+++ b/net/bluetooth/bnep/sock.c	Wed Dec 10 15:55:23 2003
@@ -192,6 +192,7 @@
 	.owner	= THIS_MODULE,
 	.create = bnep_sock_create
 };
+MODULE_ALIAS_BTPROTO(BTPROTO_BNEP);
 
 int __init bnep_sock_init(void)
 {
diff -Nru a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
--- a/net/bluetooth/hci_sock.c	Wed Dec 10 15:55:23 2003
+++ b/net/bluetooth/hci_sock.c	Wed Dec 10 15:55:23 2003
@@ -639,6 +639,7 @@
 	.owner	= THIS_MODULE,
 	.create = hci_sock_create,
 };
+MODULE_ALIAS_BTPROTO(BTPROTO_HCI);
 
 struct notifier_block hci_sock_nblock = {
 	.notifier_call = hci_sock_dev_event
diff -Nru a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
--- a/net/bluetooth/l2cap.c	Wed Dec 10 15:55:23 2003
+++ b/net/bluetooth/l2cap.c	Wed Dec 10 15:55:23 2003
@@ -2141,6 +2141,7 @@
 	.create	=       l2cap_sock_create,
 	.owner	=	THIS_MODULE,
 };
+MODULE_ALIAS_BTPROTO(BTPROTO_L2CAP);
 
 static struct hci_proto l2cap_hci_proto = {
 	.name =         "L2CAP",
diff -Nru a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
--- a/net/bluetooth/rfcomm/sock.c	Wed Dec 10 15:55:23 2003
+++ b/net/bluetooth/rfcomm/sock.c	Wed Dec 10 15:55:23 2003
@@ -888,6 +888,7 @@
 	.owner		= THIS_MODULE,
 	.create		= rfcomm_sock_create
 };
+MODULE_ALIAS_BTPROTO(BTPROTO_RFCOMM);
 
 int  __init rfcomm_init_sockets(void)
 {
