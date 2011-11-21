From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [PATCH 1/5] atm: br2684: Do not move counters backwards
Date: Mon, 21 Nov 2011 21:25:54 +0100
Message-ID: <1321907158-27857-2-git-send-email-jorge@dti2.net>
References: <1321907158-27857-1-git-send-email-jorge@dti2.net>
Reply-To: jorge@dti2.net
Cc: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
To: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:56411 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754388Ab1KUU0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 15:26:18 -0500
Received: from nikopol.intranet.dti2.net ([81.24.160.13])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v12.5.0)
	with ESMTP id md50019764593.msg
	for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 21:26:15 +0100
In-Reply-To: <1321907158-27857-1-git-send-email-jorge@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>

    This snippet has caused several bugs in the past, and I don't see the
point on substracting the skb len from netdev stats.

Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
---
 net/atm/br2684.c |    9 +--------
 1 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index d07223c..81cf33b 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -557,15 +557,8 @@ static int br2684_regvcc(struct atm_vcc *atmvcc, void __user * arg)
 	skb_queue_splice_init(rq, &queue);
 	spin_unlock_irqrestore(&rq->lock, flags);
 
-	skb_queue_walk_safe(&queue, skb, tmp) {
-		struct net_device *dev;
-
+	skb_queue_walk_safe(&queue, skb, tmp)
 		br2684_push(atmvcc, skb);
-		dev = skb->dev;
-
-		dev->stats.rx_bytes -= skb->len;
-		dev->stats.rx_packets--;
-	}
 
 	/* initialize netdev carrier state */
 	if (atmvcc->dev->signal == ATM_PHY_SIG_LOST)
-- 
1.7.7.1
