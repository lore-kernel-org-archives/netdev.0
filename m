From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] netconsole: Convert to pr_<level>
Date: Mon, 28 Oct 2013 12:53:21 -0700
Message-ID: <1382990001.8718.4.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use a more current logging style.

Convert printks to pr_<level>.

Consolidate multiple printks into a single printk to avoid
any possible dmesg interleaving.  Add a default "event" msg
in case the listed types are ever expanded.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/netconsole.c | 57 +++++++++++++++++++++++-------------------------
 1 file changed, 27 insertions(+), 30 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index adeee61..a8ef4c4 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -34,6 +34,8 @@
  *
  ****************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/mm.h>
 #include <linux/init.h>
 #include <linux/module.h>
@@ -319,8 +321,8 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 	if (enabled < 0 || enabled > 1)
 		return -EINVAL;
 	if (enabled == nt->enabled) {
-		printk(KERN_INFO "netconsole: network logging has already %s\n",
-				nt->enabled ? "started" : "stopped");
+		pr_info("network logging has already %s\n",
+			nt->enabled ? "started" : "stopped");
 		return -EINVAL;
 	}
 
@@ -339,7 +341,7 @@ static ssize_t store_enabled(struct netconsole_target *nt,
 			return err;
 		}
 
-		printk(KERN_INFO "netconsole: network logging started\n");
+		pr_info("network logging started\n");
 
 	} else {	/* 0 */
 		netpoll_cleanup(&nt->np);
@@ -358,9 +360,8 @@ static ssize_t store_dev_name(struct netconsole_target *nt,
 	size_t len;
 
 	if (nt->enabled) {
-		printk(KERN_ERR "netconsole: target (%s) is enabled, "
-				"disable to update parameters\n",
-				config_item_name(&nt->item));
+		pr_err("target (%s) is enabled, disable to update parameters\n",
+		       config_item_name(&nt->item));
 		return -EINVAL;
 	}
 
@@ -381,9 +382,8 @@ static ssize_t store_local_port(struct netconsole_target *nt,
 	int rv;
 
 	if (nt->enabled) {
-		printk(KERN_ERR "netconsole: target (%s) is enabled, "
-				"disable to update parameters\n",
-				config_item_name(&nt->item));
+		pr_err("target (%s) is enabled, disable to update parameters\n",
+		       config_item_name(&nt->item));
 		return -EINVAL;
 	}
 
@@ -400,9 +400,8 @@ static ssize_t store_remote_port(struct netconsole_target *nt,
 	int rv;
 
 	if (nt->enabled) {
-		printk(KERN_ERR "netconsole: target (%s) is enabled, "
-				"disable to update parameters\n",
-				config_item_name(&nt->item));
+		pr_err("target (%s) is enabled, disable to update parameters\n",
+		       config_item_name(&nt->item));
 		return -EINVAL;
 	}
 
@@ -417,9 +416,8 @@ static ssize_t store_local_ip(struct netconsole_target *nt,
 			      size_t count)
 {
 	if (nt->enabled) {
-		printk(KERN_ERR "netconsole: target (%s) is enabled, "
-				"disable to update parameters\n",
-				config_item_name(&nt->item));
+		pr_err("target (%s) is enabled, disable to update parameters\n",
+		       config_item_name(&nt->item));
 		return -EINVAL;
 	}
 
@@ -427,7 +425,7 @@ static ssize_t store_local_ip(struct netconsole_target *nt,
 		const char *end;
 		if (in6_pton(buf, count, nt->np.local_ip.in6.s6_addr, -1, &end) > 0) {
 			if (*end && *end != '\n') {
-				printk(KERN_ERR "netconsole: invalid IPv6 address at: <%c>\n", *end);
+				pr_err("invalid IPv6 address at: <%c>\n", *end);
 				return -EINVAL;
 			}
 			nt->np.ipv6 = true;
@@ -448,9 +446,8 @@ static ssize_t store_remote_ip(struct netconsole_target *nt,
 			       size_t count)
 {
 	if (nt->enabled) {
-		printk(KERN_ERR "netconsole: target (%s) is enabled, "
-				"disable to update parameters\n",
-				config_item_name(&nt->item));
+		pr_err("target (%s) is enabled, disable to update parameters\n",
+		       config_item_name(&nt->item));
 		return -EINVAL;
 	}
 
@@ -458,7 +455,7 @@ static ssize_t store_remote_ip(struct netconsole_target *nt,
 		const char *end;
 		if (in6_pton(buf, count, nt->np.remote_ip.in6.s6_addr, -1, &end) > 0) {
 			if (*end && *end != '\n') {
-				printk(KERN_ERR "netconsole: invalid IPv6 address at: <%c>\n", *end);
+				pr_err("invalid IPv6 address at: <%c>\n", *end);
 				return -EINVAL;
 			}
 			nt->np.ipv6 = true;
@@ -481,9 +478,8 @@ static ssize_t store_remote_mac(struct netconsole_target *nt,
 	u8 remote_mac[ETH_ALEN];
 
 	if (nt->enabled) {
-		printk(KERN_ERR "netconsole: target (%s) is enabled, "
-				"disable to update parameters\n",
-				config_item_name(&nt->item));
+		pr_err("target (%s) is enabled, disable to update parameters\n",
+		       config_item_name(&nt->item));
 		return -EINVAL;
 	}
 
@@ -704,19 +700,20 @@ restart:
 	}
 	spin_unlock_irqrestore(&target_list_lock, flags);
 	if (stopped) {
-		printk(KERN_INFO "netconsole: network logging stopped on "
-		       "interface %s as it ", dev->name);
+		const char *msg = "had an event";
 		switch (event) {
 		case NETDEV_UNREGISTER:
-			printk(KERN_CONT "unregistered\n");
+			msg = "unregistered";
 			break;
 		case NETDEV_RELEASE:
-			printk(KERN_CONT "released slaves\n");
+			msg = "released slaves";
 			break;
 		case NETDEV_JOIN:
-			printk(KERN_CONT "is joining a master device\n");
+			msg = "is joining a master device";
 			break;
 		}
+		pr_info("network logging stopped on interface %s as it %s\n",
+			dev->name, msg);
 	}
 
 done:
@@ -802,7 +799,7 @@ static int __init init_netconsole(void)
 		goto undonotifier;
 
 	register_console(&netconsole);
-	printk(KERN_INFO "netconsole: network logging started\n");
+	pr_info("network logging started\n");
 
 	return err;
 
@@ -810,7 +807,7 @@ undonotifier:
 	unregister_netdevice_notifier(&netconsole_netdev_notifier);
 
 fail:
-	printk(KERN_ERR "netconsole: cleaning up\n");
+	pr_err("cleaning up\n");
 
 	/*
 	 * Remove all targets and destroy them (only targets created
