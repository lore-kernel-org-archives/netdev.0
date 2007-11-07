From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Stack Trace. Bad?
Date: Wed, 7 Nov 2007 13:49:00 +0300
Message-ID: <20071107104900.GB14732@2ka.mipt.ru>
References: <cccedfc60711061136r5ec89e73m7457e9fea0bf4f55@mail.gmail.com> <cccedfc60711061139r11a5e8c6raf6cd64c575ec453@mail.gmail.com> <cccedfc60711061222o6c4599fcyf71265c126568395@mail.gmail.com> <cccedfc60711061223me598dc8sad8dd36577874915@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jon Nelson <jnelson@jamponi.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:55020 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751382AbXKGKsr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 05:48:47 -0500
Content-Disposition: inline
In-Reply-To: <cccedfc60711061223me598dc8sad8dd36577874915@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jon.

On Tue, Nov 06, 2007 at 02:23:03PM -0600, Jon Nelson (jnelson@jamponi.net) wrote:
> [linux-raid was also emailed this same information]

It looks like it was not :)

> I was testing some network throughput today and ran into this.
> I should note that I've this motherboard has 2x MCP55 Ethernet and one
> of them works fine and the other one gives lots and lots of frame
> errors under load.
> 
> The following is only an harmless informational message.
> Unless you get a _continuous_flood_ of these messages it means
> everything is working fine. Allocations from irqs cannot be
> perfectly reliable and the kernel is designed to handle that.
> md0_raid5: page allocation failure. order:2, mode:0x20
> 
> Call Trace:
>  <IRQ>  [<ffffffff802684c2>] __alloc_pages+0x324/0x33d
>  [<ffffffff80283147>] kmem_getpages+0x66/0x116
>  [<ffffffff8028367a>] fallback_alloc+0x104/0x174
>  [<ffffffff80283330>] kmem_cache_alloc_node+0x9c/0xa8
>  [<ffffffff80396984>] __alloc_skb+0x65/0x138
>  [<ffffffff8821d82a>] :forcedeth:nv_alloc_rx_optimized+0x4d/0x18f

What MTU for this card is? Forcedeth supports jumbo frames, but does it
in very unoptimized way, particulary by relying on the possibility to
allocate 2-order pages, which is wrong.

So, set MTU to 1500 and things will be back into good shape.
I think adding fragments support is not a short-term solution because
of closed specs.

-- 
	Evgeniy Polyakov
