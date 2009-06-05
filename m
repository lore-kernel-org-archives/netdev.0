From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: net: Ensure partial checksum offset is inside the skb head
Date: Fri, 5 Jun 2009 13:52:01 +0930
Message-ID: <200906051352.02133.rusty@rustcorp.com.au>
References: <20090604110600.GA28453@gondor.apana.org.au> <20090604112201.GA28820@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:40537 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750716AbZFEEWD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jun 2009 00:22:03 -0400
In-Reply-To: <20090604112201.GA28820@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 4 Jun 2009 08:52:01 pm Herbert Xu wrote:
> On Thu, Jun 04, 2009 at 09:06:00PM +1000, Herbert Xu wrote:
> > tun: Optimise handling of bogus gso->hdr_len
> >
> > As all current versions of virtio_net generate a value for the
> > header length that's too small, we should optimise this so that
> > we don't copy it twice.  This can be done by ensuring that it is
> > at least as large as the place where we'll write the checksum.
> >
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> With this applied we can strengthen the partial checksum check:
>
> net: Ensure partial checksum offset is inside the skb head
>
> In skb_partial_csum_set we check to see if the checksum offset
> is within the packet.  However, we really should check that it
> is within the skb head as that's the only bit we can modify
> without copying.
>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Yep, makes sense.  FWIW:

Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Thanks!
Rusty.
