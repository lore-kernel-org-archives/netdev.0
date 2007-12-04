From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 4/4] udp: memory accounting in IPv4
Date: Tue, 4 Dec 2007 11:26:45 +1100
Message-ID: <20071204002644.GA28982@gondor.apana.org.au>
References: <474DB80E.5070403@redhat.com> <474DB930.5080409@redhat.com> <20071201122120.GB14368@gondor.apana.org.au> <47515CCF.3030009@cosmosbay.com> <47549BE2.9080605@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Bill Fink <billfink@mindspring.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: Hideo AOKI <haoki@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2283 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750764AbXLDA1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 19:27:16 -0500
Content-Disposition: inline
In-Reply-To: <47549BE2.9080605@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 03, 2007 at 07:14:26PM -0500, Hideo AOKI wrote:
>
> Let me try to use sk_forward_alloc at first, while percpu storage
> is an interesting idea.

Actually I don't think sk_forward_alloc would work for UDP because
it runs lockless (unlike TCP which is run under a the socket lock).

So it's either going to be the atomic op or per-cpu counters.  For
me the atomic op isn't the issue, it's the SMP cache-line bouncing
that's more important so having something that did atomic ops on a
socket counter which then feeds into the global counter would solve
my concerns.

But let's wait and see what Dave has to say about this too.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
