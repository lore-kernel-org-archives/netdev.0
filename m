From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] fix module netproto alias for bluetooth
Date: Wed, 10 Dec 2003 15:58:36 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031210155836.1c12d56a.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Maxim Krasnyansky <maxk@qualcomm.com>,
        Rusty Russell
 <rusty@rustcorp.com.au>,
        "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In 2.6.0-test11 the net-pf-31 alias gets associated with the bnep module
rather than the bluetooth module that actually handles the protocol.
It is mostly works because bnep depends on bluetooth so it gets loaded.

diff -Nru a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
--- a/net/bluetooth/af_bluetooth.c	Wed Dec 10 15:55:50 2003
+++ b/net/bluetooth/af_bluetooth.c	Wed Dec 10 15:55:50 2003
@@ -361,3 +361,4 @@
 MODULE_AUTHOR("Maxim Krasnyansky <maxk@qualcomm.com>");
 MODULE_DESCRIPTION("Bluetooth Core ver " VERSION);
 MODULE_LICENSE("GPL");
+MODULE_ALIAS_NETPROTO(PF_BLUETOOTH);
diff -Nru a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
--- a/net/bluetooth/bnep/core.c	Wed Dec 10 15:55:50 2003
+++ b/net/bluetooth/bnep/core.c	Wed Dec 10 15:55:50 2003
@@ -707,4 +707,3 @@
 MODULE_DESCRIPTION("Bluetooth BNEP ver " VERSION);
 MODULE_AUTHOR("David Libault <david.libault@inventel.fr>, Maxim Krasnyanskiy <maxk@qualcomm.com>");
 MODULE_LICENSE("GPL");
-MODULE_ALIAS_NETPROTO(PF_BLUETOOTH);
