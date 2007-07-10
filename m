From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: [PATCH v2 -mm 1/9] netconsole: Cleanups, codingstyle, prettyfication
Date: Tue, 10 Jul 2007 14:49:25 +0530
Message-ID: <20070710091925.23907.3312.sendpatchset@cselinux1.cse.iitk.ac.in>
References: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in>
Cc: Matt Mackall <mpm@selenic.com>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Satyam Sharma <ssatyam@cse.iitk.ac.in>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:42579 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756424AbXGJI5M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 04:57:12 -0400
In-Reply-To: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <ssatyam@cse.iitk.ac.in>

[1/9] netconsole: Cleanups, codingstyle, prettyfication

(1) Remove unwanted headers.
(2) Mark __init and __exit as appropriate.
(3) Various trivial codingstyle and prettification stuff.

Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>

---

 drivers/net/netconsole.c |   55 +++++++++++++++++++++++------------------------
 1 file changed, 27 insertions(+), 28 deletions(-)

---

diff -ruNp a/drivers/net/netconsole.c b/drivers/net/netconsole.c
--- a/drivers/net/netconsole.c	2007-04-26 08:38:32.000000000 +0530
+++ b/drivers/net/netconsole.c	2007-07-03 20:27:17.000000000 +0530
@@ -35,35 +35,32 @@
  ****************************************************************/
 
 #include <linux/mm.h>
-#include <linux/tty.h>
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/console.h>
-#include <linux/tty_driver.h>
 #include <linux/moduleparam.h>
 #include <linux/string.h>
-#include <linux/sysrq.h>
-#include <linux/smp.h>
 #include <linux/netpoll.h>
 
 MODULE_AUTHOR("Maintainer: Matt Mackall <mpm@selenic.com>");
 MODULE_DESCRIPTION("Console driver for network interfaces");
 MODULE_LICENSE("GPL");
 
-static char config[256];
-module_param_string(netconsole, config, 256, 0);
+#define MAX_PARAM_LENGTH	256
+#define MAX_PRINT_CHUNK		1000
+
+static char config[MAX_PARAM_LENGTH];
+module_param_string(netconsole, config, MAX_PARAM_LENGTH, 0);
 MODULE_PARM_DESC(netconsole, " netconsole=[src-port]@[src-ip]/[dev],[tgt-port]@<tgt-ip>/[tgt-macaddr]\n");
 
 static struct netpoll np = {
-	.name = "netconsole",
-	.dev_name = "eth0",
-	.local_port = 6665,
-	.remote_port = 6666,
-	.remote_mac = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff},
+	.name		= "netconsole",
+	.dev_name	= "eth0",
+	.local_port	= 6665,
+	.remote_port	= 6666,
+	.remote_mac	= {0xff, 0xff, 0xff, 0xff, 0xff, 0xff},
 };
-static int configured = 0;
-
-#define MAX_PRINT_CHUNK 1000
+static int configured;
 
 static void write_msg(struct console *con, const char *msg, unsigned int len)
 {
@@ -75,7 +72,7 @@ static void write_msg(struct console *co
 
 	local_irq_save(flags);
 
-	for(left = len; left; ) {
+	for (left = len; left;) {
 		frag = min(left, MAX_PRINT_CHUNK);
 		netpoll_send_udp(&np, msg, frag);
 		msg += frag;
@@ -86,12 +83,12 @@ static void write_msg(struct console *co
 }
 
 static struct console netconsole = {
-	.name = "netcon",
-	.flags = CON_ENABLED | CON_PRINTBUFFER,
-	.write = write_msg
+	.name	= "netcon",
+	.flags	= CON_ENABLED | CON_PRINTBUFFER,
+	.write	= write_msg,
 };
 
-static int option_setup(char *opt)
+static int __init option_setup(char *opt)
 {
 	configured = !netpoll_parse_options(&np, opt);
 	return 1;
@@ -99,28 +96,30 @@ static int option_setup(char *opt)
 
 __setup("netconsole=", option_setup);
 
-static int init_netconsole(void)
+static int __init init_netconsole(void)
 {
-	int err;
+	int err = 0;
 
-	if(strlen(config))
+	if (strnlen(config, MAX_PARAM_LENGTH))
 		option_setup(config);
 
-	if(!configured) {
-		printk("netconsole: not configured, aborting\n");
-		return 0;
+	if (!configured) {
+		printk(KERN_INFO "netconsole: not configured, aborting\n");
+		goto out;
 	}
 
 	err = netpoll_setup(&np);
 	if (err)
-		return err;
+		goto out;
 
 	register_console(&netconsole);
 	printk(KERN_INFO "netconsole: network logging started\n");
-	return 0;
+
+out:
+	return err;
 }
 
-static void cleanup_netconsole(void)
+static void __exit cleanup_netconsole(void)
 {
 	unregister_console(&netconsole);
 	netpoll_cleanup(&np);
