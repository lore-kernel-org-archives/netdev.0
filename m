From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Mon, 19 Jan 2009 07:14:20 +0100
Message-ID: <20090119061420.GB12946@1wt.eu>
References: <20090115.155434.206643894.davem@davemloft.net> <20090119004206.GA10396@1wt.eu> <20090119030844.GA31941@gondor.apana.org.au> <20090118.192719.198405397.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, jarkao2@gmail.com, zbr@ioremap.net,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1600 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755960AbZASGOp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2009 01:14:45 -0500
Content-Disposition: inline
In-Reply-To: <20090118.192719.198405397.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 18, 2009 at 07:27:19PM -0800, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Mon, 19 Jan 2009 14:08:44 +1100
> 
> > On Mon, Jan 19, 2009 at 01:42:06AM +0100, Willy Tarreau wrote:
> > >
> > > Just for the record, I've now re-integrated those changes in a test kernel
> > > that I booted on my 10gig machines. I have updated my user-space code in
> > > haproxy to run a new series of tests. Eventhough there is a memcpy(), the
> > > results are EXCELLENT (on a C2D 2.66 GHz using Myricom's Myri10GE NICs) :
> > > 
> > >   - 4.8 Gbps at 100% CPU using MTU=1500 without LRO
> > >     (3.2 Gbps at 100% CPU without splice)
> > 
> > One thing to note is that Myricom's driver probably uses page
> > frags which means that you're not actually triggering the copy.

So does this mean that the corruption problem should still there for
such a driver ? I'm asking before testing, because at these speeds,
validity tests are not that easy ;-)

> Right.
> 
> And this is also the only reason why jumbo MTU worked :-)

What should we expect from other drivers with jumbo frames ? Hangs,
corruption, errors, packet loss ?

Thanks,
Willy

