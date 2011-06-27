From: Joe Perches <joe@perches.com>
Subject: [PATCH 7/8] ixp4xx_hss: Update to current logging forms
Date: Sun, 26 Jun 2011 22:01:34 -0700
Message-ID: <537895e4f7d669757d2acb06965788721f38bb71.1309150684.git.joe@perches.com>
References: <cover.1309150683.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3227 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756309Ab1F0FCH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2011 01:02:07 -0400
In-Reply-To: <cover.1309150683.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use pr_fmt, pr_<level> and netdev_<level> as appropriate.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wan/ixp4xx_hss.c |   28 +++++++++++++---------------
 1 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx_hss.c
index f1e1643..aaaca9a 100644
--- a/drivers/net/wan/ixp4xx_hss.c
+++ b/drivers/net/wan/ixp4xx_hss.c
@@ -8,6 +8,8 @@
  * as published by the Free Software Foundation.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/bitops.h>
 #include <linux/cdev.h>
 #include <linux/dma-mapping.h>
@@ -358,9 +360,8 @@ static void hss_npe_send(struct port *port, struct msg *msg, const char* what)
 {
 	u32 *val = (u32*)msg;
 	if (npe_send_message(port->npe, msg, what)) {
-		printk(KERN_CRIT "HSS-%i: unable to send command [%08X:%08X]"
-		       " to %s\n", port->id, val[0], val[1],
-		       npe_name(port->npe));
+		pr_crit("HSS-%i: unable to send command [%08X:%08X] to %s\n",
+			port->id, val[0], val[1], npe_name(port->npe));
 		BUG();
 	}
 }
@@ -447,8 +448,7 @@ static void hss_config(struct port *port)
 	if (npe_recv_message(port->npe, &msg, "HSS_LOAD_CONFIG") ||
 	    /* HSS_LOAD_CONFIG for port #1 returns port_id = #4 */
 	    msg.cmd != PORT_CONFIG_LOAD || msg.data32) {
-		printk(KERN_CRIT "HSS-%i: HSS_LOAD_CONFIG failed\n",
-		       port->id);
+		pr_crit("HSS-%i: HSS_LOAD_CONFIG failed\n", port->id);
 		BUG();
 	}
 
@@ -477,8 +477,7 @@ static u32 hss_get_status(struct port *port)
 	msg.hss_port = port->id;
 	hss_npe_send(port, &msg, "PORT_ERROR_READ");
 	if (npe_recv_message(port->npe, &msg, "PORT_ERROR_READ")) {
-		printk(KERN_CRIT "HSS-%i: unable to read HSS status\n",
-		       port->id);
+		pr_crit("HSS-%i: unable to read HSS status\n", port->id);
 		BUG();
 	}
 
@@ -736,9 +735,8 @@ static int hss_hdlc_poll(struct napi_struct *napi, int budget)
 			dev->stats.rx_errors++;
 			break;
 		default:	/* FIXME - remove printk */
-			printk(KERN_ERR "%s: hss_hdlc_poll: status 0x%02X"
-			       " errors %u\n", dev->name, desc->status,
-			       desc->error_count);
+			netdev_err(dev, "hss_hdlc_poll: status 0x%02X errors %u\n",
+				   desc->status, desc->error_count);
 			dev->stats.rx_errors++;
 		}
 
@@ -1127,8 +1125,8 @@ static int hss_hdlc_close(struct net_device *dev)
 		buffs--;
 
 	if (buffs)
-		printk(KERN_CRIT "%s: unable to drain RX queue, %i buffer(s)"
-		       " left in NPE\n", dev->name, buffs);
+		netdev_crit(dev, "unable to drain RX queue, %i buffer(s) left in NPE\n",
+			    buffs);
 
 	buffs = TX_DESCS;
 	while (queue_get_desc(queue_ids[port->id].tx, port, 1) >= 0)
@@ -1143,8 +1141,8 @@ static int hss_hdlc_close(struct net_device *dev)
 	} while (++i < MAX_CLOSE_WAIT);
 
 	if (buffs)
-		printk(KERN_CRIT "%s: unable to drain TX queue, %i buffer(s) "
-		       "left in NPE\n", dev->name, buffs);
+		netdev_crit(dev, "unable to drain TX queue, %i buffer(s) left in NPE\n",
+			    buffs);
 #if DEBUG_CLOSE
 	if (!buffs)
 		printk(KERN_DEBUG "Draining TX queues took %i cycles\n", i);
@@ -1364,7 +1362,7 @@ static int __devinit hss_init_one(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, port);
 
-	printk(KERN_INFO "%s: HSS-%i\n", dev->name, port->id);
+	netdev_info(dev, "HSS-%i\n", port->id);
 	return 0;
 
 err_free_netdev:
-- 
1.7.6.rc1

