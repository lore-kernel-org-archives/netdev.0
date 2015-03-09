From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable: Move hash_rnd into bucket_table
Date: Tue, 10 Mar 2015 09:21:05 +1100
Message-ID: <20150309222105.GA12158@gondor.apana.org.au>
References: <20150131102150.GA29498@gondor.apana.org.au>
 <20150202.191956.404010205495035337.davem@davemloft.net>
 <20150202.192634.1792206005008667377.davem@davemloft.net>
 <20150203201750.GA22474@gondor.apana.org.au>
 <20150309095833.GA4028@gondor.apana.org.au>
 <54FDC9CC.6080709@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:43647 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754337AbbCIWV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 18:21:27 -0400
Content-Disposition: inline
In-Reply-To: <54FDC9CC.6080709@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 09, 2015 at 05:26:52PM +0100, Daniel Borkmann wrote:
> 
> I believe the original purpose was to have reproduceability, but
> yeah, there are no users of it currently.

If anyone ever needed that we could always provide a way to set
the random value, through a rehash.
 
> Have you tested this patch? ;-)

Clearly not :)

> If I see this correctly, the first time you shrink or expand, your hash_rnd
> from then onwards will constantly be 0.
> 
> You need to copy over the above old hash_rnd to the new one from the newly
> allocated tbl. So, bucket_table_alloc() needs a change as well. Of course,
> with rehashing, the get_random_bytes() would directly move there.

Yes it should copy them.  I've fixed in my tree now and it actually
works!

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
