From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Wed, 06 Nov 2013 07:01:10 -0800
Message-ID: <1383750070.4291.163.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383499603.4291.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131104041108.GA22823@gondor.apana.org.au>
	 <20131106013038.GA14894@gondor.apana.org.au>
	 <1383702347.4291.152.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131106040717.GA15711@gondor.apana.org.au>
	 <1383711785.4291.156.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131106042858.GA15745@gondor.apana.org.au>
	 <1383715222.4291.158.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131106080425.GA17556@gondor.apana.org.au>
	 <20131106081638.GA17665@gondor.apana.org.au>
	 <20131106131252.GA20680@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com, mst@redhat.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:35458 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756670Ab3KFPBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 10:01:15 -0500
Received: by mail-pb0-f52.google.com with SMTP id rr4so2651159pbb.11
        for <netdev@vger.kernel.org>; Wed, 06 Nov 2013 07:01:12 -0800 (PST)
In-Reply-To: <20131106131252.GA20680@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-06 at 21:12 +0800, Herbert Xu wrote:

> I take that back.  While the original patch was seriously broken,
> it has since been fixed by the coalescing patch that Jason Wang
> wrote.
> 

Patch was not 'broken', but a step into the right direction. I am very
sorry if you think otherwise.

> It's still pretty weird to be dividing page frags into 1500-byte
> chunks and then merging back up to 4K but at least it should do the
> right thing now.


Have you thought about arches having PAGE_SIZE=65536, and how bad it is
to use a full page per network frame ? It is lazy and x86 centered.

So after our patches, we now have an optimal situation, even on these
arches.

On x86, a full 64KB GSO packet will now fit in 2 (or 3) frags allocated
in 32KB pages (order-3) in fast path (ie if there is not high memory
pressure)

According to our tests, performance is better on x86, and virtio_net now
is usable on arches with PAGE_SIZE=65536
