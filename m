From: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH] net sched: text ematch: zero out ts_state before using it
Date: Thu,  9 Oct 2014 09:05:21 -0700
Message-ID: <1412870721-31061-1-git-send-email-osandov@osandov.com>
Cc: Omar Sandoval <osandov@osandov.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:58727 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372AbaJIQFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 12:05:49 -0400
Received: by mail-pd0-f178.google.com with SMTP id y10so30936pdj.23
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2014 09:05:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

textsearch_find zeroes out the offset, but the control buffer (which may or may
not matter in this case) needs to be zeroed out as well.

Signed-off-by: Omar Sandoval <osandov@osandov.com>
---
 net/sched/em_text.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sched/em_text.c b/net/sched/em_text.c
index 15d353d..2a1b6d9 100644
--- a/net/sched/em_text.c
+++ b/net/sched/em_text.c
@@ -36,6 +36,8 @@ static int em_text_match(struct sk_buff *skb, struct tcf_ematch *m,
 	int from, to;
 	struct ts_state state;
 
+	memset(&state, 0, sizeof(state));
+
 	from = tcf_get_base_ptr(skb, tm->from_layer) - skb->data;
 	from += tm->from_offset;
 
-- 
2.1.2
