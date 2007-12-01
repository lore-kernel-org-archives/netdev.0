From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 4/4] udp: memory accounting in IPv4
Date: Sun, 2 Dec 2007 00:16:43 +1100
Message-ID: <20071201131643.GE15910@gondor.apana.org.au>
References: <474DB80E.5070403@redhat.com> <474DB930.5080409@redhat.com> <20071201122120.GB14368@gondor.apana.org.au> <47515CCF.3030009@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hideo AOKI <haoki@redhat.com>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Bill Fink <billfink@mindspring.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3494 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750818AbXLANQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 08:16:55 -0500
Content-Disposition: inline
In-Reply-To: <47515CCF.3030009@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 01, 2007 at 02:08:31PM +0100, Eric Dumazet wrote:
> 
> I agree adding yet another atomics ops is a big problem.
> 
> Another idea, coupled with recent work on percpu storage done by Christoph 
> Lameter, would be to use kind of a percpu_counter :

Yes that's an interesting idea.

> We dont really need strong and precise memory accounting (UDP , but TCP as 
> well), just some kind of limit to avoid memory to be too much used.

BTW it's no big deal for TCP because it's completely serialised so it
doesn't use atomic ops for the accounting.  More importantly, it uses
sk_forward_alloc so not every packet needs to touch the global counter.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
