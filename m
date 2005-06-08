From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: NAPI packet weighting patch
Date: Tue, 07 Jun 2005 20:43:39 -0700 (PDT)
Message-ID: <20050607.204339.21591152.davem@davemloft.net>
References: <468F3FDA28AA87429AD807992E22D07E0450C01F@orsmsx408>
	<20050607.132159.35660612.davem@davemloft.net>
	<Pine.LNX.4.62.0506071852290.31708@ladlxr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.ronciak@intel.com, hadi@cyberus.ca, shemminger@osdl.org,
        mitch.a.williams@intel.com, mchan@broadcom.com, buytenh@wantstofly.org,
        jdmason@us.ibm.com, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jesse.brandeburg@intel.com
In-Reply-To: <Pine.LNX.4.62.0506071852290.31708@ladlxr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date: Tue, 7 Jun 2005 19:20:37 -0700 (PDT)

> with the 2.6.12-rc5 kernel (the old) tso promptly shuts down after a SACK, 
> and after that point the machine is CPU bound at 100%.  This is the point 
> that we start to drop packets at the hardware level.

You're getting packet loss on the local network where you're
running these tests?  Or is it simple packet reordering?

> I tried the experiment today where I replenish buffers to hardware every 
> 16 packets or so.  This appears to mitigate all drops at the hardware 
> level (no drops).  We're still at 100% with the rc5 kernel, however.
> 
> even with this replenish fix, the addition of dropping the weight to 16 
> helped increase our throughput, although only about 1%.

Any minor timing difference of any kind can have up to a %3 or
%4 difference in TCP performance when the receiver is CPU
limited.

> On the other hand, taking our driver as is with no changes and running the 
> supertso (not the split out version, yet) kernel, we show no dropped 
> packets and 60% cpu use.  This combines with a 6% increase in throughput, 
> and the data pattern on the wire is much more constant (i have tcpdumps, 
> do you want to see them Dave?)

Yes, indeed the tcpdumps tend to look much nicer with supertso.

The 10gbit guys see regressions though.  They are helping me
test things gradually in order to track down what change causes
the problems.  That's why I've started rewriting super TSO from
scratch in a series of very small patches.

I don't see how supertso can help the receiver, which is where
the RX drops should be occuring.  That's a little weird.

I can't believe a 2.5 GHZ machine can't keep up with a simple 1 Gbit
TCP stream.  Do you have some other computation going on in that
system?  As stated yesterday my 1.5 GHZ crappy sparc64 box can receive
a 1 Gbit TCP stream with much cpu to spare, my 750 MHZ sparc64 box can
nearly do so as well.

Something is up, if a single gigabit TCP stream can fully CPU
load your machine.  10 gigabit, yeah, definitely all current
generation machines are cpu limited over that link speed, but
1 gigabit should be no problem.
