From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 4/9] [PATCH] claw: invalid return codes from hard_start_xmit
Date: Tue, 24 Mar 2009 13:29:08 +0100
Message-ID: <20090324124335.784434000@linux.vnet.ibm.com>
References: <20090324122904.744942000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:57234 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757603AbZCXMnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 08:43:39 -0400
Content-Disposition: inline; filename=611-claw-rc-warning.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Avoid kernel warnings by using the correct hard_start_xmit return
code NETDEV_TX_BUSY for skb requeuing.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 drivers/s390/net/claw.c |    2 ++
 1 file changed, 2 insertions(+)

diff -urpN linux-2.6/drivers/s390/net/claw.c linux-2.6-patched/drivers/s390/net/claw.c
--- linux-2.6/drivers/s390/net/claw.c	2008-12-25 00:26:37.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/claw.c	2009-03-04 15:58:30.000000000 +0100
@@ -335,6 +335,8 @@ claw_tx(struct sk_buff *skb, struct net_
         rc=claw_hw_tx( skb, dev, 1 );
         spin_unlock_irqrestore(get_ccwdev_lock(p_ch->cdev), saveflags);
 	CLAW_DBF_TEXT_(4, trace, "clawtx%d", rc);
+	if (rc)
+		rc = NETDEV_TX_BUSY;
         return rc;
 }   /*  end of claw_tx */
 

