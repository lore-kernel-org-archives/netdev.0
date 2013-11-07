From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Wed, 06 Nov 2013 18:08:40 -0800
Message-ID: <1383790120.2878.36.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131106040717.GA15711@gondor.apana.org.au>
	 <1383711785.4291.156.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131106042858.GA15745@gondor.apana.org.au>
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
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com, mst@redhat.com,
	Jason Wang <jasowang@redhat.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:60102 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361Ab3KGCIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 21:08:44 -0500
Received: by mail-pa0-f47.google.com with SMTP id lf10so538969pab.20
        for <netdev@vger.kernel.org>; Wed, 06 Nov 2013 18:08:43 -0800 (PST)
In-Reply-To: <1383789758.2878.32.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-06 at 18:02 -0800, Eric Dumazet wrote:
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

After skb_page_frag_refill() call, its trivial to check if the page is
order-0.

If yes, use the whole remaining space, instead of MAX_PACKET_LEN

-> If memory is fragmented, we switch back to old behavior.

Really, its that simple.
