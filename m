From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: DMA allocation driver defined limit?
Date: Thu, 25 Apr 2013 22:31:35 +0100
Message-ID: <1366925495.2594.18.camel@bwh-desktop.uk.solarflarecom.com>
References: <CALZVapkJZotCxzMbGhZfvVV3G8W2z5tehEe7BaTjps620M+-Mw@mail.gmail.com>
	 <1366828908.2600.4.camel@bwh-desktop.uk.solarflarecom.com>
	 <CALZVapn-95Sg33fgzkQGfR6C0t40OZNJAh_e8CoS3E7GL7eiig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Javier Domingo <javierdo1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8244 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758804Ab3DYVbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 17:31:38 -0400
In-Reply-To: <CALZVapn-95Sg33fgzkQGfR6C0t40OZNJAh_e8CoS3E7GL7eiig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-25 at 23:15 +0200, Javier Domingo wrote:
> > I don't see what the network card's memory has got to do with it.  I
> > would expect that you can allocate and DMA-map much more memory (number
> > of rings * number of descriptors per ring * maximum length of
> > descriptor).
> 
> So the limit is on number of skbuff nuber and it is self-imposed by the card.
> 
> > Before you deliver an skb up the stack, you must DMA-unmap the header
> > area. The stack then takes care of limiting the amount of memory in
> > use.
> 
> I have found that the limit on rings is consistent, as it only
> allocates another area when the later one is unmapped.
> 
> One last question is: If netdev_budget is 300, why the DMA ring size
> is 256 by default in e1000? Shouldn't it be greater than 300, so that
> if it has enought packets in one softirq, it could capture them?

There is no connection between these numbers.  Firstly, NAPI doesn't
switch re-enable interrupts on net devices after its budget is exhausted
(indeed, it doesn't know *how* to); it merely allows other soft IRQ
handlers to run.  Secondly, drivers should refill their RX rings well
before they are completely empty, and they may therefore handle more
than an entire ring-full of completions before breaking out of NAPI
polling.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
