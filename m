From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.12-rc6] b44: check link state during open
Date: Wed, 8 Jun 2005 15:11:57 -0400
Message-ID: <20050608191156.GA28376@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Check the link state during b44_open.  This closes a 1 HZ window
that existed after b44_open ran but before the b44_timer handler ran,
during which ethtool would report "Link detected: yes" no matter what
the link state actually was.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/b44.c |    3 +++
 1 files changed, 3 insertions(+)

--- linux-2.6.12-rc6/drivers/net/b44.c.orig	2005-06-08 14:52:35.000000000 -0400
+++ linux-2.6.12-rc6/drivers/net/b44.c	2005-06-08 14:52:43.000000000 -0400
@@ -1285,6 +1285,9 @@ static int b44_open(struct net_device *d
 	b44_init_hw(bp);
 	bp->flags |= B44_FLAG_INIT_COMPLETE;
 
+	netif_carrier_off(dev);
+	b44_check_phy(bp);
+
 	spin_unlock_irq(&bp->lock);
 
 	init_timer(&bp->timer);
-- 
John W. Linville
linville@tuxdriver.com
