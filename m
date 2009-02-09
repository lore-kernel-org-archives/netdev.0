From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 002/002] de2104x: support for systems lacking cache
 coherence
Date: Sun, 08 Feb 2009 23:45:02 -0800 (PST)
Message-ID: <20090208.234502.197065045.davem@davemloft.net>
References: <46e1c7760902071330i5362fe4fvd99fc7075fc666d3@mail.gmail.com>
	<46e1c7760902082327s1c498ac3w56939960ac306426@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: risto.suominen@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53856
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753939AbZBIHpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 02:45:08 -0500
In-Reply-To: <46e1c7760902082327s1c498ac3w56939960ac306426@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Risto Suominen <risto.suominen@gmail.com>
Date: Mon, 9 Feb 2009 09:27:49 +0200

> Add a configurable Descriptor Skip Length for systems that lack cache coherence.
> 
> Signed-off-by: Risto Suominen <Risto.Suominen@gmail.com>

I really don't see why this patch could possibly be necessary.

On systems that lack cache coherence:

1) {pci,dma}_alloc_{consistent,coherent}() give kernel mappings of
   the buffer with the cache disabled.  Therefore the device and
   and cpu see the correct data.

2) {pci,dma}_{map,unmap}_{single,sg}() do the appropriate cache
   flushing.

   Explicit syncing between cpu and device can be performed
   using {pci,dma}_sync_{single,sg}() as needed.

Therefore, this patch is superfluous.
