From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: mv643xx(10/20): compile fix for non-NAPI case
Date: Mon, 28 Mar 2005 16:49:50 -0700
Message-ID: <20050328234950.GJ29098@xyzzy>
References: <20050328233807.GA28423@xyzzy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>, Manish Lachwani <mlachwani@mvista.com>,
        Brian Waite <brian@waitefamily.us>,
        "Steven J. Hill" <sjhill@realitydiluted.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        James Chapman <jchapman@katalix.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050328233807.GA28423@xyzzy>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Compiles for the non-NAPI configuration were broken. 

Signed-off-by: James Chapman <jchapman@katalix.com>
Acked-by: Dale Farnsworth <dale@farnsworth.org>

Index: linux-2.5-enet/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.5-enet.orig/drivers/net/mv643xx_eth.c
+++ linux-2.5-enet/drivers/net/mv643xx_eth.c
@@ -561,9 +561,10 @@
 								(port_num), 0);
 			__netif_rx_schedule(dev);
 		}
+	}
 #else
 		if (eth_int_cause & (BIT2 | BIT11))
-			mv643xx_eth_receive_queue(dev, 0);
+			mv643xx_eth_receive_queue(dev);
 
 		/*
 		 * After forwarded received packets to upper layer, add a task
@@ -580,7 +581,6 @@
 		mp->rx_task.func(dev);
 #endif
 #endif
-	}
 	/* PHY status changed */
 	if (eth_int_cause_ext & (BIT16 | BIT20)) {
 		struct ethtool_cmd cmd;
