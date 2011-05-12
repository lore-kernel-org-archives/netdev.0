From: frank.blaschka@de.ibm.com
Subject: [patch 5/9] [PATCH] lcs: get rid of compile warning
Date: Thu, 12 May 2011 07:43:23 +0200
Message-ID: <20110512054415.866413564@de.ibm.com>
References: <20110512054318.241733700@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Heiko Carstens <heiko.carstens@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([194.196.100.166]:44911 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753705Ab1ELFoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 01:44:18 -0400
Content-Disposition: inline; filename=604-lcs-compile-warning.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Carstens <heiko.carstens@de.ibm.com>

-Wunused-but-set-variable generates a compile warning for lcs' tasklet
function. Invoked functions contain already error handling; thus
additional return code checking is not needed here.

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---


 drivers/s390/net/lcs.c |   10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)
diff -urpN linux-2.6/drivers/s390/net/lcs.c linux-2.6-patched/drivers/s390/net/lcs.c
--- linux-2.6/drivers/s390/net/lcs.c	2011-05-10 09:14:06.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/lcs.c	2011-05-10 09:14:25.000000000 +0200
@@ -1483,7 +1483,6 @@ lcs_tasklet(unsigned long data)
 	struct lcs_channel *channel;
 	struct lcs_buffer *iob;
 	int buf_idx;
-	int rc;
 
 	channel = (struct lcs_channel *) data;
 	LCS_DBF_TEXT_(5, trace, "tlet%s", dev_name(&channel->ccwdev->dev));
@@ -1500,14 +1499,11 @@ lcs_tasklet(unsigned long data)
 	channel->buf_idx = buf_idx;
 
 	if (channel->state == LCS_CH_STATE_STOPPED)
-		// FIXME: what if rc != 0 ??
-		rc = lcs_start_channel(channel);
+		lcs_start_channel(channel);
 	spin_lock_irqsave(get_ccwdev_lock(channel->ccwdev), flags);
 	if (channel->state == LCS_CH_STATE_SUSPENDED &&
-	    channel->iob[channel->io_idx].state == LCS_BUF_STATE_READY) {
-		// FIXME: what if rc != 0 ??
-		rc = __lcs_resume_channel(channel);
-	}
+	    channel->iob[channel->io_idx].state == LCS_BUF_STATE_READY)
+		__lcs_resume_channel(channel);
 	spin_unlock_irqrestore(get_ccwdev_lock(channel->ccwdev), flags);
 
 	/* Something happened on the channel. Wake up waiters. */

