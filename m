From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 1/3] [bonding 2.4] Get rid of MOD_*_USE_COUNT, and use C99 initializers
Date: Mon, 15 Sep 2003 12:00:19 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309151200.19968.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	2003-09-15 11:39:34.000000000 +0300
+++ b/drivers/net/bonding/bond_main.c	2003-09-15 11:39:36.000000000 +0300
@@ -980,8 +980,6 @@ static int bond_open(struct net_device *
 		add_timer(alb_timer);
 	}
 
-	MOD_INC_USE_COUNT;
-
 	if (miimon > 0) {  /* link check interval, in milliseconds. */
 		init_timer(timer);
 		timer->expires  = jiffies + (miimon * HZ / 1000);
@@ -1055,7 +1053,6 @@ static int bond_close(struct net_device 
 		bond_alb_deinitialize(bond);
 	}
 
-	MOD_DEC_USE_COUNT;
 	return 0;
 }
 
@@ -3770,7 +3767,7 @@ static int bond_netdev_event(struct noti
 }
 
 static struct notifier_block bond_netdev_notifier = {
-	notifier_call: bond_netdev_event,
+	.notifier_call = bond_netdev_event,
 };
 
 static void bond_deinit(struct net_device *dev)
