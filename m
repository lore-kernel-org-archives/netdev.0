From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 3/5 2.4] e1000: fix set ringparam for ethtool returning error
 code on bad input
Date: Fri, 15 Oct 2004 06:51:18 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150530300.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.4/drivers/net/e1000/e1000_ethtool.c linux-2.4/drivers/net/e1000.new/e1000_ethtool.c
--- linux-2.4/drivers/net/e1000/e1000_ethtool.c	2004-10-07 09:11:14.000000000 -0700
+++ linux-2.4/drivers/net/e1000.new/e1000_ethtool.c	2004-10-07 09:11:17.000000000 -0700
@@ -593,6 +593,9 @@ e1000_set_ringparam(struct net_device *n
 	tx_old = adapter->tx_ring;
 	rx_old = adapter->rx_ring;
 
+	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending)) 
+		return -EINVAL;
+
 	if(netif_running(adapter->netdev))
 		e1000_down(adapter);
 
 
