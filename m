From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Tue, 3 Feb 2009 22:53:13 +1100
Message-ID: <20090203115313.GA9018@gondor.apana.org.au>
References: <20090202080855.GA4129@ff.dom.local> <20090202.001854.261399333.davem@davemloft.net> <20090202084358.GB4129@ff.dom.local> <20090202.235017.253437221.davem@davemloft.net> <20090203094108.GA4639@ff.dom.local> <20090203111012.GA16878@ioremap.net> <20090203112431.GA8746@gondor.apana.org.au> <20090203114944.GA21957@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36847 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751655AbZBCLyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 06:54:32 -0500
Content-Disposition: inline
In-Reply-To: <20090203114944.GA21957@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 03, 2009 at 02:49:44PM +0300, Evgeniy Polyakov wrote:
> How many such preallocated frames is enough? Does it enough to have all
> sockets recv buffer sizes divided by the MTU size? Or just some of them,
> or... That will work but there are way too many corner cases.

Easy, the driver is already allocating them right now so we don't
have to change a thing :)

All we have to do is change the refill mechanism to always allocate
a replacement skb in the rx path, and if that fails, allocate a
fragmented skb instead and copy the received data into it so that
the contiguous skb can be reused.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
