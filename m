From: akpm@linux-foundation.org
Subject: [patch 2/8] netfilter: xt_time gives a wrong monthday in a leap year
Date: Mon, 22 Sep 2008 14:50:36 -0700
Message-ID: <200809222150.m8MLoaXW031860@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	kaih.luo@gmail.com, jengelh@computergmbh.de, kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54831 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753448AbYIVVvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 17:51:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kaihui Luo <kaih.luo@gmail.com>

The function localtime_3 in xt_time.c gives a wrong monthday in a leap
year after 28th 2.  calculating monthday should use the array
days_since_leapyear[] not days_since_year[] in a leap year.

Signed-off-by: Kaihui Luo <kaih.luo@gmail.com>
Acked-by: Jan Engelhardt <jengelh@computergmbh.de>
Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/netfilter/xt_time.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff -puN net/netfilter/xt_time.c~netfilter-xt_time-gives-a-wrong-monthday-in-a-leap-year net/netfilter/xt_time.c
--- a/net/netfilter/xt_time.c~netfilter-xt_time-gives-a-wrong-monthday-in-a-leap-year
+++ a/net/netfilter/xt_time.c
@@ -136,17 +136,19 @@ static void localtime_3(struct xtm *r, t
 	 * from w repeatedly while counting.)
 	 */
 	if (is_leap(year)) {
+		/* use days_since_leapyear[] in a leap year */
 		for (i = ARRAY_SIZE(days_since_leapyear) - 1;
-		    i > 0 && days_since_year[i] > w; --i)
+		    i > 0 && days_since_leapyear[i] > w; --i)
 			/* just loop */;
+		r->monthday = w - days_since_leapyear[i] + 1;
 	} else {
 		for (i = ARRAY_SIZE(days_since_year) - 1;
 		    i > 0 && days_since_year[i] > w; --i)
 			/* just loop */;
+		r->monthday = w - days_since_year[i] + 1;
 	}
 
 	r->month    = i + 1;
-	r->monthday = w - days_since_year[i] + 1;
 	return;
 }
 
_
