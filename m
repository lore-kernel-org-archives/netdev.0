From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] memory leak in irda/sa1100_ir.c
Date: Thu, 9 Oct 2003 09:37:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031009093752.01a374bc.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This driver seems confused about what get done for it on module exit.
It needs to free the network device it created.

Patch against 2.6.0-test7

diff -urN -X dontdiff linux-2.5/drivers/net/irda/sa1100_ir.c linux-2.5-net/drivers/net/irda/sa1100_ir.c
--- linux-2.5/drivers/net/irda/sa1100_ir.c	2003-09-30 13:53:58.000000000 -0700
+++ linux-2.5-net/drivers/net/irda/sa1100_ir.c	2003-09-17 15:49:30.000000000 -0700
@@ -1132,12 +1132,8 @@
 	release_mem_region(__PREG(Ser2HSCR0), 0x1c);
 	release_mem_region(__PREG(Ser2UTCR0), 0x24);
 
-	/*
-	 * We now know that the netdevice is no longer in use, and all
-	 * references to our driver have been removed.  The only structure
-	 * which may still be present is the netdevice, which will get
-	 * cleaned up by net/core/dev.c
-	 */
+	if(dev)
+		free_netdev(dev);
 }
 
 static int __init sa1100ir_setup(char *line)
