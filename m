From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ax25 use dev_hold/dev_put as required for net_devices.
Date: Tue, 12 Aug 2003 16:49:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030812164940.4b8ebcf9.shemminger@osdl.org>
References: <20030812194653.A28977@jeroen.pe1rxq.ampr.org>
	<20030812135655.7334887b.shemminger@osdl.org>
	<20030812230951.E28977@jeroen.pe1rxq.ampr.org>
	<20030812153901.6e700dcb.shemminger@osdl.org>
	<20030813010301.K28977@jeroen.pe1rxq.ampr.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, ralf@linux-mips.org, davem@redhat.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeroen Vreeken <pe1rxq@amsat.org>
In-Reply-To: <20030813010301.K28977@jeroen.pe1rxq.ampr.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ax25 holds a reference to the net device below, in the ax25_dev structure;
therefore it needs to use dev_hold/dev_put.

This is against 2.6.0-test3 with your earlier patch

diff -Nru a/net/ax25/ax25_dev.c b/net/ax25/ax25_dev.c
--- a/net/ax25/ax25_dev.c	Tue Aug 12 16:45:51 2003
+++ b/net/ax25/ax25_dev.c	Tue Aug 12 16:45:51 2003
@@ -67,6 +67,7 @@
 
 	dev->ax25_ptr     = ax25_dev;
 	ax25_dev->dev     = dev;
+	dev_hold(dev);
 	ax25_dev->forward = NULL;
 
 	ax25_dev->values[AX25_VALUES_IPDEFMODE] = AX25_DEF_IPDEFMODE;
@@ -121,6 +122,7 @@
 	if ((s = ax25_dev_list) == ax25_dev) {
 		ax25_dev_list = s->next;
 		spin_unlock_bh(&ax25_dev_lock);
+		dev_put(dev);
 		kfree(ax25_dev);
 		ax25_register_sysctl();
 		return;
@@ -131,6 +133,7 @@
 			s->next = ax25_dev->next;
 			spin_unlock_bh(&ax25_dev_lock);
 			kfree(ax25_dev);
+			dev_put(dev);
 			ax25_register_sysctl();
 			return;
 		}
