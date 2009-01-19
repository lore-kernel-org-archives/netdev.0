From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Mon, 19 Jan 2009 12:59:41 -0800 (PST)
Message-ID: <20090119.125941.240930524.davem@davemloft.net>
References: <20090119061420.GB12946@1wt.eu>
	<20090118.221908.47032075.davem@davemloft.net>
	<20090119101924.GA1881@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, jarkao2@gmail.com, zbr@ioremap.net, dada1@cosmosbay.com,
	ben@zeus.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47791
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753844AbZASU7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 15:59:40 -0500
In-Reply-To: <20090119101924.GA1881@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 19 Jan 2009 21:19:24 +1100

> On Sun, Jan 18, 2009 at 10:19:08PM -0800, David Miller wrote:
> > 
> > Actually, I see, the myri10ge driver does put up to
> > 64 bytes of the initial packet into the linear area.
> > If the IPV4 + TCP headers are less than this, you will
> > hit the corruption case even with the myri10ge driver.
> 
> I thought splice only mapped the payload areas, no?

And the difference between 64 and IPV4+TCP header len becomes the
payload, don't you see? :-)

myri10ge just pulls min(64, skb->len) bytes from the SKB frags into
the linear area, unconditionally.  So a small number of payload bytes
can in fact end up there.

Otherwise Willy could never have triggered this bug.
