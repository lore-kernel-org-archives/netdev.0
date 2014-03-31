From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net-gro: restore frag0 optimization
Date: Mon, 31 Mar 2014 14:19:44 -0700
Message-ID: <1396300784.29410.75.camel@edumazet-glaptop2.roam.corp.google.com>
References: <53345A6C.5080008@redhat.com>
	 <1395940898.12610.307.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1396153701.29410.27.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140331.162747.1884094141150130320.davem@davemloft.net>
	 <1396299703.29410.71.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mschmidt@redhat.com, netdev@vger.kernel.org, edumazet@google.com,
	hkchu@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:59397 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbaCaVTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 17:19:46 -0400
Received: by mail-pb0-f51.google.com with SMTP id uo5so8830629pbc.10
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 14:19:46 -0700 (PDT)
In-Reply-To: <1396299703.29410.71.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-31 at 14:01 -0700, Eric Dumazet wrote:

> 
> BTW, I found a off-by-one error in skb_gro_header_hard()


>  
> -static inline int skb_gro_header_hard(struct sk_buff *skb, unsigned int hlen)
> +static inline bool skb_gro_header_hard(const struct sk_buff *skb,
> +				       unsigned int hlen)
>  {
> -	return NAPI_GRO_CB(skb)->frag0_len < hlen;
> +	return NAPI_GRO_CB(skb)->frag0_len <= hlen;
>  }


Oh well, scratch this. This strange function name fooled me again.

bool slowpath = hlen > NAPI_GRO_CB(skb)->frag0_len;
