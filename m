From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 4/16 2.5] ixgb: Fix NAPI driver crash on ifdown during traffic
Date: Fri, 15 Oct 2004 06:54:31 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150624070.31227-100000@isotope.jf.intel.com>
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
@@ -1652,6 +1652,7 @@ static irqreturn_t ixgb_intr(int irq, vo
 		netif_rx_complete(netdev);
 		/* RAIDC will be automatically restarted by irq_enable */
 		ixgb_irq_enable(adapter);
+		return 0;
 	}
 
 	return (work_done >= work_to_do);
