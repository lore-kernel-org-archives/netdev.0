From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] bcm43xx: return correct hard_start_xmit error code]
Date: Sat, 19 Aug 2006 10:56:28 -0500
Message-ID: <44E734AC.2090701@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:20432 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1750782AbWHSP4p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Aug 2006 11:56:45 -0400
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



John,

Please apply the following patch by Michael Buesch to wireless-2.6.

Larry

==============================

hard_start_xmit should return a NETIF_TX_FOO error code.

Signed-off-by: Michael Buesch <mb@bu3sch.de>
Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c	
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c	
@@ -3918,7 +3918,9 @@
  		err = bcm43xx_tx(bcm, txb);
  	spin_unlock_irqrestore(&bcm->irq_lock, flags);

-	return err;
+	if (unlikely(err))
+		return NETDEV_TX_BUSY;
+	return NETDEV_TX_OK;
  }

  static struct net_device_stats * bcm43xx_net_get_stats(struct net_device *net_dev)



