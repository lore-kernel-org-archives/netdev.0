From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 7/16 2.5] ixgb: prevent infinite loop trying to re-establish
 link while actively communicating
Date: Fri, 15 Oct 2004 06:55:08 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150630370.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c	2004-10-05 15:50:18.000000000 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c	2004-10-05 17:55:48.000000000 -0700
@@ -1405,10 +1405,8 @@ static void ixgb_tx_timeout(struct net_d
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 
-	netif_device_detach(netdev);
 	ixgb_down(adapter, TRUE);
 	ixgb_up(adapter);
-	netif_device_attach(netdev);
 }
 
 /**
