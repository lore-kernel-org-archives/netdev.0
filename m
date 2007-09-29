From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Sat, 29 Sep 2007 17:21:23 +0200
Message-ID: <46FE6D73.4000002@trash.net>
References: <E1IbT8r-0000Av-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hadi@cyberus.ca, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50330 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753842AbXI2PVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 11:21:45 -0400
In-Reply-To: <E1IbT8r-0000Av-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
>>On Fri, Sep 28, 2007 at 06:55:32PM +0200, Patrick McHardy wrote:
>>
>>>Looking at ip_input.o as example (everything without forced inlining):
>>>
>>>   text    data     bss     dec     hex filename
>>>   2076       8       0    2084     824 net/ipv4/ip_input.o
>>>   3483       8       0    3491     da3 net/ipv4/ip_input.o
>>
>>If it's so big perhaps it should be inlined? It'll be a tail
>>call anyway.
> 
> 
> s/should be/shouldn't be/


Unfortunately gcc doesn't perform tail call optimization when the
address of a parameter or local variable is passed to an extern
function before the tail call, which NF_HOOK does for the skb.

