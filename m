From: Patrick McHardy <kaber@trash.net>
Subject: net: fix network drivers ndo_start_xmit() return values (part 5)
Date: Fri, 12 Jun 2009 17:13:07 +0200
Message-ID: <4A327083.5050701@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000205090105010309060006"
Cc: Linux Netdev List <netdev@vger.kernel.org>, ursula.braun@de.ibm.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47190 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751760AbZFLPNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 11:13:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000205090105010309060006
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------000205090105010309060006
Content-Type: text/x-patch;
 name="05.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="05.diff"

commit a457e7b57fba9fe2209890bb068ecae60285d0db
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Jun 12 17:07:07 2009 +0200

    net: fix network drivers ndo_start_xmit() return values (part 5)
    
    Fix up s390 drivers that return an errno value to qdisc_restart(), causing
    qdisc_restart() to print a warning an requeue/retransmit the skb.
    
    - claw: impossible condition, simply remove it
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/drivers/s390/net/claw.c b/drivers/s390/net/claw.c
index 30a43cc..7b6f46d 100644
--- a/drivers/s390/net/claw.c
+++ b/drivers/s390/net/claw.c
@@ -338,12 +338,6 @@ claw_tx(struct sk_buff *skb, struct net_device *dev)
 
 	CLAW_DBF_TEXT(4, trace, "claw_tx");
         p_ch=&privptr->channel[WRITE];
-        if (skb == NULL) {
-                privptr->stats.tx_dropped++;
-		privptr->stats.tx_errors++;
-		CLAW_DBF_TEXT_(2, trace, "clawtx%d", -EIO);
-                return -EIO;
-        }
         spin_lock_irqsave(get_ccwdev_lock(p_ch->cdev), saveflags);
         rc=claw_hw_tx( skb, dev, 1 );
         spin_unlock_irqrestore(get_ccwdev_lock(p_ch->cdev), saveflags);

--------------000205090105010309060006--
