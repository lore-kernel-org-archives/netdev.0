From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Tue, 05 Nov 2013 20:23:05 -0800
Message-ID: <1383711785.4291.156.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131029.194446.2215574000648693370.davem@davemloft.net>
	 <1383091610.1534.29.camel@bwh-desktop.uk.level5networks.com>
	 <1383400897.4291.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103122824.GA17394@gondor.apana.org.au>
	 <1383496104.4291.69.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131103163103.GA18894@gondor.apana.org.au>
	 <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104041108.GA22823@gondor.apana.org.au>
	 <20131106013038.GA14894@gondor.apana.org.au>
	 <1383702347.4291.152.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131106040717.GA15711@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:41546 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752916Ab3KFEXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 23:23:08 -0500
Received: by mail-pb0-f41.google.com with SMTP id wy17so5234877pbc.14
        for <netdev@vger.kernel.org>; Tue, 05 Nov 2013 20:23:07 -0800 (PST)
In-Reply-To: <20131106040717.GA15711@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-06 at 12:07 +0800, Herbert Xu wrote:
> On Tue, Nov 05, 2013 at 05:45:47PM -0800, Eric Dumazet wrote:
> >
> > Hmm, I do not think fskb has the headers in the general case.
> 
> Only GRO produces such packets, see the changeset where I added
> frag_list support to skb_setgment

Nope, I already mentioned this :

Please take a look at 2613af0ed18a11d5c566a81f9a6510b73180660a
("virtio_net: migrate mergeable rx buffers to page frag allocators")

I do not see why skb_segment() would be tied to GRO -> GSO, with
the property of each page frag being exactly MSS sized.

We use it in TCP stack with page frags of any size.

skb_segment() needs to iterate properly on all pages frags,
the one found in the first skb, and the ones found on frag_list skbs.
