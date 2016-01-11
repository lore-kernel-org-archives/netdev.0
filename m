From: John Fastabend <john.fastabend@gmail.com>
Subject: [PATCH] net: pktgen: fix null ptr deref in skb allocation
Date: Sun, 10 Jan 2016 21:38:44 -0800
Message-ID: <20160111053844.3695.82965.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bogdan.hamciuc@freescale.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34184 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751036AbcAKFi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 00:38:59 -0500
Received: by mail-pf0-f182.google.com with SMTP id q63so40537631pfb.1
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 21:38:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix possible null pointer dereference that may occur when calling
skb_reserve() on a null skb.

Fixes: 879c7220e82 ("net: pktgen: Observe needed_headroom of the device")
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/core/pktgen.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index de8d5cc..4da4d51 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2787,7 +2787,9 @@ static struct sk_buff *pktgen_alloc_skb(struct net_device *dev,
 	} else {
 		 skb = __netdev_alloc_skb(dev, size, GFP_NOWAIT);
 	}
-	skb_reserve(skb, LL_RESERVED_SPACE(dev));
+
+	if (likely(skb))
+		skb_reserve(skb, LL_RESERVED_SPACE(dev));
 
 	return skb;
 }
