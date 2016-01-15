From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv6: update skb->csum when CE mark is propagated
Date: Fri, 15 Jan 2016 07:44:26 -0800
Message-ID: <1452872666.1223.168.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1452862616.1223.165.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160115134515.GA31463@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36528 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826AbcAOPo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 10:44:28 -0500
Received: by mail-pf0-f179.google.com with SMTP id n128so119379350pfn.3
        for <netdev@vger.kernel.org>; Fri, 15 Jan 2016 07:44:28 -0800 (PST)
In-Reply-To: <20160115134515.GA31463@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-01-15 at 21:45 +0800, Herbert Xu wrote:
> On Fri, Jan 15, 2016 at 04:56:56AM -0800, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > When a tunnel decapsulates the outer header, it has to comply
> > with RFC 6080 and eventually propagate CE mark into inner header.
> > 
> > It turns out IP6_ECN_set_ce() does not correctly update skb->csum
> > for CHECKSUM_COMPLETE packets, triggering infamous "hw csum failure"
> > messages and stack traces.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Good catch!

Thanks Herbert

Note that I considered to use 

skb->csum = csum_add(skb->csum, from ^ to);

instead of the more generic

skb->csum = csum_add(csum_sub(skb->csum, from), to);

I can spin a v2 if you guys prefer the optimized version (but a little
more hacky...)
