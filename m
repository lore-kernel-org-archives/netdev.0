From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Mon, 19 Jan 2009 07:11:21 +0100
Message-ID: <20090119061120.GA12946@1wt.eu>
References: <20090115234408.GA1693@1wt.eu> <20090115.155434.206643894.davem@davemloft.net> <20090119004206.GA10396@1wt.eu> <20090118.192815.41774176.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, jarkao2@gmail.com, zbr@ioremap.net,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1603 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758536AbZASGOw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2009 01:14:52 -0500
Content-Disposition: inline
In-Reply-To: <20090118.192815.41774176.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 18, 2009 at 07:28:15PM -0800, David Miller wrote:
> From: Willy Tarreau <w@1wt.eu>
> Date: Mon, 19 Jan 2009 01:42:06 +0100
> 
> > Hi guys,
> > 
> > On Thu, Jan 15, 2009 at 03:54:34PM -0800, David Miller wrote:
> > > From: Willy Tarreau <w@1wt.eu>
> > > Date: Fri, 16 Jan 2009 00:44:08 +0100
> > > 
> > > > And BTW feel free to add my Tested-by if you want in case you merge
> > > > this fix.
> > > 
> > > Done, thanks Willy.
> > 
> > Just for the record, I've now re-integrated those changes in a test kernel
> > that I booted on my 10gig machines. I have updated my user-space code in
> > haproxy to run a new series of tests. Eventhough there is a memcpy(), the
> > results are EXCELLENT (on a C2D 2.66 GHz using Myricom's Myri10GE NICs) :
> > 
> >   - 4.8 Gbps at 100% CPU using MTU=1500 without LRO
> >     (3.2 Gbps at 100% CPU without splice)
> > 
> >   - 9.2 Gbps at 50% CPU using MTU=1500 with LRO
> > 
> >   - 10 Gbps at 20% CPU using MTU=9000 without LRO (7 Gbps at 100% CPU without
> >     splice)
> > 
> >   - 10 Gbps at 15% CPU using MTU=9000 with LRO
> 
> Thanks for the numbers.
> 
> We can almost certainly do a lot better, so if you have the time and
> can get some oprofile dumps for these various cases that would be
> useful to us.

No problem, of course. It's just a matter of time, but if we can push
the numbers further, let's try.

Regards,
Willy

