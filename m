From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [PATCH net-drivers-2.6 1/5] ixgb: use netif_poll_{enable|disable}
Date: Tue, 15 Feb 2005 13:37:20 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0502151200000.30336-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

1 use netif_poll_{enable|disable} to synchronize between poll and i/f down/up
Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c	2005-02-06 23:33:00.652031344 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c	2005-02-06 23:33:01.617884512 -0800
@@ -292,6 +292,9 @@ ixgb_up(struct ixgb_adapter *adapter)
 	mod_timer(&adapter->watchdog_timer, jiffies);
 	ixgb_irq_enable(adapter);
 
+#ifdef CONFIG_IXGB_NAPI
+	netif_poll_enable(netdev);
+#endif
 	return 0;
 }
 
@@ -309,6 +312,9 @@ ixgb_down(struct ixgb_adapter *adapter, 
 #endif
 	if(kill_watchdog)
 		del_timer_sync(&adapter->watchdog_timer);
+#ifdef CONFIG_IXGB_NAPI
+	netif_poll_disable(netdev);
+#endif
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
 	netif_carrier_off(netdev);
	
