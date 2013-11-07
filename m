From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Thu, 7 Nov 2013 07:56:33 +0200
Message-ID: <20131107055633.GA28986@redhat.com>
References: <20131106042858.GA15745@gondor.apana.org.au>
 <1383715222.4291.158.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131106080425.GA17556@gondor.apana.org.au>
 <20131106081638.GA17665@gondor.apana.org.au>
 <20131106131252.GA20680@gondor.apana.org.au>
 <1383750070.4291.163.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131107003658.GA27976@gondor.apana.org.au>
 <1383786208.2878.15.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131107014724.GA28946@gondor.apana.org.au>
 <1383789758.2878.32.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com,
	Jason Wang <jasowang@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37312 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751083Ab3KGFxu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 00:53:50 -0500
Content-Disposition: inline
In-Reply-To: <1383789758.2878.32.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 06, 2013 at 06:02:38PM -0800, Eric Dumazet wrote:
> On Thu, 2013-11-07 at 09:47 +0800, Herbert Xu wrote:
> 
> > Say the system is fragmented sufficiently that you'll end up with
> > 0-order pages.  In that case you'll only ever be able to coalesce
> > two packets.
> 
> 4K page will contain 2 frags and they will coalesce.
> 
> Performance will still be quite good.
> 
> We probably add a tweak, to not have any hole in this case.
> 
> > 
> > Real systems that run for more than a day do end up with seriously
> > fragmented memory.
> 
> Sure, but having shallow skbs in the first place help quite a bit.
> 
> There is no perfect solution, unless of course you change virtio_net to
> provide different queues, with different frag sizes.
> 
> Sort of what NIU driver uses.
> 

I considered doing this but won't this mean packets can get reordered?
In practice we need to maintain ordering of RX frames within
a given flow, correct?

-- 
MST
