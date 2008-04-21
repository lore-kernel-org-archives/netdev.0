From: Mark Asselstine <mark.asselstine@windriver.com>
Subject: [PATCH] Remove unneeded and deprecated cli()/sti() calls.
Date: Mon, 21 Apr 2008 15:49:10 -0400
Message-ID: <1208807350-10618-1-git-send-email-mark.asselstine@windriver.com>
Cc: netdev@vger.kernel.org, asselsm@gmail.com, klaus.kudielka@ieee.org,
	linux-hams@vger.kernel.org,
	Mark Asselstine <mark.asselstine@windriver.com>
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:37399 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751248AbYDUTtQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 15:49:16 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These cli()/sti() calls are made in start_timer() and are therefor
redundant since the register_lock is now used to protect register
io from within scc_isr() and write_scc() (where all calls to
start_timer() originate).

Signed-off-by: Mark Asselstine <mark.asselstine@windriver.com>
---
 drivers/net/hamradio/dmascc.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/hamradio/dmascc.c b/drivers/net/hamradio/dmascc.c
index e04bf99..0b94833 100644
--- a/drivers/net/hamradio/dmascc.c
+++ b/drivers/net/hamradio/dmascc.c
@@ -1083,15 +1083,12 @@ static void start_timer(struct scc_priv *priv, int t, int r15)
 	if (t == 0) {
 		tm_isr(priv);
 	} else if (t > 0) {
-		save_flags(flags);
-		cli();
 		outb(t & 0xFF, priv->tmr_cnt);
 		outb((t >> 8) & 0xFF, priv->tmr_cnt);
 		if (priv->type != TYPE_TWIN) {
 			write_scc(priv, R15, r15 | CTSIE);
 			priv->rr0 |= CTS;
 		}
-		restore_flags(flags);
 	}
 }
 
-- 
1.5.4.3

