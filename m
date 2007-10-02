From: Ben Greear <greearb@candelatech.com>
Subject: Re: tcp bw in 2.6
Date: Tue, 02 Oct 2007 09:48:46 -0700
Message-ID: <4702766E.80202@candelatech.com>
References: <20071002005917.GB5480@bitmover.com> <E1IcfN0-0007tt-00@gondolin.me.apana.org.au> <20071002150935.GC17418@bitmover.com> <20071002154137.GD17418@bitmover.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: lm@bitmover.com, Herbert Xu <herbert@gondor.apana.org.au>,
	torvalds@linux-foundation.org, davem@davemloft.net,
	wscott@bitmover.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:40826 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752794AbXJBQuD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 12:50:03 -0400
In-Reply-To: <20071002154137.GD17418@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Larry McVoy wrote:
> Interesting data point.  My test case is like this:
>
> server
> 	bind
> 	listen
> 	while (newsock = accept...)
> 		transfer()
>
> client
> 	connect
> 	transfer
>
> If the server side is the source of the data, i.e, it's transfer is a 
> write loop, then I get the bad behaviour.  If I switch them so the data
> flows in the other direction, then it works, I go from about 14K pkt/sec
> to 43K pkt/sec.
>
> Can anyone else reproduce this?  I can extract the test case from lmbench
> so it is standalone but I suspect that any test case will do it.  I'll
> try with the one that John sent.  Yup, s/read/write/ and s/write/read/
> in his two files at the appropriate places and I get exactly the same
> behaviour.
>
> So is this a bug or intentional?
>   
I have a more complex configuration & application, but I don't see this 
problem in
my testing.  Using e1000 nics and modern hardware I can set up a connection
between two machines and run 800+Mbps in both directions, or near line speed
in one direction if the other direction is mostly silent.

I am purposefully setting the socket send/rx buffers, as well has 
twiddling with
the tcp and netdev related tunables.  If you want, I can email these 
tweaks to you.

NICs and busses have a huge impact on performance, so make sure those 
are good.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


