From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] synclink -- incorrect check of register_netdev return val.
Date: Fri, 10 Oct 2003 10:32:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031010103202.1c6ef5f2.shemminger@osdl.org>
References: <20031009112714.18742308.shemminger@osdl.org>
	<20031010000158.2dc9ce78.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031010000158.2dc9ce78.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The synclink family of drivers all check for register_netdev returning
-1 when in fact it will return -EIO or -EEXIST.

diff -Nru a/drivers/char/pcmcia/synclink_cs.c b/drivers/char/pcmcia/synclink_cs.c
--- a/drivers/char/pcmcia/synclink_cs.c	Fri Oct 10 10:00:46 2003
+++ b/drivers/char/pcmcia/synclink_cs.c	Fri Oct 10 10:00:46 2003
@@ -4232,7 +4232,7 @@
 	d->tx_timeout = mgslpc_sppp_tx_timeout;
 	d->watchdog_timeo = 10*HZ;
 
-	if (register_netdev(d) == -1) {
+	if (register_netdev(d)) {
 		printk(KERN_WARNING "%s: register_netdev failed.\n", d->name);
 		sppp_detach(info->netdev);
 		return;
diff -Nru a/drivers/char/synclink.c b/drivers/char/synclink.c
--- a/drivers/char/synclink.c	Fri Oct 10 10:00:46 2003
+++ b/drivers/char/synclink.c	Fri Oct 10 10:00:46 2003
@@ -7847,7 +7847,7 @@
 	d->tx_timeout = mgsl_sppp_tx_timeout;
 	d->watchdog_timeo = 10*HZ;
 
-	if (register_netdev(d) == -1) {
+	if (register_netdev(d)) {
 		printk(KERN_WARNING "%s: register_netdev failed.\n", d->name);
 		sppp_detach(info->netdev);
 		return;
diff -Nru a/drivers/char/synclinkmp.c b/drivers/char/synclinkmp.c
--- a/drivers/char/synclinkmp.c	Fri Oct 10 10:00:46 2003
+++ b/drivers/char/synclinkmp.c	Fri Oct 10 10:00:46 2003
@@ -1653,7 +1653,7 @@
 	d->tx_timeout = sppp_cb_tx_timeout;
 	d->watchdog_timeo = 10*HZ;
 
-	if (register_netdev(d) == -1) {
+	if (register_netdev(d)) {
 		printk(KERN_WARNING "%s: register_netdev failed.\n", d->name);
 		sppp_detach(info->netdev);
 		return;
