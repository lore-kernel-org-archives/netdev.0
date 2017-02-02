From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: remove useless pfmemalloc setting
Date: Wed, 01 Feb 2017 18:13:23 -0800
Message-ID: <1486001603.13103.10.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485983078-2372-1-git-send-email-jbacik@fb.com>
         <1485992285.6360.168.camel@edumazet-glaptop3.roam.corp.google.com>
         <1485993427.6360.170.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Josef Bacik <jbacik@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34079 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751073AbdBBCNZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 21:13:25 -0500
Received: by mail-pf0-f193.google.com with SMTP id y143so241119pfb.1
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 18:13:25 -0800 (PST)
In-Reply-To: <1485993427.6360.170.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When __alloc_skb() allocates an skb from fast clone cache,
setting pfmemalloc on the clone is not needed.

Clone will be properly initialized later at skb_clone() time,
including pfmemalloc field, as it is included in the
headers_start/headers_end section which is fully copied.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/skbuff.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 26c1344cc23e31d4248d23fc007bcab4b034c5c9..4f8f2a1a66b5a36705e8f9966f7abd751932dcc6 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -271,7 +271,6 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 		atomic_set(&fclones->fclone_ref, 1);
 
 		fclones->skb2.fclone = SKB_FCLONE_CLONE;
-		fclones->skb2.pfmemalloc = pfmemalloc;
 	}
 out:
 	return skb;
