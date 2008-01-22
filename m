From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3] virtio: Net header needs gso_hdr_len
Date: Tue, 22 Jan 2008 21:36:30 +1100
Message-ID: <20080122103630.GA24135@gondor.apana.org.au>
References: <E1JEvnR-0006ax-00@gondolin.me.apana.org.au> <200801161519.03339.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55689 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755052AbYAVKgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 05:36:36 -0500
Content-Disposition: inline
In-Reply-To: <200801161519.03339.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 16, 2008 at 03:19:03PM +1100, Rusty Russell wrote:
> > > It's far easier to deal with GSO if we don't have to parse the packet
> > > to figure out the header length.  Add the field to the virtio_net_hdr
> > > struct (and fix the spaces that somehow crept in there).
>
> > Why do we need this? When receiving GSO packets from an untrusted
> > source the network stack will fill in the transport header offset
> > after verifying that the headers are sane.
> 
> Thanks for clarifying; it simplifies things.

Actually now that I've tried your test program I can see that this
field exists not because of GSO, but because of SG.  It tells you
how many bytes you want to put in the skb head as opposed to the
frag array.

So this field is fine with me as long as it is named as such to
avoid confusion since it really has nothing to do with GSO as you
also need it for SG with large MTUs.

I think this is more flexible than the Xen approach where this is
essentially hard-coded to 64 bytes.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
