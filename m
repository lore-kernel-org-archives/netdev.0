From: Willy Tarreau <w@1wt.eu>
Subject: Re: WARNING: at net/sched/sch_generic.c:219 dev_watchdog+0xfe/0x17e() with tg3 network
Date: Wed, 26 Nov 2008 22:12:20 +0100
Message-ID: <20081126211220.GA22374@1wt.eu>
References: <20081120031101.GD26448@xw6200.broadcom.net> <20081120053746.GB15168@1wt.eu> <20081120184310.GB27712@xw6200.broadcom.net> <20081120212637.GB23844@1wt.eu> <20081120215318.GB27907@xw6200.broadcom.net> <20081124132744.GB24851@1wt.eu> <20081124215247.GA29696@1wt.eu> <20081125015223.GA9151@xw6200.broadcom.net> <20081125053128.GA32426@1wt.eu> <20081125175413.GA9808@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roger Heflin <rogerheflin@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1395 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753191AbYKZVNF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Nov 2008 16:13:05 -0500
Content-Disposition: inline
In-Reply-To: <20081125175413.GA9808@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Matt,

On Tue, Nov 25, 2008 at 09:54:13AM -0800, Matt Carlson wrote:
> On Mon, Nov 24, 2008 at 09:31:28PM -0800, Willy Tarreau wrote:
> > On Mon, Nov 24, 2008 at 05:52:23PM -0800, Matt Carlson wrote:
> > (...)
> > > > tg3: eth0: transmit timed out, resetting
> > > > tg3: DEBUG: MAC_TX_STATUS[0000000b] MAC_RX_STATUS[00000006]
> > > > tg3: DEBUG: RDMAC_STATUS[00000000] WDMAC_STATUS[00000008]
> > > > tg3: tg3_stop_block timed out, ofs=1400 enable_bit=2
> > > > tg3: tg3_stop_block timed out, ofs=c00 enable_bit=2
> > > > tg3: tg3_stop_block timed out, ofs=4c00 enable_bit=2
> > > > tg3: eth0: Link is down.
> > > > tg3: eth0: Link is up at 100 Mbps, full duplex.
> > > > tg3: eth0: Flow control is on for TX and on for RX.
> > > > 
> > > > The ease with which I reproduce it here clearly indicates that this is
> > > > related to the switch, probably just the fact that it is at 100 Mbps.
> > > > Unfortunately this evening I must go, but I still have one 100 Mbps
> > > > switch somewhere at home, I'll reproduce the same test ASAP in order
> > > > to bisect the issue.
> > > > 
> > > > Regards,
> > > > Willy
> > > 
> > > Does turning off flow control help at all?
> > 
> > I have not tested but I will. I hope to be able to trigger the problem
> > on other similar switches, because I'm only once a week connected to
> > the culprit...
> 
> I can't say for certain, but I suspect the problem might be more
> associated with the link speed than the particular switch you are using.
> Can you try autoneg'ing down to a slower speed and see if that helps
> make the problem more reproducable?

I've run a new test on a switch I have here at home (another el-cheapo,
non-manageable 100 Mbps, netgear this time). Unfortunately I cannot
reproduce the problem at all. I have disabled FC on my laptop, it did
not have any effect. I have disabled auto-neg and manually forced the
speed to 100/Full on my laptop, and could not reproduce the problem
either (though the speed was much lower due to the switch obviously
negociating 100/Half when not seeing my NWay frames).

I have tried unplugging the cable during transfers and changing negociation
during transfers, trying to trigger artifacts, but with no result. So I
think that I will really need to debug this on the "faulty" switch on
next monday. It does not surprize me much, because we don't see that
many reports for a similar problem, eventhough the tg3 is very common
in laptops. I just hope it's a recent regression, as I'd prefer avoid
having to bisect from a very old kernel.

I'll keep you informed,
Willy

