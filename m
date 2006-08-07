From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] SNMPv2 tcpOutSegs counter error
Date: Mon, 07 Aug 2006 12:40:34 +1000
Message-ID: <E1G9v2g-0000rZ-00@gondolin.me.apana.org.au>
References: <1154920659.3388.4.camel@LINE>
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:5638 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750916AbWHGCku
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Aug 2006 22:40:50 -0400
To: yjwei@nanjing-fnst.com (Wei Yongjun)
In-Reply-To: <1154920659.3388.4.camel@LINE>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wei Yongjun <yjwei@nanjing-fnst.com> wrote:
> 
> --- a/net/ipv4/tcp_output.c     2006-08-03 18:05:22.425081936 -0400
> +++ b/net/ipv4/tcp_output.c     2006-08-07 09:48:41.186372896 -0400
> @@ -462,7 +462,8 @@ static int tcp_transmit_skb(struct sock 
>        if (skb->len != tcp_header_size)
>                tcp_event_data_sent(tp, skb, sk);
> 
> -       TCP_INC_STATS(TCP_MIB_OUTSEGS);
> +       if(!before(tcb->seq, tp->snd_nxt))
> +               TCP_INC_STATS(TCP_MIB_OUTSEGS);

The general approach looks sound.  I have one esoteric question
though.  If a retransmitted packet is coalesced with one that is
yet to be transmitted (a fairly unlikely scenario, but possible I
think), should it count towards OUTSEGS?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
