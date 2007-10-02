From: lm@bitmover.com (Larry McVoy)
Subject: Re: tcp bw in 2.6
Date: Tue, 2 Oct 2007 14:26:08 -0700
Message-ID: <20071002212608.GG29944@bitmover.com>
References: <20071002154137.GD17418@bitmover.com> <alpine.LFD.0.999.0710020930250.3579@woody.linux-foundation.org> <20071002164858.GH17418@bitmover.com> <20071002.141656.42880006.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lm@bitmover.com, torvalds@linux-foundation.org,
	herbert@gondor.apana.org.au, wscott@bitmover.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipcop.bitmover.com ([192.132.92.15]:43957 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753934AbXJBV0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 17:26:08 -0400
Content-Disposition: inline
In-Reply-To: <20071002.141656.42880006.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 02, 2007 at 02:16:56PM -0700, David Miller wrote:
> We absolutely depend upon people like you to report when there are
> anomalies like this.  It's the only thing that scales.

Well cool, finally doing something useful :)

Is this issue no test setup?  Because this does seem like something we'd
want to have work well.

> FWIW I have a t1000 Niagara box and an Ultra45 going through a netgear
> gigabit switch.  I'm getting 85MB/sec in one direction and 10MB/sec in
> the other (using bw_tcp from lmbench3).  

Note that bw_tcp mucks with SND/RCVBUF.  It probably shouldn't, it's been
12 years since that code went in there and I dunno if it is still needed.

> Both are using identical
> broadcom tigon3 gigabit chips and identical current kernels so that is
> a truly strange result.
> 
> I'll investigate, it may be the same thing you're seeing.

Wow, sounds very similar.  In my case I was seeing pretty close to 3x
consistently.  You're more like 8x, but I was all e1000 not broadcom.

And note that sky2 doesn't have this problem.  Does the broadcom do TSO?
And sky2 not?  I noticed a much higher CPU load for sky2.
-- 
---
Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com
