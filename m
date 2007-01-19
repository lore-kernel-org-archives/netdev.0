From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [PATCH] tcp_output: Re: rare bad TCP checksum with 2.6.19?
Date: Fri, 19 Jan 2007 16:23:19 +0300
Message-ID: <45B0C647.30508@tls.msk.ru>
References: <20070119110641.GA3135@ff.dom.local> <45B0B63C.3080201@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:22301 "EHLO hobbit.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965130AbXASNXX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jan 2007 08:23:23 -0500
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <45B0B63C.3080201@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> Here is my patch proposal. If I'm not totally wrong,
>> there is a possibility that, during collapsing, empty
>> skb with FIN is added to "normal" packet and changes
>> its ip_summed field to CHECKSUM_NONE.
>>
>> diff -Nurp linux-2.6.19-/net/ipv4/tcp_output.c linux-2.6.19/net/ipv4/tcp_output.c
>> --- linux-2.6.19-/net/ipv4/tcp_output.c	2006-11-29 22:57:37.000000000 +0100
>> +++ linux-2.6.19/net/ipv4/tcp_output.c	2007-01-19 07:58:39.000000000 +0100
>> @@ -1590,7 +1590,8 @@ static void tcp_retrans_try_collapse(str
>>  
>>  		memcpy(skb_put(skb, next_skb_size), next_skb->data, next_skb_size);
>>  
>> -		skb->ip_summed = next_skb->ip_summed;
>> +		if (next_skb->ip_summed == CHECKSUM_PARTIAL)
>> +			skb->ip_summed = CHECKSUM_PARTIAL;
>>  
>>  		if (skb->ip_summed != CHECKSUM_PARTIAL)
>>  			skb->csum = csum_block_add(skb->csum, next_skb->csum, skb_size);
>>
> 
> I noticed this too, but I can't see how it could lead to
> a partial checksum on the wire since the checksumming is
> done after changing ip_summed to CHECKSUM_NONE. Is this
> patch verified to fix Michael's problem?

It seems to fix this "my" problem, yes - at least I can't reproduce it anymore.
Tcpdump is running however - let's see... :)

/mjt
