From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH RFC net-next] net: Assert napi_gro_cb size against
 skb->cb[]
Date: Fri, 31 Jul 2015 22:24:03 +0200
Message-ID: <20150731202403.GB20471@breakpoint.cc>
References: <1438368669-659-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	daniel@iogearbox.net, edumazet@google.com, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:33081 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1946247AbbGaUYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 16:24:08 -0400
Content-Disposition: inline
In-Reply-To: <1438368669-659-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 64-bits hosts, napi_gro_cb is 48 bytes, which is exactly the size of
> skb->cb[], while on 32-bits hosts it is 36 bytes, but if it were to
> grow, we would not be catching a size inflation as we should.
> ---
>  net/core/dev.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 4870c3556a5a..20bc82604b75 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4115,6 +4115,8 @@ static void skb_gro_reset_offset(struct sk_buff *skb)
>  	const struct skb_shared_info *pinfo = skb_shinfo(skb);
>  	const skb_frag_t *frag0 = &pinfo->frags[0];
>  
> +	BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct napi_gro_cb));

commit c3c7c254b2e8cd99b0adf288c2a1bddacd7ba255
already added a check for this.
