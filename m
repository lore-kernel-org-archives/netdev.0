From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: udp packets following an UFO enqueued packet need
 also be handled by UFO
Date: Wed, 02 Oct 2013 04:53:55 -0700
Message-ID: <1380714835.19002.92.camel@edumazet-glaptop.roam.corp.google.com>
References: <20130921042700.GB8070@order.stressinduktion.org>
	 <20130930114343.GA6356@minipsycho.brq.redhat.com>
	 <20130930172312.GE10771@order.stressinduktion.org>
	 <20131001105837.GA1424@minipsycho.brq.redhat.com>
	 <20131001120907.GH10771@order.stressinduktion.org>
	 <20131001123214.GI10771@order.stressinduktion.org>
	 <20131001214721.GJ10771@order.stressinduktion.org>
	 <20131001232534.GM10771@order.stressinduktion.org>
	 <20131002112052.GC1528@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, herbert@gondor.apana.org.au,
	hannes@stressinduktion.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:47485 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753520Ab3JBLx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 07:53:57 -0400
Received: by mail-pd0-f178.google.com with SMTP id w10so766454pde.23
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 04:53:57 -0700 (PDT)
In-Reply-To: <20131002112052.GC1528@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> This patch should fix this on ipv4 as well:
> 
> Subject: ip_output: do skb ufo init for peeked non ufo skb as well
> 

Is it an official patch ? s/Subject:/[PATCH]/ 

> Now, if user application does:

Any idea when the bug was added (commit id + title) ?

> sendto len<mtu flag MSG_MORE
> sendto len>mtu flag 0
> The skb is not treated as fragmented one because it is not initialized
> that way. So move the initialization to fix this.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  net/ipv4/ip_output.c | 14 +++++++++-----
>  1 file changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index a04d872..bd21c5d 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -772,15 +772,19 @@ static inline int ip_ufo_append_data(struct sock *sk,
>  		/* initialize protocol header pointer */
>  		skb->transport_header = skb->network_header + fragheaderlen;
>  
> -		skb->ip_summed = CHECKSUM_PARTIAL;
>  		skb->csum = 0;

Any idea why we have skb->csum = 0 here ?

Thanks !
