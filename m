From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [3/3] gso: Handle malicious GRO packets without crashing
Date: Tue, 12 Nov 2013 02:55:03 +0800
Message-ID: <20131111185502.GB12462@gondor.apana.org.au>
References: <20131106123900.GA20259@gondor.apana.org.au>
 <20131106133045.GA20931@gondor.apana.org.au>
 <20131106143927.GA21604@gondor.apana.org.au>
 <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131107004339.GA28156@gondor.apana.org.au>
 <20131107062234.GA31156@gondor.apana.org.au>
 <20131107070335.GA31638@gondor.apana.org.au>
 <20131107070647.GB31638@gondor.apana.org.au>
 <20131107070847.GC31638@gondor.apana.org.au>
 <527BE659.9060702@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:34183 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754119Ab3KKSzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 13:55:09 -0500
Content-Disposition: inline
In-Reply-To: <527BE659.9060702@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 07, 2013 at 10:13:29PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 11/07/2013 10:08 AM, Herbert Xu wrote:
> 
> >As virtio_net can now generate GRO frag_list packets without
> >sufficient verification, we need to handle malicious GRO packets
> >thrown at us.
> 
> >This patch converts to affected BUG_ONs in skb_segment to rate-
> >limited warnings.
> 
> >Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> >diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> >index bcc3f1c..fb1106d 100644
> >--- a/net/core/skbuff.c
> >+++ b/net/core/skbuff.c
> >@@ -2881,7 +2881,15 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
> >  			while (tail->next)
> >  				tail = tail->next;
> >
> >-			BUG_ON(fskb && tail->len != len + doffset);
> >+			if (fskb && tail->len != len + doffset) {
> >+				net_warn_ratelimited(
> >+					"skb_segment: "
> >+					"illegal GSO fragment: %u %u\n",
> 
>    Don't break up the message -- chekpatch.pl should allow that...

Thanks for the comment.  In the latest version of this patch
this should no longer be an issue.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
