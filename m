From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 02/10] net: Use SKB_WITH_OVERHEAD in build_skb
Date: Tue, 10 Apr 2012 15:26:16 +0100
Message-ID: <1334067984-7706-2-git-send-email-ian.campbell@citrix.com>
References: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xen.org,
	Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:56112 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758789Ab2DJOck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 10:32:40 -0400
In-Reply-To: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
---
 net/core/skbuff.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 59a1ecb..d4e139e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -264,7 +264,7 @@ struct sk_buff *build_skb(void *data)
 	if (!skb)
 		return NULL;
 
-	size = ksize(data) - SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+	size = SKB_WITH_OVERHEAD(ksize(data));
 
 	memset(skb, 0, offsetof(struct sk_buff, tail));
 	skb->truesize = SKB_TRUESIZE(size);
-- 
1.7.2.5
