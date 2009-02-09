From: Risto Suominen <risto.suominen@gmail.com>
Subject: Re: [PATCH 002/002] de2104x: support for systems lacking cache
	coherence
Date: Mon, 9 Feb 2009 10:22:15 +0200
Message-ID: <46e1c7760902090022g1d903ca0nf314f0c1cc6b07c8@mail.gmail.com>
References: <46e1c7760902071330i5362fe4fvd99fc7075fc666d3@mail.gmail.com>
	 <46e1c7760902082327s1c498ac3w56939960ac306426@mail.gmail.com>
	 <20090208.234502.197065045.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:43670 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750696AbZBIIWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 03:22:17 -0500
Received: by bwz5 with SMTP id 5so951973bwz.13
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2009 00:22:15 -0800 (PST)
In-Reply-To: <20090208.234502.197065045.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/2/9 David Miller <davem@davemloft.net>:
> From: Risto Suominen <risto.suominen@gmail.com>
> Date: Mon, 9 Feb 2009 09:27:49 +0200
>
>> Add a configurable Descriptor Skip Length for systems that lack cache coherence.
>>
>> Signed-off-by: Risto Suominen <Risto.Suominen@gmail.com>
>
> I really don't see why this patch could possibly be necessary.
>
Because it makes it work on my PowerMac 5500 ;)

> On systems that lack cache coherence:
>
> 1) {pci,dma}_alloc_{consistent,coherent}() give kernel mappings of
>   the buffer with the cache disabled.  Therefore the device and
>   and cpu see the correct data.
>
> 2) {pci,dma}_{map,unmap}_{single,sg}() do the appropriate cache
>   flushing.
>
>   Explicit syncing between cpu and device can be performed
>   using {pci,dma}_sync_{single,sg}() as needed.
>
Sounds good, but does not seem to help. My theory is that when the cpu
is writing to one descriptor, it accidentally overwrites another
descriptor, that has already been written to by the device, as there
is only a single dirty bit, that makes the whole cacheline to be
flushed.

> Therefore, this patch is superfluous.
>
Or everything else is. My solution does not cost a penny.

Risto
