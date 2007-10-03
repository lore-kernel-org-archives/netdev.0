From: David Miller <davem@davemloft.net>
Subject: Re: tcp bw in 2.6
Date: Wed, 03 Oct 2007 01:02:08 -0700 (PDT)
Message-ID: <20071003.010208.08324398.davem@davemloft.net>
References: <4702C37F.4030601@hp.com>
	<20071002.153216.82129058.davem@davemloft.net>
	<20071002223644.GA14331@bitmover.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, torvalds@linux-foundation.org,
	herbert@gondor.apana.org.au, wscott@bitmover.com,
	netdev@vger.kernel.org
To: lm@bitmover.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44041
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752372AbXJCICY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 04:02:24 -0400
In-Reply-To: <20071002223644.GA14331@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: lm@bitmover.com (Larry McVoy)
Date: Tue, 2 Oct 2007 15:36:44 -0700

> On Tue, Oct 02, 2007 at 03:32:16PM -0700, David Miller wrote:
> > I'm starting to have a theory about what the bad case might
> > be.
> > 
> > A strong sender going to an even stronger receiver which can
> > pull out packets into the process as fast as they arrive.
> > This might be part of what keeps the receive window from
> > growing.
> 
> I can back you up on that.  When I straced the receiving side that goes
> slowly, all the reads were short, like 1-2K.  The way that works the 
> reads were a lot larger as I recall.

My issue turns out to be hardware specific too.

The two Broadcom 5714 onboard NICs on my Niagara t1000 give bad packet
receive performance for some reason, the other two which are Broadcom
5704's are perfectly fine.  I'll figure out what the problem is,
probably some misprogramed register in either the chip or the bridge
it's behind.

The UDP stream test of netperf is great for isolating TCP/TSO vs.
hardware issues.  If you can't saturate the pipe or the cpu with
the UDP stream test, it's likely a hardware issue.

The cpu utilization and service demand numbers provided, on both
send and receive, are really useful for diagnosing problems like
this.

Rick deserves several beers for his work on this cool toy. :)
