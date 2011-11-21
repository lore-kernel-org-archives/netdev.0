From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [PATCH 3/5] atm: clip: move clip_devs check to clip_push
Date: Mon, 21 Nov 2011 21:25:56 +0100
Message-ID: <1321907158-27857-4-git-send-email-jorge@dti2.net>
References: <1321907158-27857-1-git-send-email-jorge@dti2.net>
Reply-To: jorge@dti2.net
Cc: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
To: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:56415 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754405Ab1KUU0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 15:26:18 -0500
Received: from nikopol.intranet.dti2.net ([81.24.160.13])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v12.5.0)
	with ESMTP id md50019764596.msg
	for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 21:26:15 +0100
In-Reply-To: <1321907158-27857-1-git-send-email-jorge@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>

    This will allow further cleanup.

Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
---
 net/atm/clip.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/net/atm/clip.c b/net/atm/clip.c
index 3cb9470..521b45b 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -189,6 +189,13 @@ static void clip_push(struct atm_vcc *vcc, struct sk_buff *skb)
 	struct clip_vcc *clip_vcc = CLIP_VCC(vcc);
 
 	pr_debug("\n");
+
+	if (!clip_devs) {
+		atm_return(vcc, skb->truesize);
+		kfree_skb(skb);
+		return;
+	}
+
 	if (!skb) {
 		pr_debug("removing VCC %p\n", clip_vcc);
 		if (clip_vcc->entry)
@@ -480,13 +487,9 @@ static int clip_mkip(struct atm_vcc *vcc, int timeout)
 	spin_unlock_irqrestore(&rq->lock, flags);
 
 	/* re-process everything received between connection setup and MKIP */
-	skb_queue_walk_safe(&queue, skb, tmp) {
-		if (!clip_devs) {
-			atm_return(vcc, skb->truesize);
-			kfree_skb(skb);
-		} else
-			clip_push(vcc, skb);
-	}
+	skb_queue_walk_safe(&queue, skb, tmp)
+		clip_push(vcc, skb);
+
 	return 0;
 }
 
-- 
1.7.7.1
