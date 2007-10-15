From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 6/10] [BRIDGE]: Unshare skb upon entry
Date: Mon, 15 Oct 2007 09:20:00 +0200
Message-ID: <471314A0.5080500@trash.net>
References: <20071014042604.GA11431@gondor.apana.org.au> <E1Igv4q-00030k-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030707020206090502060008"
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36422 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754152AbXJOHUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 03:20:07 -0400
In-Reply-To: <E1Igv4q-00030k-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030707020206090502060008
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> [BRIDGE]: Unshare skb upon entry
> 
> Due to the special location of the bridging hook, it should never see a
> shared packet anyway (certainly not with any in-kernel code).  So it
> makes sense to unshare the skb there if necessary as that will greatly
> simplify the code below it (in particular, netfilter).


I guess we can remove the unsharing from br_netfilter.c now.

Signed-off-by: Patrick McHardy <kaber@trash.net>



--------------030707020206090502060008
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 246bf23..da22f90 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -511,9 +511,6 @@ static unsigned int br_nf_pre_routing(unsigned int hook, struct sk_buff *skb,
 	struct iphdr *iph;
 	__u32 len = nf_bridge_encap_header_len(skb);
 
-	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
-		return NF_STOLEN;
-
 	if (unlikely(!pskb_may_pull(skb, len)))
 		goto out;
 

--------------030707020206090502060008--
