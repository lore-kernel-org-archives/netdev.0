From: ganesh.venkatesan@intel.com
Subject: [PATCH 5/12 2.4] e1000 - avoid infinite loop while trying to
 re-establish link
Date: Thu, 29 Jul 2004 08:29:55 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0407290730460.21929-100000@westville2.jf.intel.com>
Reply-To: ganesh.venkatesan@intel.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.4/drivers/net/e1000/e1000_main.c linux-2.4/drivers/net/e1000.new/e1000_main.c
--- linux-2.4/drivers/net/e1000/e1000_main.c	2004-07-28 08:47:08.177582000 -0700
+++ linux-2.4/drivers/net/e1000.new/e1000_main.c	2004-07-28 08:47:09.559371936 -0700
@@ -1842,10 +1842,8 @@ e1000_tx_timeout_task(struct net_device 
 {
 	struct e1000_adapter *adapter = netdev->priv;
 
-	netif_device_detach(netdev);
 	e1000_down(adapter);
 	e1000_up(adapter);
-	netif_device_attach(netdev);
 }
 
 /**
