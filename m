From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] Allow lapb to be unloaded.
Date: Fri, 18 Jul 2003 15:01:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030718150101.0558d04e.shemminger@osdl.org>
References: <20030718133211.1c7ed08d.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Henner Eisen <eis@baty.hanse.de>, "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030718133211.1c7ed08d.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Without an exit routine lapb can't be unloaded.

Tested on 2.6.0-test1
diff -Nru a/net/lapb/lapb_iface.c b/net/lapb/lapb_iface.c
--- a/net/lapb/lapb_iface.c	Fri Jul 18 14:52:18 2003
+++ b/net/lapb/lapb_iface.c	Fri Jul 18 14:52:18 2003
@@ -443,8 +443,14 @@
 	return 0;
 }
 
+static void __exit lapb_exit(void)
+{
+	WARN_ON(!list_empty(&lapb_list));
+}
+
 MODULE_AUTHOR("Jonathan Naylor <g4klx@g4klx.demon.co.uk>");
 MODULE_DESCRIPTION("The X.25 Link Access Procedure B link layer protocol");
 MODULE_LICENSE("GPL");
 
 module_init(lapb_init);
+module_exit(lapb_exit);
