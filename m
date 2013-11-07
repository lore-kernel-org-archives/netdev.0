From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Wed, 06 Nov 2013 18:37:35 -0800
Message-ID: <1383791855.9412.5.camel@edumazet-glaptop2.roam.corp.google.com>
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
	 <20131107021519.GA29081@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com, mst@redhat.com,
	Jason Wang <jasowang@redhat.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:60278 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777Ab3KGChj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 21:37:39 -0500
Received: by mail-pa0-f43.google.com with SMTP id hz1so569218pad.2
        for <netdev@vger.kernel.org>; Wed, 06 Nov 2013 18:37:39 -0800 (PST)
In-Reply-To: <20131107021519.GA29081@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-07 at 10:15 +0800, Herbert Xu wrote:
> On Wed, Nov 06, 2013 at 06:02:38PM -0800, Eric Dumazet wrote:
> > 
> > 4K page will contain 2 frags and they will coalesce.
> > 
> > Performance will still be quite good.
> >
> > We probably add a tweak, to not have any hole in this case.
> 
> Also have you considered the security aspect of this? If you have
> two skbs sharing a page, and one gets transmitted to a third party
> using zero-copy, the other unrelated skb's content may become visible
> where it shouldn't.

If the hypervisor is doomed, there is nothing we can do.

virtio_net owns the pages, and relies on hypervisor doing the right
thing.

That you use part of the page, is really irrelevant.

It seems you are speaking of virtio_net sending frames, but its about
receiving frames here.

We receive frames, delivered by the trusted hypervisor.

OK, I will shut up now, since apparently I really upset you.
