From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.9-rc4-bk3-netdev3 2/3] r8169: unneeded synchronize_irq()
Date: Tue, 19 Oct 2004 01:09:50 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018230948.GA27418@electric-eye.fr.zoreil.com>
References: <20041018230823.GB19990@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20041018230823.GB19990@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

synchronize_irq() is not needed as it is already issued by free_irq().

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-230 drivers/net/r8169.c
--- linux-2.6.9/drivers/net/r8169.c~r8169-230	2004-10-18 23:37:30.000000000 +0200
+++ linux-2.6.9-fr/drivers/net/r8169.c	2004-10-18 23:37:58.000000000 +0200
@@ -2259,7 +2259,6 @@ rtl8169_close(struct net_device *dev)
 
 	spin_unlock_irq(&tp->lock);
 
-	synchronize_irq(dev->irq);
 	free_irq(dev->irq, dev);
 
 	netif_poll_disable(dev);

_
