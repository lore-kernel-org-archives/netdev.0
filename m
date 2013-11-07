From: Jason Wang <jasowang@redhat.com>
Subject: Re: gso: Attempt to handle mega-GRO packets
Date: Thu, 07 Nov 2013 10:52:57 +0800
Message-ID: <527B0089.4030605@redhat.com>
References: <20131106013038.GA14894@gondor.apana.org.au> <1383702347.4291.152.camel@edumazet-glaptop2.roam.corp.google.com> <20131106040717.GA15711@gondor.apana.org.au> <1383711785.4291.156.camel@edumazet-glaptop2.roam.corp.google.com> <20131106042858.GA15745@gondor.apana.org.au> <1383715222.4291.158.camel@edumazet-glaptop2.roam.corp.google.com> <20131106080425.GA17556@gondor.apana.org.au> <20131106081638.GA17665@gondor.apana.org.au> <20131106131252.GA20680@gondor.apana.org.au> <1383750070.4291.163.camel@edumazet-glaptop2.roam.corp.google.com> <20131107003658.GA27976@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com, mst@redhat.com
To: Herbert Xu <herbert@gondor.hengli.com.au>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62012 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752733Ab3KGCxV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Nov 2013 21:53:21 -0500
In-Reply-To: <20131107003658.GA27976@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/07/2013 08:36 AM, Herbert Xu wrote:
> On Wed, Nov 06, 2013 at 07:01:10AM -0800, Eric Dumazet wrote:
>> Have you thought about arches having PAGE_SIZE=65536, and how bad it is
>> to use a full page per network frame ? It is lazy and x86 centered.
> So instead if we were sending a full 64K packet on such an arch to
> another guest, we'd now chop it up into 1.5K chunks and reassemble them.
>
>> So after our patches, we now have an optimal situation, even on these
>> arches.
> Optimal only for physical incoming packets with no jumbo frames.
>
> What's worse, I now realise that the coalesce thing isn't even
> guaranteed to work.  It probably works in your benchmarks because
> you're working with freshly allocated pages.
>
> But once the system has been running for a while, I see nothing
> in the virtio_net code that tries to prevent fragmentation.  Once
> fragmentation sets in, you'll be back in the terrible situation
> that we were in prior to the coalesce patch.
>
> Jason/Michael (Tsirkin), am I missing something that would prevent
> fragmentation of these buffers?
>
> Cheers,

No. Maybe we can use per-queue buffers instead.
