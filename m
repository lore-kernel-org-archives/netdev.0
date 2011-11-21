From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [PATCH 2/5] atm: clip: Don't move counters backwards
Date: Mon, 21 Nov 2011 21:25:55 +0100
Message-ID: <1321907158-27857-3-git-send-email-jorge@dti2.net>
References: <1321907158-27857-1-git-send-email-jorge@dti2.net>
Reply-To: jorge@dti2.net
Cc: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
To: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:56413 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754227Ab1KUU0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 15:26:18 -0500
Received: from nikopol.intranet.dti2.net ([81.24.160.13])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v12.5.0)
	with ESMTP id md50019764595.msg
	for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 21:26:15 +0100
In-Reply-To: <1321907158-27857-1-git-send-email-jorge@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>

    I don't see the point on substracting the skb len from the netdev stats.

Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
---
 net/atm/clip.c |   10 +---------
 1 files changed, 1 insertions(+), 9 deletions(-)

diff --git a/net/atm/clip.c b/net/atm/clip.c
index 8523940..3cb9470 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -484,16 +484,8 @@ static int clip_mkip(struct atm_vcc *vcc, int timeout)
 		if (!clip_devs) {
 			atm_return(vcc, skb->truesize);
 			kfree_skb(skb);
-		} else {
-			struct net_device *dev = skb->dev;
-			unsigned int len = skb->len;
-
-			skb_get(skb);
+		} else
 			clip_push(vcc, skb);
-			dev->stats.rx_packets--;
-			dev->stats.rx_bytes -= len;
-			kfree_skb(skb);
-		}
 	}
 	return 0;
 }
-- 
1.7.7.1
