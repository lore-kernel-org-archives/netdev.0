From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bridge: Fix IGMP3 report parsing
Date: Thu, 8 Apr 2010 12:07:09 +0800
Message-ID: <20100408040709.GA19944@gondor.apana.org.au>
References: <20100408012634.GC18649@gondor.apana.org.au> <20100407.205248.113724360.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, banyeer@yahoo.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:40981 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751120Ab0DHEHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 00:07:13 -0400
Content-Disposition: inline
In-Reply-To: <20100407.205248.113724360.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 07, 2010 at 08:52:48PM -0700, David Miller wrote:
> 
> If pskb_may_pull() actually does anything non-trivial,
> skb->data will change and you'll be referring to freed
> up memory.
> 
> That's probably why you had the grec assignment where
> you originally had it in the first place :-)

Heh, you're clearly more awake than I was :)

bridge: Fix IGMP3 report parsing

The IGMP3 report parsing is looking at the wrong address for
group records.  This patch fixes it.

Reported-by: Banyeer <banyeer@yahoo.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 6980625..f29ada8 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -723,7 +723,7 @@ static int br_multicast_igmp3_report(struct net_bridge *br,
 		if (!pskb_may_pull(skb, len))
 			return -EINVAL;
 
-		grec = (void *)(skb->data + len);
+		grec = (void *)(skb->data + len - sizeof(*grec));
 		group = grec->grec_mca;
 		type = grec->grec_type;
 
Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
