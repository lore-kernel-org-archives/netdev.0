From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 0/3] tun: fix aio
Date: Mon, 27 Apr 2009 12:34:55 +0300
Message-ID: <20090427093455.GA29082@redhat.com>
References: <20090420112527.GA6692@dhcp-1-124.tlv.redhat.com> <20090420120930.GA4941@gondor.apana.org.au> <20090420122137.GA6768@dhcp-1-124.tlv.redhat.com> <200904271048.38401.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:37303 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752889AbZD0JgE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Apr 2009 05:36:04 -0400
Content-Disposition: inline
In-Reply-To: <200904271048.38401.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 27, 2009 at 10:48:37AM +0930, Rusty Russell wrote:
> On Mon, 20 Apr 2009 09:51:38 pm Michael S. Tsirkin wrote:
> > On Mon, Apr 20, 2009 at 08:09:30PM +0800, Herbert Xu wrote:
> > > Michael S. Tsirkin <mst@redhat.com> wrote:
> > > >
> > > > Note: I started out just allocating and copying the iovec rather than adding
> > > > yet another skb-iterating routine, but this turned out to add small but
> > > > measurable overhead on data path: tx time per packet jumped from 6500 to 6700 ns
> > > > (let me know if you want to see that version of the patch).
> > > 
> > > Can you please post the copying version as well so we can compare?
> > 
> > Sure. Here it is: much smaller, but slightly slower.
> 
> Which could probably be fixed by using an on-stack version for a iovec
> of less than a certain size...

I agree that for large message sizes the malloc would probably be
dwarfed by the cost of memory copy. However a large iovec might pass a
small message, might it not?

-- 
MST
