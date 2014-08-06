From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] udp: UDP Fast Port
Date: Wed, 06 Aug 2014 17:41:03 +0200
Message-ID: <1407339663.11943.15.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1407261519050.27164@tomh.mtv.corp.google.com>
	 <1406557222.12728.23.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140729.152937.71880257673026429.davem@davemloft.net>
	 <CA+mtBx_kXTU8Dyn-bR8W2EnrZqU8Rp-2MeP2R2nv3L67aoh==Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:64598 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854AbaHFPlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 11:41:08 -0400
Received: by mail-we0-f180.google.com with SMTP id w61so2784573wes.25
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2014 08:41:07 -0700 (PDT)
In-Reply-To: <CA+mtBx_kXTU8Dyn-bR8W2EnrZqU8Rp-2MeP2R2nv3L67aoh==Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-07-29 at 16:21 -0700, Tom Herbert wrote:

> We still need a context to do the decap though. If we were able to use
> the socket only with rcu and without taking a reference we could just
> call encap_rcv directly from the lookup. I suppose it might be
> plausible to have socket point to another context data structure which
> could be accessed with just rcu protection...

I'll work on UDP stack to get rid of SLAB_DESTROY_BY_RCU, to avoid
refcount atomic ops, and make receiver side faster.

1) UDP sockets are way smaller than TCP ones.

2) Applications wanting fast UDP communications do not
allocate/deallocate sockets for short amount of time.

(netperf has -t TCP_CRR , but no UDP_CRR for example)
