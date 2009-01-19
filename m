From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Sun, 18 Jan 2009 19:27:19 -0800 (PST)
Message-ID: <20090118.192719.198405397.davem@davemloft.net>
References: <20090115.155434.206643894.davem@davemloft.net>
	<20090119004206.GA10396@1wt.eu>
	<20090119030844.GA31941@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, jarkao2@gmail.com, zbr@ioremap.net, dada1@cosmosbay.com,
	ben@zeus.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33554
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750942AbZASD1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 22:27:18 -0500
In-Reply-To: <20090119030844.GA31941@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 19 Jan 2009 14:08:44 +1100

> On Mon, Jan 19, 2009 at 01:42:06AM +0100, Willy Tarreau wrote:
> >
> > Just for the record, I've now re-integrated those changes in a test kernel
> > that I booted on my 10gig machines. I have updated my user-space code in
> > haproxy to run a new series of tests. Eventhough there is a memcpy(), the
> > results are EXCELLENT (on a C2D 2.66 GHz using Myricom's Myri10GE NICs) :
> > 
> >   - 4.8 Gbps at 100% CPU using MTU=1500 without LRO
> >     (3.2 Gbps at 100% CPU without splice)
> 
> One thing to note is that Myricom's driver probably uses page
> frags which means that you're not actually triggering the copy.

Right.

And this is also the only reason why jumbo MTU worked :-)
