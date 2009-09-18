From: akpm@linux-foundation.org
Subject: [patch 1/6] isdn: hisax, fix lock imbalance
Date: Fri, 18 Sep 2009 12:53:01 -0700
Message-ID: <200909181953.n8IJr1Wl026154@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jirislaby@gmail.com, Karsten-Keil@t-online.de
To: isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45478 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754105AbZIRTxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2009 15:53:53 -0400
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
@@ -594,6 +594,7 @@ Amd7930_l1hw(struct PStack *st, int pr, 
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
@@ -468,6 +468,7 @@ ICC_l1hw(struct PStack *st, int pr, void
 				if (cs->debug & L1_DEB_WARN)
 					debugl1(cs, " l2l1 tx_skb exist this shouldn't happen");
 				skb_queue_tail(&cs->sq, skb);
+				spin_unlock_irqrestore(&cs->lock, flags);
 				break;
 			}
 			if (cs->debug & DEB_DLOG_HEX)
_
