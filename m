From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH netdev-2.6 3/10] ixgb: Prevent infinite loop trying to
 re-establish link while actively communicating
Date: Fri, 29 Oct 2004 05:09:22 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410290447340.26064-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: ganesh venkatesan <ganesh.venkatesan@intel.com>

diff -up netdev-2.6/drivers/net/ixgb/ixgb_main.c netdev-2.6/drivers/net/ixgb.new/ixgb_main.c
--- netdev-2.6/drivers/net/ixgb/ixgb_main.c	2004-10-15 13:15:38.000000000 -0700
+++ netdev-2.6/drivers/net/ixgb.new/ixgb_main.c	2004-10-15 13:15:55.000000000 -0700
@@ -1404,10 +1404,8 @@ static void ixgb_tx_timeout(struct net_d
 {
 	struct ixgb_adapter *adapter = netdev->priv;
 
-	netif_device_detach(netdev);
 	ixgb_down(adapter, TRUE);
 	ixgb_up(adapter);
-	netif_device_attach(netdev);
 }
 
 /**
