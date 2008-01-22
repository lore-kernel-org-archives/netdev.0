From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/3] virtio: Net header needs gso_hdr_len
Date: Wed, 23 Jan 2008 09:06:14 +1100
Message-ID: <200801230906.14585.rusty@rustcorp.com.au>
References: <E1JEvnR-0006ax-00@gondolin.me.apana.org.au> <200801161519.03339.rusty@rustcorp.com.au> <20080122103630.GA24135@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:46912 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750906AbYAVWIm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2008 17:08:42 -0500
In-Reply-To: <20080122103630.GA24135@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 22 January 2008 21:36:30 Herbert Xu wrote:
> On Wed, Jan 16, 2008 at 03:19:03PM +1100, Rusty Russell wrote:
> > > > It's far easier to deal with GSO if we don't have to parse the packet
> > > > to figure out the header length.  Add the field to the virtio_net_hdr
> > > > struct (and fix the spaces that somehow crept in there).
> > >
> > > Why do we need this? When receiving GSO packets from an untrusted
> > > source the network stack will fill in the transport header offset
> > > after verifying that the headers are sane.
> >
> > Thanks for clarifying; it simplifies things.
>
> Actually now that I've tried your test program I can see that this
> field exists not because of GSO, but because of SG.  It tells you
> how many bytes you want to put in the skb head as opposed to the
> frag array.

Yes, I took it out after your comments, then realized I needed it and put it 
back.

> So this field is fine with me as long as it is named as such to
> avoid confusion since it really has nothing to do with GSO as you
> also need it for SG with large MTUs.

Hmm, how about just "hdr_len" rather than "gso_hdr_len"?

Thanks,
Rusty.
