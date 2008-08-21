From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 4/4] LCS recovery dumps when cable reconnect
Date: Thu, 21 Aug 2008 17:10:25 +0200
Message-ID: <20080821151654.326848000@linux.vnet.ibm.com>
References: <20080821151021.069615000@linux.vnet.ibm.com>
Cc: "Klaus-D. Wacker" <kdwacker@de.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:34673 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757375AbYHUPRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 11:17:05 -0400
Content-Disposition: inline; filename=603-lcs-recovery.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Klaus-D. Wacker <kdwacker@de.ibm.com>

LCS recovery dumps in irq routine when CCW address in
Subchannel Status Word (SCSW) is zero. This occurs
when recovery is driven after cable reconnect.

Signed-off-by: Klaus-D. Wacker <kdwacker@de.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 drivers/s390/net/lcs.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -urpN linux-2.6/drivers/s390/net/lcs.c linux-2.6-patched/drivers/s390/net/lcs.c
--- linux-2.6/drivers/s390/net/lcs.c	2008-08-20 15:54:46.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/lcs.c	2008-08-20 15:55:15.000000000 +0200
@@ -1412,7 +1412,8 @@ lcs_irq(struct ccw_device *cdev, unsigne
 	}
 	/* How far in the ccw chain have we processed? */
 	if ((channel->state != LCS_CH_STATE_INIT) &&
-	    (irb->scsw.cmd.fctl & SCSW_FCTL_START_FUNC)) {
+	    (irb->scsw.cmd.fctl & SCSW_FCTL_START_FUNC) &&
+	    (irb->scsw.cmd.cpa != 0)) {
 		index = (struct ccw1 *) __va((addr_t) irb->scsw.cmd.cpa)
 			- channel->ccws;
 		if ((irb->scsw.cmd.actl & SCSW_ACTL_SUSPENDED) ||

-- 
