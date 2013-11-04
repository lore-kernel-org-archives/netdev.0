From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next] net: introduce dev_set_forwarding()
Date: Mon, 04 Nov 2013 05:58:21 -0800
Message-ID: <1383573501.4291.115.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104041108.GA22823@gondor.apana.org.au>
	 <1383538982.4291.80.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104042913.GA23021@gondor.apana.org.au>
	 <1383541254.4291.82.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104052321.GA23252@gondor.apana.org.au>
	 <1383545155.4291.89.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104062202.GA23719@gondor.apana.org.au>
	 <20131104062650.GA23755@gondor.apana.org.au>
	 <1383549041.4291.110.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104072155.GA24303@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:63526 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752539Ab3KDN6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 08:58:23 -0500
Received: by mail-pd0-f177.google.com with SMTP id p10so6670248pdj.22
        for <netdev@vger.kernel.org>; Mon, 04 Nov 2013 05:58:23 -0800 (PST)
In-Reply-To: <20131104072155.GA24303@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-04 at 15:21 +0800, Herbert Xu wrote:
> On Sun, Nov 03, 2013 at 11:10:41PM -0800, Eric Dumazet wrote:
> >
> > Using frag_list for skb meant to be delivered to local stack is mostly
> > fine. Its for forwarding that its not a win, since no driver actually
> > supports frag_list and we revert to skb_segment().
> 
> Sigh.
> 
> Most of the gain these days isn't coming from the hardware anymore,
> especially for virtualisation where the network stack is at least
> twice as long.  The gain is in paying the cost of the network once
> instead of n times for an aggregation of n packets.  So with your
> mega-GRO patch, the choice comes down to paying for one trip or
> three trips.  The difference may not be trivial, even for a router.

I do think we are on the same thoughts.

Please take a look at 2613af0ed18a11d5c566a81f9a6510b73180660a
("virtio_net: migrate mergeable rx buffers to page frag allocators")

Notice it also uses frag_list

So if you don't provide a skb_segment() patch, I will.

I had urgent matters last week.
