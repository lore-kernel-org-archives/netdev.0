From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 002/002] de2104x: support for systems lacking cache  coherence
Date: Mon, 09 Feb 2009 17:58:25 +0100
Message-ID: <m3vdrja6oe.fsf@intrepid.localdomain>
References: <46e1c7760902071330i5362fe4fvd99fc7075fc666d3@mail.gmail.com>
	<46e1c7760902082327s1c498ac3w56939960ac306426@mail.gmail.com>
	<20090208.234502.197065045.davem@davemloft.net>
	<46e1c7760902090022g1d903ca0nf314f0c1cc6b07c8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Risto Suominen <risto.suominen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:51279 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751235AbZBIQ62 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2009 11:58:28 -0500
In-Reply-To: <46e1c7760902090022g1d903ca0nf314f0c1cc6b07c8@mail.gmail.com> (Risto Suominen's message of "Mon\, 9 Feb 2009 10\:22\:15 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Risto Suominen <risto.suominen@gmail.com> writes:

>> 1) {pci,dma}_alloc_{consistent,coherent}() give kernel mappings of
>>   the buffer with the cache disabled.
                ^^^^^^^^^^^^^^^^^^^^^^^

> Sounds good, but does not seem to help. My theory is that when the cpu
> is writing to one descriptor, it accidentally overwrites another
> descriptor, that has already been written to by the device, as there
> is only a single dirty bit, that makes the whole cacheline to be
> flushed.

That means the consistent/coherent mapping isn't really
consistent/coherent (uncached), right? Perhaps there is some way to fix
this instead of changing the drivers to avoid the problematic area?

Potentially any driver is affected by such coherency problem, this can't
be specific to 21040.
-- 
Krzysztof Halasa
