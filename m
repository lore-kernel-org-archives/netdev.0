From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH netdev-2.6 1/10] ixgb: Fix NAPI driver crash on ifdown during
 traffic
Date: Fri, 29 Oct 2004 05:08:07 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410290444200.26064-100000@isotope.jf.intel.com>
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
@@ -1655,6 +1655,7 @@ static irqreturn_t ixgb_intr(int irq, vo
 		netif_rx_complete(netdev);
 		/* RAIDC will be automatically restarted by irq_enable */
 		ixgb_irq_enable(adapter);
+		return 0;
 	}
 
 	return (work_done >= work_to_do);
