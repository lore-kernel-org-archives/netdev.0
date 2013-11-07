From: Mathias Krause <mathias.krause@secunet.com>
Subject: Re: [PATCH net-next 3/3] net: allow to leave the buffer fragmented
 in skb_cow_data()
Date: Thu, 07 Nov 2013 11:01:10 +0100
Message-ID: <527B64E6.9040004@secunet.com>
References: <cover.1381923854.git.mathias.krause@secunet.com> <14f30e8f5f8405c1ca73b6d3a554441c1736142d.1381923854.git.mathias.krause@secunet.com> <20131106093028.GA18435@gondor.apana.org.au> <527A109E.5040000@secunet.com> <20131106095217.GA18851@gondor.apana.org.au> <527A391B.4050907@secunet.com> <20131106124811.GA20404@gondor.apana.org.au> <527B5586.3090401@secunet.com> <20131107090135.GA385@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:40881 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752909Ab3KGKBN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 05:01:13 -0500
In-Reply-To: <20131107090135.GA385@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07.11.2013 10:01, Herbert Xu wrote:
> On Thu, Nov 07, 2013 at 09:55:34AM +0100, Mathias Krause wrote:
>> Indeed. I want to avoid the costly memcpy() on the CPU serving the NIC
>> interrupt, as that is a bottleneck in my setup. The packet processing --
>> encrypting/decrypting of ESP packets -- gets mostly parallelized via
>> pcrypt, so that's fine. But the initial network processing, i.e. getting
>> to pcrypt, is what's throttling the throughput currently. (RPS only
>> partly solves this problem as for the ESP receive path most traffic ends
>> up on the same flow).
> 
> How about this: instead of doing in-place encryption/decryption
> let's allocate a new destination buffer and encrypt/decrypt into
> it.  Then we essentially get the copy for free.
> 
> So instead of modifying skb_cow_data you can change esp4.c, etc.

That might be another option. But I fear it might affect performance due
to caching or NUMA effects. :/

I'll think about it and will try to investigate both approaches.


Thanks,
Mathias
