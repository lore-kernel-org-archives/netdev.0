From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Add NAPI support to ll_temac driver
Date: Wed, 20 Apr 2011 13:47:05 +0100
Message-ID: <1303303625.3464.103.camel@localhost>
References: <4DAD5753.4040108@monstr.eu>
	 <1303209787.3480.9.camel@edumazet-laptop>
	 <1303215925.3464.54.camel@localhost>  <4DAD84B1.9020405@monstr.eu>
	 <1303218898.3464.59.camel@localhost>  <4DAEBE44.4060801@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:38289 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752710Ab1DTMrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 08:47:10 -0400
In-Reply-To: <4DAEBE44.4060801@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-04-20 at 13:06 +0200, Michal Simek wrote:
[...]
> I have measured TX path and I have found that driver design is not so good.
> It is always create one BD for one SKB and it starts DMA to copy packet to 
> controller and send it.

You will always get a single packet at a time to push to the hardware.
The only improvement you can make on this is to implement segmentation
offload, but if the hardware doesn't do this then... well, it's not
easy.

> On 66MHz cpu it takes approximately 800 cpu cycles (not 
> 800 instructions) for sending (1.5k packet).
> Current driver also enable irq for TX and when the packet is send interrupt is 
> generated and skb is freed.
> I see that it takes more time to handle the IRQ than busy waiting when DMA is 
> done. I looked at sfc driver and there is any TX queue and any notifier. Hos 
> does it work? Is it required to have any hw support?

The principle of NAPI is that once you receive an IRQ you mask it and
poll until there are no more completions to handle.  So it greatly
reduces this IRQ overhead.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

