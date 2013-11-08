From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next] net: introduce dev_set_forwarding()
Date: Thu, 07 Nov 2013 18:42:34 -0800
Message-ID: <1383878554.9412.153.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383584130.1553.2.camel@bwh-desktop.uk.level5networks.com>
	 <20131107.161755.355597965034457889.davem@davemloft.net>
	 <20131107213111.GA6885@gondor.apana.org.au>
	 <20131107.170651.1819930710384730745.davem@davemloft.net>
	 <20131108021758.GA13467@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:41084 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757114Ab3KHCml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 21:42:41 -0500
Received: by mail-pb0-f46.google.com with SMTP id un15so1511581pbc.19
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 18:42:40 -0800 (PST)
In-Reply-To: <20131108021758.GA13467@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-08 at 10:17 +0800, Herbert Xu wrote:

> Oh no let's keep it as it is indeed a great cleanup and improvement
> for LRO.  We can however remove the bits that relate to GRO.

What about doing a benchmark first ?

I benchmarked the 'locally delivered' traffic, not the forwarding one.

That's why I am not comfortable of having large GRO packets that need
to be segmented.

You tell us hardware advantage of TSO is negligible, this is not
what I observe today on many platforms.

A normal TSO packets with 16 MSS setups a ~17 DMA descriptors,
while GSO requires 2 DMA descriptors per MSS, plus a lot of overhead
in sk_buff allocation/deallocation.
