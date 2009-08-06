From: akpm@linux-foundation.org
Subject: [patch 1/3] isdn: hisax, fix lock imbalance
Date: Thu, 06 Aug 2009 16:06:23 -0700
Message-ID: <200908062306.n76N6OWI006378@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jirislaby@gmail.com, Karsten-Keil@t-online.de
To: isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58873 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756849AbZHFXG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 19:06:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Slaby <jirislaby@gmail.com>

Add omittted unlocks to 2 functions.

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
Cc: Karsten Keil <Karsten-Keil@t-online.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/hisax/amd7930_fn.c |    1 +
 drivers/isdn/hisax/icc.c        |    1 +
 2 files changed, 2 insertions(+)

diff -puN drivers/isdn/hisax/amd7930_fn.c~isdn-hisax-fix-lock-imbalance drivers/isdn/hisax/amd7930_fn.c
--- a/drivers/isdn/hisax/amd7930_fn.c~isdn-hisax-fix-lock-imbalance
+++ a/drivers/isdn/hisax/amd7930_fn.c
@@ -596,6 +596,7 @@ Amd7930_l1hw(struct PStack *st, int pr, 
 				if (cs->debug & L1_DEB_WARN)
 					debugl1(cs, "Amd7930: l1hw: l2l1 tx_skb exist this shouldn't happen");
 				skb_queue_tail(&cs->sq, skb);
+				spin_unlock_irqrestore(&cs->lock, flags);
 				break;
 			}
 			if (cs->debug & DEB_DLOG_HEX)
diff -puN drivers/isdn/hisax/icc.c~isdn-hisax-fix-lock-imbalance drivers/isdn/hisax/icc.c
--- a/drivers/isdn/hisax/icc.c~isdn-hisax-fix-lock-imbalance
+++ a/drivers/isdn/hisax/icc.c
@@ -470,6 +470,7 @@ ICC_l1hw(struct PStack *st, int pr, void
 				if (cs->debug & L1_DEB_WARN)
 					debugl1(cs, " l2l1 tx_skb exist this shouldn't happen");
 				skb_queue_tail(&cs->sq, skb);
+				spin_unlock_irqrestore(&cs->lock, flags);
 				break;
 			}
 			if (cs->debug & DEB_DLOG_HEX)
_
