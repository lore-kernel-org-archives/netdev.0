From: Jens Rosenboom <me@jayr.de>
Subject: Re: [BUG] netxen: Stops working between 2.6.30 and 2.6.31-rc1
Date: Fri, 20 Nov 2009 17:11:04 +0100
Message-ID: <20091120161104.GN14661@jayr.de>
References: <20091119163908.GJ14661@jayr.de> <7608421F3572AB4292BB2532AE89D5658B0B95BD5C@AVEXMB1.qlogic.org> <20091119183607.GK14661@jayr.de> <7608421F3572AB4292BB2532AE89D5658B0B95BDC9@AVEXMB1.qlogic.org> <20091120074903.GL14661@jayr.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dhananjay Phadke <dhananjay.phadke@qlogic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Amit Salecha <amit.salecha@qlogic.com>
To: Jens Rosenboom <me@jayr.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout7.freenet.de ([195.4.92.97]:33252 "EHLO mout7.freenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753149AbZKTQLW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Nov 2009 11:11:22 -0500
Content-Disposition: inline
In-Reply-To: <20091120074903.GL14661@jayr.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2009 at 08:49:03AM +0100, Jens Rosenboom wrote:
> On Thu, Nov 19, 2009 at 02:11:33PM -0800, Dhananjay Phadke wrote:
> > > Sorry, I forgot to mention that all later kernels that I tested
> > > including 2.6.31 and the current net-2.6 also fail, so the badness
> > > comes in somewhere in between 2.6.30 and 2.6.31-rc1.
> > > 
> > > I also noticed that the newer kernel allocate four interrupts for the
> > > card instead of only one, but none of them seem to get triggered, the
> > > /proc/interrupts counters all stay at zero.
> > 
> > What firmware revision you have? Since you are saying nothing
> > transmitted as well, I doubt if you have a link. Otherwise I
> > would imagine kernel tries to send some neighbor solicitation
> > crap as soon as you bring up interface. What does your
> > "ethtool ethx" say about the link? 
> 
> ethtool says "Link detected: yes" , if I try to ping a different host on the 
> LAN the MAC of the card appears in the FDB on the switch, so I'm pretty sure 
> that packets do get sent even if the kernel doesn't get a report for that 
> because of the broken interrupts. Firmware is 3.4.336, which is the only one 
> I could find from IBM Japan, the original Netxen pages seem to have been dumped
> by Qlogic. :-( The firmware on the card itself is being rejected by the
> kernel as too old.
> 
> > It's possible to bisect commits which applied in driver/net/netxen.
> > That way you have fewer commits to rewind and remains focused on
> > the driver rather than screwing scsi.
> 
> I did restrict the bisect to net/ + driver/net and still ran into trouble,
> I can retry with your suggestion.

Sorry for following up to myself, but I made some progress. The bisect still
broke things, so I started to try to patch the latest kernel to use only a
single interrupt, but that didn't help either.

But I managed in finding another firmware which has version v3.4.250, which
is called "legacy" by the kernel. Loading this firmware results also in the
driver only using one interrupt, and the good news is: It Works. ;-)

Maybe this helps you to further narrow down the problem, I'm also ready to
take some testing/debugging patches or send you any other information that
might be helpful.
