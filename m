From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (10/16) smsc-ircc2 -- use unregister_netdev
Date: Tue, 30 Sep 2003 15:21:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930152136.73c68299.shemminger@osdl.org>
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

No need to expose rtnl_lock, it is done in unregister_netdev.

diff -Nru a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
--- a/drivers/net/irda/smsc-ircc2.c	Tue Sep 30 11:56:14 2003
+++ b/drivers/net/irda/smsc-ircc2.c	Tue Sep 30 11:56:14 2003
@@ -1745,11 +1745,8 @@
 		pm_unregister(self->pmdev);
 
 	/* Remove netdevice */
-	if (self->netdev) {
-		rtnl_lock();
-		unregister_netdevice(self->netdev);
-		rtnl_unlock();
-	}
+	if (self->netdev) 
+		unregister_netdev(self->netdev);
 
 	/* Make sure the irq handler is not exectuting */
 	spin_lock_irqsave(&self->lock, flags);
