From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH RFC] net: tcp: GRO should be ECN friendly
Date: Mon, 6 Aug 2012 17:01:50 +0800
Message-ID: <20120806090150.GB18425@gondor.apana.org.au>
References: <1344242090.9299.1656.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:43707 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752931Ab2HFJB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 05:01:59 -0400
Content-Disposition: inline
In-Reply-To: <1344242090.9299.1656.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 06, 2012 at 10:34:50AM +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> While doing TCP ECN tests, I discovered GRO was reordering packets if it
> receives one packet with CE set, while previous packets in same NAPI run
> have ECT(0) for the same flow :
> 
> 09:25:25.857620 IP (tos 0x2,ECT(0), ttl 64, id 27893, offset 0, flags
> [DF], proto TCP (6), length 4396)
>     172.30.42.19.54550 > 172.30.42.13.44139: Flags [.], seq
> 233801:238145, ack 1, win 115, options [nop,nop,TS val 3397779 ecr
> 1990627], length 4344
> 
> 09:25:25.857626 IP (tos 0x3,CE, ttl 64, id 27892, offset 0, flags [DF],
> proto TCP (6), length 1500)
>     172.30.42.19.54550 > 172.30.42.13.44139: Flags [.], seq
> 232353:233801, ack 1, win 115, options [nop,nop,TS val 3397779 ecr
> 1990627], length 1448
> 
> 09:25:25.857638 IP (tos 0x0, ttl 64, id 34581, offset 0, flags [DF],
> proto TCP (6), length 64)
>     172.30.42.13.44139 > 172.30.42.19.54550: Flags [.], cksum 0xac8f
> (incorrect -> 0xca69), ack 232353, win 1271, options [nop,nop,TS val
> 1990627 ecr 3397779,nop,nop,sack 1 {233801:238145}], length 0
> 
> We have two problems here :
> 
> 1) GRO reorders packets
> 
>   If NIC gave packet1, then packet2, which happen to be from "different
> flows"  GRO feeds stack with packet2, then packet1. I have yet to
> understand how to solve this problem.
> 
> 2) GRO is not ECN friendly
> 
> Delivering packets out of order makes TCP stack not as fast as it could
> be.
> 
> In this patch I suggest we make the tos test not part of the 'same_flow'
> determination, but part of the 'should flush' logic
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Good catch, thanks Eric!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
