From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6] convert ROSE to use module_param
Date: Thu, 29 Jul 2004 11:35:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040729113522.30add0e5@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-hams@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, ralf@linux-mips.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Switch to module_param and the hash list can be local.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/rose/af_rose.c b/net/rose/af_rose.c
--- a/net/rose/af_rose.c	2004-07-23 13:33:31 -07:00
+++ b/net/rose/af_rose.c	2004-07-23 13:33:31 -07:00
@@ -11,6 +11,7 @@
  */
 #include <linux/config.h>
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/init.h>
 #include <linux/errno.h>
 #include <linux/types.h>
@@ -57,7 +58,7 @@
 int sysctl_rose_maximum_vcs             = ROSE_DEFAULT_MAXVC;
 int sysctl_rose_window_size             = ROSE_DEFAULT_WINDOW_SIZE;
 
-HLIST_HEAD(rose_list);
+static HLIST_HEAD(rose_list);
 spinlock_t rose_list_lock = SPIN_LOCK_UNLOCKED;
 
 static struct proto_ops rose_proto_ops;
@@ -1550,7 +1551,7 @@
 }
 module_init(rose_proto_init);
 
-MODULE_PARM(rose_ndevs, "i");
+module_param(rose_ndevs, int, 0);
 MODULE_PARM_DESC(rose_ndevs, "number of ROSE devices");
 
 MODULE_AUTHOR("Jonathan Naylor G4KLX <g4klx@g4klx.demon.co.uk>");
