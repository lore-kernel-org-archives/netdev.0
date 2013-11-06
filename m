From: Joe Perches <joe@perches.com>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Wed, 06 Nov 2013 09:25:51 -0800
Message-ID: <1383758751.7940.20.camel@joe-AO722>
References: <1383091610.1534.29.camel@bwh-desktop.uk.level5networks.com>
	 <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103122824.GA17394@gondor.apana.org.au>
	 <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103163103.GA18894@gondor.apana.org.au>
	 <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104041108.GA22823@gondor.apana.org.au>
	 <20131106013038.GA14894@gondor.apana.org.au>
	 <20131106123900.GA20259@gondor.apana.org.au>
	 <20131106133045.GA20931@gondor.apana.org.au>
	 <20131106143927.GA21604@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0050.hostedemail.com ([216.40.44.50]:56107 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754348Ab3KFRZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 12:25:49 -0500
In-Reply-To: <20131106143927.GA21604@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-06 at 22:39 +0800, Herbert Xu wrote:
> On Wed, Nov 06, 2013 at 09:30:45PM +0800, Herbert Xu wrote:
> > In order to handle malicious GSO packets that is now possible with
> > the use of frag_list in virtio_net, we need to remove the BUG_ONs.
[]
> Still totally untested but at least this has a chance of handling
> the new virtio_net.

trivial:  please add "\n" to each net_warn_ratelimited
format termination.

> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
[]
> @@ -2861,15 +2853,62 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
[]
> +			if (skb_has_frag_list(nskb)) {
> +				net_warn_ratelimited(
> +					"skb_segment: "
> +					"nested frag_list detected");

	"nested frag_list detected\n");

etc...

It might be nicer to coalesce the format fragments too.
