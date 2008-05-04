From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: mac80211 truesize bugs
Date: Sun, 4 May 2008 20:45:42 +0800
Message-ID: <20080504124542.GA1455@gondor.apana.org.au>
References: <1209866916.6210.39.camel@johannes.berg> <20080504021213.GA30660@gondor.apana.org.au> <1209867740.6210.46.camel@johannes.berg> <20080504031652.GA30993@gondor.apana.org.au> <1209890847.6210.51.camel@johannes.berg> <1209892489.6210.56.camel@johannes.berg> <20080504094444.GA541@gondor.apana.org.au> <1209894754.6210.58.camel@johannes.berg> <1209900355.6210.64.camel@johannes.berg> <1209904088.4065.11.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, mb@bu3sch.de,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57422 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756867AbYEDMpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 08:45:55 -0400
Content-Disposition: inline
In-Reply-To: <1209904088.4065.11.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 04, 2008 at 02:28:08PM +0200, Johannes Berg wrote:
>
> Now I see the problem. I increased the LL_MAX_HEADER constant, but all
> code uses dev->hard_header_len to allocate the headroom (via
> LL_RESERVED_SPACE), e.g. packet.c:

Right hard_header_len is being overloaded with two meanings.
On the one hand it's used to indicate the length of the header
managed by the hardware header cache, on the other hand we use
it to indicate the head room for those devices that don't have
a cache.

Since your device wants both, it fails miserably.

There are three ways out of this.  You could have your own cache
(I haven't looked at your headers so I don't know whether that
makes sense), have no cache at all, or add a new field that gets
added to hard_header_len for the purposes of calculating head
room.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
