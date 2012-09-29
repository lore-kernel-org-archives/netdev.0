From: Weiping Pan <wpan@redhat.com>
Subject: [PATCH net] use skb_end_offset() in skb_try_coalesce()
Date: Sat, 29 Sep 2012 14:15:30 +0800
Message-ID: <6f3540c213735f009409d1cc7d3fe0dea91469d9.1348899174.git.wpan@redhat.com>
Cc: Weiping Pan <wpan@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2711 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752721Ab2I2GOF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Sep 2012 02:14:05 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q8T6E4Kh012031
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Sat, 29 Sep 2012 02:14:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit ec47ea824774(skb: Add inline helper for getting the skb end offset from
head) introduces this helper function, skb_end_offset(),
we should make use of it.

Signed-off-by: Weiping Pan <wpan@redhat.com>
---
 net/core/skbuff.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e33ebae..86f040a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3488,8 +3488,7 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
 		    skb_shinfo(from)->nr_frags > MAX_SKB_FRAGS)
 			return false;
 
-		delta = from->truesize -
-			SKB_TRUESIZE(skb_end_pointer(from) - from->head);
+		delta = from->truesize - SKB_TRUESIZE(skb_end_offset(from));
 	}
 
 	WARN_ON_ONCE(delta < len);
-- 
1.7.4.4
