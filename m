From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 6/6] neigh: use standard interface to modify timer
Date: Fri, 15 May 2015 14:55:46 +0800
Message-ID: <1431672946-300-7-git-send-email-ying.xue@windriver.com>
References: <1431672946-300-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <alexei@purestorage.com>,
	<joern@purestorage.com>, <ja@ssi.bg>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:48104 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754509AbbEOG4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 02:56:13 -0400
In-Reply-To: <1431672946-300-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Should use standard interface - neigh_add_timer() to modify neigh
timer.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/core/neighbour.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 67a0e42..d7c2d36 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -939,8 +939,7 @@ static void neigh_timer_handler(unsigned long arg)
 	if (neigh->nud_state & NUD_IN_TIMER) {
 		if (time_before(next, jiffies + HZ/2))
 			next = jiffies + HZ/2;
-		if (!mod_timer(&neigh->timer, next))
-			neigh_hold(neigh);
+		neigh_add_timer(neigh, next);
 	}
 	if (neigh->nud_state & (NUD_INCOMPLETE | NUD_PROBE)) {
 		neigh_probe(neigh);
-- 
1.7.9.5
