From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (11/16) smsc-ircc2 -- register_netdev
Date: Tue, 30 Sep 2003 15:21:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930152144.3e3e3353.shemminger@osdl.org>
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

Again, smsc doesn't need to use rtnl, it is take care of by using
register_netdev.

diff -Nru a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
--- a/drivers/net/irda/smsc-ircc2.c	Tue Sep 30 14:26:14 2003
+++ b/drivers/net/irda/smsc-ircc2.c	Tue Sep 30 14:26:14 2003
@@ -672,9 +672,7 @@
 	dev->base_addr = self->io.fir_base;
 	dev->irq = self->io.irq;
 
-	rtnl_lock();
-	err = register_netdevice(dev);
-	rtnl_unlock();
+	err = register_netdev(dev);
 	if (err) {
 		ERROR("%s(), register_netdev() failed!\n", __FUNCTION__);
 		kfree(self->tx_buff.head);
