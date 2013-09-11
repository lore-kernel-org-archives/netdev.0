From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net_sched: htb: fix a typo in htb_change_class()
Date: Tue, 10 Sep 2013 17:36:37 -0700
Message-ID: <1378859797.26319.90.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Vimalkumar <j.vimal@gmail.com>, Jiri Pirko <jpirko@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f42.google.com ([209.85.213.42]:50572 "EHLO
	mail-yh0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100Ab3IKAnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 20:43:25 -0400
Received: by mail-yh0-f42.google.com with SMTP id z12so3276162yhz.15
        for <netdev@vger.kernel.org>; Tue, 10 Sep 2013 17:43:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vimalkumar <j.vimal@gmail.com>

Fix a typo added in commit 56b765b79 ("htb: improved accuracy at high
rates")

cbuffer should not be a copy of buffer.

Signed-off-by: Vimalkumar <j.vimal@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Jiri Pirko <jpirko@redhat.com>
---
 net/sched/sch_htb.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index c2178b1..863846c 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1495,7 +1495,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	psched_ratecfg_precompute(&cl->ceil, &hopt->ceil);
 
 	cl->buffer = PSCHED_TICKS2NS(hopt->buffer);
-	cl->cbuffer = PSCHED_TICKS2NS(hopt->buffer);
+	cl->cbuffer = PSCHED_TICKS2NS(hopt->cbuffer);
 
 	sch_tree_unlock(sch);
 
