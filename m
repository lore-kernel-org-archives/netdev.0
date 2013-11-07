From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [3/3] gso: Handle malicious GRO packets without crashing
Date: Thu, 07 Nov 2013 22:13:29 +0300
Message-ID: <527BE659.9060702@cogentembedded.com>
References: <20131104041108.GA22823@gondor.apana.org.au> <20131106013038.GA14894@gondor.apana.org.au> <20131106123900.GA20259@gondor.apana.org.au> <20131106133045.GA20931@gondor.apana.org.au> <20131106143927.GA21604@gondor.apana.org.au> <1383767241.21999.9.camel@edumazet-glaptop2.roam.corp.google.com> <20131107004339.GA28156@gondor.apana.org.au> <20131107062234.GA31156@gondor.apana.org.au> <20131107070335.GA31638@gondor.apana.org.au> <20131107070647.GB31638@gondor.apana.org.au> <20131107070847.GC31638@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:35316 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535Ab3KGSNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 13:13:37 -0500
Received: by mail-lb0-f176.google.com with SMTP id z5so745148lbh.35
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 10:13:36 -0800 (PST)
In-Reply-To: <20131107070847.GC31638@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/07/2013 10:08 AM, Herbert Xu wrote:

> As virtio_net can now generate GRO frag_list packets without
> sufficient verification, we need to handle malicious GRO packets
> thrown at us.

> This patch converts to affected BUG_ONs in skb_segment to rate-
> limited warnings.

> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index bcc3f1c..fb1106d 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2881,7 +2881,15 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
>   			while (tail->next)
>   				tail = tail->next;
>
> -			BUG_ON(fskb && tail->len != len + doffset);
> +			if (fskb && tail->len != len + doffset) {
> +				net_warn_ratelimited(
> +					"skb_segment: "
> +					"illegal GSO fragment: %u %u\n",

    Don't break up the message -- chekpatch.pl should allow that...

> @@ -2929,7 +2937,15 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
>   		if (pos < offset + len) {
>   			struct sk_buff *fskb2 = fskb;
>
> -			BUG_ON(pos + fskb->len != offset + len);
> +			if (pos + fskb->len != offset + len) {
> +				net_warn_ratelimited(
> +					"skb_segment: "
> +					"illegal GSO trailer: %u %u\n",

    Same here.

WBR, Sergei
