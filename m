From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.5 2/3] e100: Fix set ringparam for ethtool returning error
 code on bad input
Date: Mon, 18 Oct 2004 03:23:49 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410180310370.20965-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>

diff -up netdev-2.6/drivers/net/e100.c netdev-2.6/drivers/net/e100.new.c
--- netdev-2.6/drivers/net/e100.c	2004-10-15 12:27:00.000000000 -0700
+++ netdev-2.6/drivers/net/e100.c.new	2004-10-15 12:27:01.000000000 -0700
@@ -1958,6 +1958,9 @@ static int e100_set_ringparam(struct net
 	struct param_range *rfds = &nic->params.rfds;
 	struct param_range *cbs = &nic->params.cbs;
 
+	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending)) 
+		return -EINVAL;
+
 	if(netif_running(netdev))
 		e100_down(nic);
 	rfds->count = max(ring->rx_pending, rfds->min);
