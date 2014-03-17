From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] net: sched: use no more than one page in struct
 fw_head
Date: Mon, 17 Mar 2014 15:30:16 +0000
Message-ID: <20140317153016.GC8956@casper.infradead.org>
References: <1394804798.21721.64.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140314153810.GX21124@linux.vnet.ibm.com>
 <20140314185005.GA17041@linux.vnet.ibm.com>
 <20140314185917.GA18933@linux.vnet.ibm.com>
 <1394826958.9668.4.camel@edumazet-glaptop2.roam.corp.google.com>
 <1394985990.9668.26.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140317135101.GA8956@casper.infradead.org>
 <1395065631.9668.44.camel@edumazet-glaptop2.roam.corp.google.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6DF4C4@AcuExch.aculab.com>
 <1395069365.9668.49.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>,
	John Fastabend <john.fastabend@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:43454 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933526AbaCQPaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 11:30:17 -0400
Content-Disposition: inline
In-Reply-To: <1395069365.9668.49.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/17/14 at 08:16am, Eric Dumazet wrote:
> On Mon, 2014-03-17 at 14:29 +0000, David Laight wrote:
> 
> > Especially for a modulus operation - which requires a second multiply
> > and probably has issues with some large values.
> > 
> > For a hash you could use '(handle * 0x1ffull) >> 32' to reduce the hash.
> 
> Nice try, but this wont work.
> 
> Most of the time @handle is a small value, for example in the 0 .. 100
> range.
> 
> 
> > 
> > or use a 'modulo 2^n-1 reduction':
> > 	handle = (handle & 0x3ffff) + (handle >> 18);
> > 	do
> > 		handle = (handle & 0x1ff) + (handle >> 9);
> > 	while (handle > 0x1ffu);
> 
> All these tricks were needed 20 years ago.
> 
> Even Thomas laptop can do a divide faster than this loop.
> 
> Let the compiler do the thing itself, it is its job.

So why do we have reciprocal_divide()?
