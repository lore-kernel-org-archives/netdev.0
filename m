From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH,pktgen] account for preamble and inter-packet gap
Date: Mon, 29 Nov 2004 07:37:42 +0100
Message-ID: <20041129063742.GA14493@xi.wantstofly.org>
References: <20041128213251.GA9330@xi.wantstofly.org> <41AA95BB.7060400@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robert.olsson@data.slu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <41AA95BB.7060400@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Nov 28, 2004 at 07:21:31PM -0800, Ben Greear wrote:

> >If you account for the Frame Check Sequence when computing bandwidth
> >stats, it's only fair that you count the preamble and inter-packet gap
> >as well.  Suggested patch attached.
> 
> a) When an ethernet NIC claims 100Mbps, does this count the preamble and 
> IPG?

Yes.  That's how we arrive at the 148kpps 'max pps for fast ethernet'
figure -- 100000000 bits per second, each packet taking 8*(8+60+4+12)
bits on the wire.

Another person suggested in private that what I'm after is properly
called '% utilization'.  It might not be possible to determine the
speed of the physical medium though.

In either case, it seems wrong to count the FCS but not the preamble/IPG.
Maybe it's more appropriate to remove the FCS from the calculations.


--L
