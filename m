From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH net-next] net: allocate skbs on local node
Date: Thu, 14 Oct 2010 12:27:52 -0700
Message-ID: <20101014122752.21dd4eaf.akpm@linux-foundation.org>
References: <1286838210.30423.128.camel@edumazet-laptop>
	<1286839363.30423.130.camel@edumazet-laptop>
	<1286859925.30423.184.camel@edumazet-laptop>
	<20101011230322.f0f6dd47.akpm@linux-foundation.org>
	<AANLkTin8FczYpPvi79w7iuKOZz3uZtYFfTPitAgQFxzD@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Christoph Hellwig <hch@lst.de>,
	Christoph Lameter <cl@linux-foundation.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35482 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753146Ab0JNT2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 15:28:37 -0400
In-Reply-To: <AANLkTin8FczYpPvi79w7iuKOZz3uZtYFfTPitAgQFxzD@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Oct 2010 08:31:01 -0700
Tom Herbert <therbert@google.com> wrote:

> > This is all conspicuously hand-wavy and unquantified. __(IOW: prove it!)
> >
> > The mooted effects should be tested for on both slab and slub, I
> > suggest. __They're pretty different beasts.
> > --
> 
> Some results running netper TCP_RR test with 200 instances, 1 byte
> request and response on 16 core AMD using bnx2x with one 16 queues,
> one for each CPU.
> 
> SLAB
> 
> Without patch 553570 tps at 86% CPU
> With patch 791883 tps at 93% CPU
> 
> SLUB
> 
> Without patch 704879 tps at 95% CPU
> With patch 775278 tps at 92% CPU
> 
> I believe both show good benfits with patch, and it actually looks
> like the impact is more pronounced for SLAB.  I would also note, that
> we have actually already internally patched __netdev_alloc_skb to do
> local node allocation which we have been running in production for
> quite some time.
> 

Yes, that's a solid gain.

Can we think of any hardware configuration for which the change would
be harmful?  Something with really expensive cross-node DMA maybe?

