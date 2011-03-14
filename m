From: huzaifas@redhat.com
Subject: [PATCH] Fix possible null pointer dereference in davinci_cpdma.c
Date: Mon, 14 Mar 2011 14:09:14 +0530
Message-ID: <1300091954-10367-1-git-send-email-huzaifas@redhat.com>
Cc: khilman@deeprootsystems.com, cyril@ti.com,
	Huzaifa Sidhpurwala <huzaifas@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23251 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752284Ab1CNIjT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 04:39:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huzaifa Sidhpurwala <huzaifas@redhat.com>

Check if chan exists before dereferencing it

Signed-off-by: Huzaifa Sidhpurwala <huzaifas@redhat.com>
---
 drivers/net/davinci_cpdma.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/davinci_cpdma.c b/drivers/net/davinci_cpdma.c
index e92b2b6..09620a6 100644
--- a/drivers/net/davinci_cpdma.c
+++ b/drivers/net/davinci_cpdma.c
@@ -526,12 +526,13 @@ err_chan_alloc:
 
 int cpdma_chan_destroy(struct cpdma_chan *chan)
 {
-	struct cpdma_ctlr *ctlr = chan->ctlr;
+	struct cpdma_ctlr *ctlr;
 	unsigned long flags;
 
 	if (!chan)
 		return -EINVAL;
 
+	ctrl = chan->ctrl;
 	spin_lock_irqsave(&ctlr->lock, flags);
 	if (chan->state != CPDMA_STATE_IDLE)
 		cpdma_chan_stop(chan);
-- 
1.7.3.4

