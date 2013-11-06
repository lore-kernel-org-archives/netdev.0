From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Wed, 6 Nov 2013 16:16:39 +0800
Message-ID: <20131106081638.GA17665@gondor.apana.org.au>
References: <20131103163103.GA18894@gondor.apana.org.au>
 <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131104041108.GA22823@gondor.apana.org.au>
 <20131106013038.GA14894@gondor.apana.org.au>
 <1383702347.4291.152.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131106040717.GA15711@gondor.apana.org.au>
 <1383711785.4291.156.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131106042858.GA15745@gondor.apana.org.au>
 <1383715222.4291.158.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131106080425.GA17556@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com, mst@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:34617 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752555Ab3KFIQq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 03:16:46 -0500
Content-Disposition: inline
In-Reply-To: <20131106080425.GA17556@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 06, 2013 at 04:04:25PM +0800, Herbert Xu wrote:
> On Tue, Nov 05, 2013 at 09:20:22PM -0800, Eric Dumazet wrote:
> > On Wed, 2013-11-06 at 12:28 +0800, Herbert Xu wrote:
> > > On Tue, Nov 05, 2013 at 08:23:05PM -0800, Eric Dumazet wrote:
> > > >
> > > > Nope, I already mentioned this :
> > > > 
> > > > Please take a look at 2613af0ed18a11d5c566a81f9a6510b73180660a
> > > > ("virtio_net: migrate mergeable rx buffers to page frag allocators")
> > > 
> > > This patch should simply be reverted.  You guys steam-rolled over
> > > the virtio_net people's concerns that this seriously impacts virt
> > > performance.
> > > 
> > 
> > Have you followed netdev traffic lately ?
> > 
> > virtio_net performance is better than before, and we did no revert,
> > thank you.
> 
> The last email I saw from Michael Tsirkin he still wasn't happy
> that your patch does not degrade virt performance.  Where is the
> reply to that?

I just looked at the aformentioned patch again and it is seriously
broken! How on earth did it get merged?

Instead of using perfectly sane 4K pages per frag to store guest to
guest traffic, we now end up using 1.5K frags, which that's why you
end up having to use the frag_list, WTF?

Dave, please revert the above commit as it is seriously broken.

Whatever performance problem it is trying to address can surely
be fixed without being so stupid as to break up perfectly sized
4K pages into 1.5K chunks.

Thanks!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
