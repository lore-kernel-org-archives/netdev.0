From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (6/9) freenetdev - misc drivers
Date: Tue, 19 Aug 2003 12:20:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819122011.40906f04.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

s/kfree/free_netdev/ in cleanup routines of a bunch
of different network drivers.

diff -Nru a/arch/um/drivers/net_kern.c b/arch/um/drivers/net_kern.c
--- a/arch/um/drivers/net_kern.c	Tue Aug 19 09:04:31 2003
+++ b/arch/um/drivers/net_kern.c	Tue Aug 19 09:04:31 2003
@@ -609,7 +609,7 @@
 	unregister_netdev(dev);
 
 	list_del(&device->list);
-	kfree(device);
+	free_netdev(device);
 	return(0);
 }
 
diff -Nru a/drivers/ieee1394/eth1394.c b/drivers/ieee1394/eth1394.c
--- a/drivers/ieee1394/eth1394.c	Tue Aug 19 09:04:31 2003
+++ b/drivers/ieee1394/eth1394.c	Tue Aug 19 09:04:31 2003
@@ -502,7 +502,7 @@
 
 		if (hi->dev) {
 			unregister_netdev (hi->dev);
-			kfree(hi->dev);
+			free_netdev(hi->dev);
 		}
 	}
 
diff -Nru a/drivers/isdn/hysdn/hysdn_net.c b/drivers/isdn/hysdn/hysdn_net.c
--- a/drivers/isdn/hysdn/hysdn_net.c	Tue Aug 19 09:04:31 2003
+++ b/drivers/isdn/hysdn/hysdn_net.c	Tue Aug 19 09:04:31 2003
@@ -334,7 +334,7 @@
 	flush_tx_buffers((struct net_local *) dev);	/* empty buffers */
 
 	unregister_netdev(dev);	/* release the device */
-	kfree(dev);		/* release the memory allocated */
+	free_netdev(dev);	/* release the memory allocated */
 	if (card->debug_flags & LOG_NET_INIT)
 		hysdn_addlog(card, "network device deleted");
 
diff -Nru a/drivers/s390/net/ctcmain.c b/drivers/s390/net/ctcmain.c
--- a/drivers/s390/net/ctcmain.c	Tue Aug 19 09:04:31 2003
+++ b/drivers/s390/net/ctcmain.c	Tue Aug 19 09:04:31 2003
@@ -2708,7 +2708,7 @@
 	}
 #ifdef MODULE
 	if (free_dev)
-		kfree(dev);
+		free_netdev(dev);
 #endif
 }
 
diff -Nru a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
--- a/drivers/s390/net/netiucv.c	Tue Aug 19 09:04:31 2003
+++ b/drivers/s390/net/netiucv.c	Tue Aug 19 09:04:31 2003
@@ -1654,7 +1654,7 @@
 			kfree_fsm(privptr->fsm);
 		kfree(privptr);
 	}
-	kfree(dev);
+	free_netdev(dev);
 }
 
 static ssize_t
diff -Nru a/drivers/usb/net/catc.c b/drivers/usb/net/catc.c
--- a/drivers/usb/net/catc.c	Tue Aug 19 09:04:31 2003
+++ b/drivers/usb/net/catc.c	Tue Aug 19 09:04:31 2003
@@ -961,7 +961,7 @@
 		usb_free_urb(catc->tx_urb);
 		usb_free_urb(catc->rx_urb);
 		usb_free_urb(catc->irq_urb);
-		kfree(catc->netdev);
+		free_netdev(catc->netdev);
 		kfree(catc);
 	}
 }
diff -Nru a/drivers/usb/net/kaweth.c b/drivers/usb/net/kaweth.c
--- a/drivers/usb/net/kaweth.c	Tue Aug 19 09:04:32 2003
+++ b/drivers/usb/net/kaweth.c	Tue Aug 19 09:04:32 2003
@@ -1189,7 +1189,7 @@
 
 		kaweth_dbg("Unregistering net device");
 		unregister_netdev(kaweth->net);
-		kfree(kaweth->net);
+		free_netdev(kaweth->net);
 	}
 
 	usb_free_urb(kaweth->rx_urb);
diff -Nru a/drivers/usb/net/pegasus.c b/drivers/usb/net/pegasus.c
--- a/drivers/usb/net/pegasus.c	Tue Aug 19 09:04:32 2003
+++ b/drivers/usb/net/pegasus.c	Tue Aug 19 09:04:32 2003
@@ -1310,7 +1310,7 @@
 	free_skb_pool(pegasus);
 	if (pegasus->rx_skb)
 		dev_kfree_skb(pegasus->rx_skb);
-	kfree(pegasus->net);
+	free_netdev(pegasus->net);
 	kfree(pegasus);
 }
 
diff -Nru a/drivers/usb/net/rtl8150.c b/drivers/usb/net/rtl8150.c
--- a/drivers/usb/net/rtl8150.c	Tue Aug 19 09:04:31 2003
+++ b/drivers/usb/net/rtl8150.c	Tue Aug 19 09:04:31 2003
@@ -870,7 +870,7 @@
 		free_skb_pool(dev);
 		if (dev->rx_skb)
 			dev_kfree_skb(dev->rx_skb);
-		kfree(dev->netdev);
+		free_netdev(dev->netdev);
 		kfree(dev->intr_buff);
 		kfree(dev);
 	}
