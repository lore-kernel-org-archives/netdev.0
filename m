From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [PATCH net-drivers-2.4 2/10] e1000: 2 use netif_poll_{enable|disable}
Date: Tue, 15 Feb 2005 13:33:07 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0502151143080.30336-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

2 use netif_poll_{enable|disable} to synchronize between poll and i/f down/up
Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.4/drivers/net/e1000/e1000_main.c net-drivers-2.4/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.4/drivers/net/e1000/e1000_main.c	2005-02-01 23:21:49.122101856 -0800
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_main.c	2005-02-01 23:21:50.517889664 -0800
@@ -303,6 +303,9 @@ e1000_up(struct e1000_adapter *adapter)
 	mod_timer(&adapter->watchdog_timer, jiffies);
 	e1000_irq_enable(adapter);
 
+#ifdef CONFIG_E1000_NAPI
+	netif_poll_enable(netdev);
+#endif
 	return 0;
 }
 
@@ -316,6 +319,10 @@ e1000_down(struct e1000_adapter *adapter
 	del_timer_sync(&adapter->tx_fifo_stall_timer);
 	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_info_timer);
+
+#ifdef CONFIG_E1000_NAPI
+	netif_poll_disable(netdev);
+#endif
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
 	netif_carrier_off(netdev);
	
