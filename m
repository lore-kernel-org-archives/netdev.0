From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/4] clip: notifier related cleanups
Date: Thu, 13 Apr 2006 15:23:01 -0700
Message-ID: <20060413152301.6c17f573@localhost.localdomain>
References: <20060412105545.3b089dd8@localhost.localdomain>
	<20060413151945.0f181d04@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:16528 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932473AbWDMW0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2006 18:26:03 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060413151945.0f181d04@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cleanup some code around notifier.  Don't need (void) casts to ignore
return values, and use C90 style initializer. Just ignore unused device
events.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- clip.orig/net/atm/clip.c	2006-04-13 15:20:26.000000000 -0700
+++ clip/net/atm/clip.c	2006-04-13 15:20:38.000000000 -0700
@@ -443,7 +443,7 @@
 	}
 	clip_priv->stats.tx_packets++;
 	clip_priv->stats.tx_bytes += skb->len;
-	(void)vcc->send(vcc, skb);
+	vcc->send(vcc, skb);
 	if (atm_may_send(vcc, 0)) {
 		entry->vccs->xoff = 0;
 		return 0;
@@ -620,26 +620,16 @@
 	switch (event) {
 	case NETDEV_UP:
 		DPRINTK("clip_device_event NETDEV_UP\n");
-		(void)to_atmarpd(act_up, PRIV(dev)->number, 0);
+		to_atmarpd(act_up, PRIV(dev)->number, 0);
 		break;
 	case NETDEV_GOING_DOWN:
 		DPRINTK("clip_device_event NETDEV_DOWN\n");
-		(void)to_atmarpd(act_down, PRIV(dev)->number, 0);
+		to_atmarpd(act_down, PRIV(dev)->number, 0);
 		break;
 	case NETDEV_CHANGE:
 	case NETDEV_CHANGEMTU:
 		DPRINTK("clip_device_event NETDEV_CHANGE*\n");
-		(void)to_atmarpd(act_change, PRIV(dev)->number, 0);
-		break;
-	case NETDEV_REBOOT:
-	case NETDEV_REGISTER:
-	case NETDEV_DOWN:
-		DPRINTK("clip_device_event %ld\n", event);
-		/* ignore */
-		break;
-	default:
-		printk(KERN_WARNING "clip_device_event: unknown event "
-		       "%ld\n", event);
+		to_atmarpd(act_change, PRIV(dev)->number, 0);
 		break;
 	}
 	return NOTIFY_DONE;
@@ -666,17 +656,13 @@
 
 
 static struct notifier_block clip_dev_notifier = {
-	clip_device_event,
-	NULL,
-	0
+	.notifier_call = clip_device_event,
 };
 
 
 
 static struct notifier_block clip_inet_notifier = {
-	clip_inet_event,
-	NULL,
-	0
+	.notifier_call = clip_inet_event,
 };
 
 
