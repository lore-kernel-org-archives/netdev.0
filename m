From: Dan Carpenter <error27@gmail.com>
Subject: [patch] ipv6: cleanup: remove unneeded null check
Date: Thu, 29 Apr 2010 16:30:35 +0200
Message-ID: <20100429143034.GI29093@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Emil S Tantilov <emils.tantilov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f183.google.com ([209.85.221.183]:33119 "EHLO
	mail-qy0-f183.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759775Ab0D3WWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 18:22:17 -0400
Received: by qyk13 with SMTP id 13so961123qyk.1
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 15:22:16 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We dereference "sk" unconditionally elsewhere in the function.  

This was left over from:  b30bd282 "ip6_xmit: remove unnecessary NULL
ptr check".  According to that commit message, "the sk argument to 
ip6_xmit is never NULL nowadays since the skb->priority assigment 
expects a valid socket."

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 75d5ef8..d26c6ae 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -218,8 +218,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
 			}
 			kfree_skb(skb);
 			skb = skb2;
-			if (sk)
-				skb_set_owner_w(skb, sk);
+			skb_set_owner_w(skb, sk);
 		}
 		if (opt->opt_flen)
 			ipv6_push_frag_opts(skb, opt, &proto);
