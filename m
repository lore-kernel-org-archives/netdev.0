From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/16) irda -- no self destruct
Date: Tue, 30 Sep 2003 14:58:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930145838.638ea0b4.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller"
 <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

For 2.6.0-test6 get rid of destructor for irda devices.
Most of the drivers already call free_netdev themselves.  
Any drivers not calling free_netdev will be fixed in this patch sequence.

diff -Nru a/net/irda/irda_device.c b/net/irda/irda_device.c
--- a/net/irda/irda_device.c	Tue Sep 30 11:56:16 2003
+++ b/net/irda/irda_device.c	Tue Sep 30 11:56:16 2003
@@ -378,8 +378,6 @@
         dev->hard_header_len = 0;
         dev->addr_len        = 0;
 
-	dev->destructor      = free_netdev;
-
         dev->type            = ARPHRD_IRDA;
         dev->tx_queue_len    = 8; /* Window size + 1 s-frame */
 
