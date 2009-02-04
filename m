From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Wed, 4 Feb 2009 20:28:20 +0100
Message-ID: <20090204192820.GA27867@1wt.eu>
References: <20090204081201.GB10445@ioremap.net> <20090204085432.GA21638@1wt.eu> <20090204085907.GA19388@gondor.apana.org.au> <20090204.010146.18100191.davem@davemloft.net> <20090204091217.GA21385@1wt.eu> <ada63jqm2mt.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	zbr@ioremap.net, jarkao2@gmail.com, dada1@cosmosbay.com,
	ben@zeus.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2038 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752277AbZBDT3h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2009 14:29:37 -0500
Content-Disposition: inline
In-Reply-To: <ada63jqm2mt.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 04, 2009 at 11:19:06AM -0800, Roland Dreier wrote:
>  > And the arbitrary choice of 9k for jumbo frames was total crap too.
>  > It's clear that no hardware designer was involved in the process.
>  > They have to stuff 16kB of RAM on a NIC to use only 9. And we need
>  > to allocate 3 pages for slightly more than 2. 7.5 kB would have been
>  > better in this regard.
> 
> 9K was not totally arbitrary.  The CRC used for checksumming ethernet
> packets has a probability of undetected errors that goes up about
> 11-thousand something bytes.  So the real limit is ~11000 bytes, and I
> believe ~9000 was chosen to be able to carry 8K NFS payloads + all XDR
> and transport headers without fragmentation.

Yes I know that initial motivation. But IMHO it was a purely functional
motivation without real considerations of the implications. When you
read Alteon's initial proposal, there is even a biased analysis (they
compare the fill ratio obtained with one 8k frame with that of 6 1.5k
frames). Their own argument does not stand with their final proposal!
I think that there might already have been people pushing for 8k and
not 9 by then, but in order to get wide acceptance in datacenters,
they had to please the NFS admins.

Now it's useless to speculate on history and I agree with Davem that
we're wasting our time with this discussion, let's go back to the
keyboard ;-)

Willy

