From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] cosa -- incorrect comparison for register_netdev
Date: Thu, 9 Oct 2003 11:27:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031009112714.18742308.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

If register_netdev fails this driver will be in trouble because
the return values are things like -EIO or -EEXIST, not just -1.

diff -Nru a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
--- a/drivers/net/wan/cosa.c	Thu Oct  9 11:24:39 2003
+++ b/drivers/net/wan/cosa.c	Thu Oct  9 11:24:39 2003
@@ -615,7 +615,7 @@
 	d->get_stats = cosa_net_stats;
 	d->tx_timeout = cosa_sppp_timeout;
 	d->watchdog_timeo = TX_TIMEOUT;
-	if (register_netdev(d) == -1) {
+	if (register_netdev(d)) {
 		printk(KERN_WARNING "%s: register_netdev failed.\n", d->name);
 		sppp_detach(chan->pppdev.dev);
 		free_netdev(chan->pppdev.dev);
