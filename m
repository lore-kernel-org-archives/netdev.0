From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: virtio_net: Set correct gso->hdr_len
Date: Fri, 5 Jun 2009 16:53:12 +1000
Message-ID: <20090605065312.GA7590@gondor.apana.org.au>
References: <20090604105917.GA28273@gondor.apana.org.au> <200906051351.06385.rusty@rustcorp.com.au> <20090605042709.GA6702@gondor.apana.org.au> <200906051620.02868.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43580 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754784AbZFEGxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 02:53:15 -0400
Content-Disposition: inline
In-Reply-To: <200906051620.02868.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 05, 2009 at 04:20:02PM +0930, Rusty Russell wrote:
>
> Right, understood now.  It really is just a hint as to how much to copy.  It 
> wasn't supposed to be that, as virtio_net.h:
> 
> 	__u16 hdr_len;		/* Ethernet + IP + tcp/udp hdrs */
> 	__u16 gso_size;		/* Bytes to append to hdr_len per frame */
> 
> The host was supposed to be able to de-gso packets together relying on 
> hdr_len.  But that's silly: it can't do TSO without knowing about sequence 
> numbers at least, and UFO without ip fragmentation offsets.  ie. it might as 
> well calc hdr_len itself.

Well I always thought hdr_len was meant to represent what should
be in the linear header :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
