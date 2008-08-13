From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/2] tun: fallback if skb_alloc() fails on big packets
Date: Wed, 13 Aug 2008 13:24:55 +1000
Message-ID: <200808131324.56071.rusty@rustcorp.com.au>
References: <200808121624.56948.rusty@rustcorp.com.au> <200808121625.53703.rusty@rustcorp.com.au> <20080812101409.GA22114@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Max Krasnyansky <maxk@qualcomm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:46398 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754221AbYHMDY7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2008 23:24:59 -0400
In-Reply-To: <20080812101409.GA22114@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 12 August 2008 20:14:09 Herbert Xu wrote:
> On Tue, Aug 12, 2008 at 04:25:53PM +1000, Rusty Russell wrote:
> > skb_alloc produces linear packets (using kmalloc()).  That can fail,
> > so should we fall back to making paged skbs.
>
> I'm not sure that this is really a good idea.  If anything then
> tries to expand the head of this skb, they may fail and be forced
> to drop the packet.

Yes, but it's no worse than now.  virtio_net keeps a cache of allocated pages, 
but that's more code; and if I'm going to generalize that I really should 
create a shrinker callback, which produces locking issues.

So I decided this was probably enough for this merge window.
Rusty.
