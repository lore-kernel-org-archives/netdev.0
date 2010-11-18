From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 2.6.37-rc2] Fix duplicate volatile warning.
Date: Thu, 18 Nov 2010 13:03:19 +0900
Message-ID: <201011180403.oAI43JBT005077@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:53823 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698Ab0KREDX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 23:03:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 0ed8ddf4 "neigh: Protect neigh->ha[] with a seqlock" made gcc 3.x
to warn

  include/net/neighbour.h: In function `neigh_event_send':
  include/net/neighbour.h:306: warning: duplicate `volatile'

.
----------------------------------------
>From a391f571f21bfa81369599f03e86fa75589291a3 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Thu, 18 Nov 2010 12:44:26 +0900
Subject: [PATCH 2.6.37-rc2] Fix duplicate volatile warning.

jiffies is defined as "volatile".

  extern unsigned long volatile __jiffy_data jiffies;

ACCESS_ONCE() uses "volatile".
As a result, some compilers warn duplicate `volatile' for ACCESS_ONCE(jiffies).

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/net/neighbour.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 55590ab..6beb1ff 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -303,7 +303,7 @@ static inline void neigh_confirm(struct neighbour *neigh)
 
 static inline int neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 {
-	unsigned long now = ACCESS_ONCE(jiffies);
+	unsigned long now = jiffies;
 	
 	if (neigh->used != now)
 		neigh->used = now;
-- 
1.7.1

