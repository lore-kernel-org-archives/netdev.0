From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.4 4/16] e1000:Enable polling before
 enabling interrupts
Date: Thu, 28 Apr 2005 20:11:08 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504281958590.30085-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Enable polling before enabling interrupts -- avoids (in NAPI mode) entering the ISR and returning without doing any work because polling is not enabled. [romieu@fr.zoriel.com]

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.4/drivers/net/e1000/e1000_main.c net-drivers-2.4/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.4/drivers/net/e1000/e1000_main.c	2005-04-12 23:00:53.000000000 -0700
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_main.c	2005-04-12 23:00:55.000000000 -0700
@@ -325,11 +325,12 @@ e1000_up(struct e1000_adapter *adapter)
 		return err;
 
 	mod_timer(&adapter->watchdog_timer, jiffies);
-	e1000_irq_enable(adapter);
 
 #ifdef CONFIG_E1000_NAPI
 	netif_poll_enable(netdev);
 #endif
+	e1000_irq_enable(adapter);
+
 	return 0;
 }
 
