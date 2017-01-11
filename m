From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] gro: use min_t() in skb_gro_reset_offset()
Date: Tue, 10 Jan 2017 19:52:43 -0800
Message-ID: <1484106763.21472.49.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1484079841.21472.35.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170110.212911.71346127320993214.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
        slavash@mellanox.com, willemb@google.com, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33278 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761267AbdAKDwq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 22:52:46 -0500
Received: by mail-pf0-f194.google.com with SMTP id 127so31831541pfg.0
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 19:52:46 -0800 (PST)
In-Reply-To: <20170110.212911.71346127320993214.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On 32bit arches, (skb->end - skb->data) is not 'unsigned int',
so we shall use min_t() instead of min() to avoid a compiler error.

Fixes: 1272ce87fa01 ("gro: Enter slow-path if there is no tailroom")
Reported-by: kernel test robot <fengguang.wu@intel.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/dev.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 88d2907ca2cda3438a7a1c0c179051a5038aa1e1..07b307b0b414730688b64fdb2295b0fa1b721e51 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4441,8 +4441,9 @@ static void skb_gro_reset_offset(struct sk_buff *skb)
 	    pinfo->nr_frags &&
 	    !PageHighMem(skb_frag_page(frag0))) {
 		NAPI_GRO_CB(skb)->frag0 = skb_frag_address(frag0);
-		NAPI_GRO_CB(skb)->frag0_len = min(skb_frag_size(frag0),
-						  skb->end - skb->tail);
+		NAPI_GRO_CB(skb)->frag0_len = min_t(unsigned int,
+						    skb_frag_size(frag0),
+						    skb->end - skb->tail);
 	}
 }
 
