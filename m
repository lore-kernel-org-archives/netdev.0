From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2.6.33 1/3] net: Micrel KSZ8841/2 PCI Ethernet driver
Date: Tue, 19 Jan 2010 16:50:34 -0800
Message-ID: <20100119165034.00f3a8cc@nehalam>
References: <14385191E87B904DBD836449AA30269D021A4A@MORGANITE.micrel.com>
	<20100116.012004.166836523.davem@davemloft.net>
	<14385191E87B904DBD836449AA30269D580A76@MORGANITE.micrel.com>
	<20100119134059.63b355e4@nehalam>
	<14385191E87B904DBD836449AA30269D580AEB@MORGANITE.micrel.com>
	<20100119161147.6faca543@nehalam>
	<14385191E87B904DBD836449AA30269D580B08@MORGANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "Ha, Tristram" <Tristram.Ha@Micrel.Com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753907Ab0ATAur@vger.kernel.org>
In-Reply-To: <14385191E87B904DBD836449AA30269D580B08@MORGANITE.micrel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 19 Jan 2010 16:34:38 -0800
"Ha, Tristram" <Tristram.Ha@Micrel.Com> wrote:

> Stephen Hemminger wrote:
> > On Tue, 19 Jan 2010 15:48:50 -0800
> > "Ha, Tristram" <Tristram.Ha@Micrel.Com> wrote:
> > 
> >> Stephen Hemminger wrote:
> >>>> Now for the driver implementation for STP support.  I programmed
> >>>> the switch's static MAC table to always pass the following frames
> >>>> to the
> >>>> host: BPDU frames with specific multicast address, broadcast
> >>>> frames, unicast frames with the device bridge's MAC address, and
> >>>> multicast frames with ICMPv6 multicast address.  All other frames
> >>>> are not
> >> passed
> >>>> to the host and are handled by the switch, forwarding each frame
> >>>> with its standard forwarding logic.  The port can be shut off if it
> >>>> is blocked and those frames will not pass through that port.  The
> >>>> host gets BPDU frames so that the bridge can determine each port's
> state.
> >>>> The other broadcast, unicast, and multicast frames passed to the
> >>>> host are necessary if some other network devices want to
> >>>> communicate with the host.  As the forwarding is done by hardware
> >>>> rather than
> >> software,
> >>>> overall performance does increase.
> >>> 
> >>> What about LACP needed by bridging?
> >>> 
> >> 
> >> I am not aware of LACP and do not know how this protocol works under
> >> bridging.  If the requirement is certain multicast frames do not get
> >> forwarded and must pass to the host bridge, I can add those fixed
> >> multicast addresses.  The static MAC table has 8 entries, so there
> are
> >> 4 more to use.
> > 
> > Anything 01:80:C2:00:00:00 should go local host.
> > LACP is part of 802.3ad bonding and uses 01:80:C2:00:02
> > 
> > In general anything to 01:80:C2:00:00:XX is likely to be used by some
> IEEE 802 standard for link
> > only multicast. 

I wouldn't worry about anything but STP.

> If the strict requirement is to support all 01:80:C2:00:00:XX multicast
> addresses, my scheme will not work.  It was designed only for STP, as
> most our customers request that feature.
> 
> I will pass your suggestions to our hardware engineers so that they can
> develop a better switch engine.

It is fine as is, just a warning of what standards committees are
likely to invent in future.

-- 
