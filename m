From: Daniel Hazelton <dhazelton@enter.net>
Subject: Re: sky2 panic in 2.6.32.1 under load
Date: Thu, 24 Dec 2009 19:06:30 -0500
Message-ID: <200912241906.30879.dhazelton@enter.net>
References: <4B300A2A.8040305@gmail.com> <20091224142146.700e4ac8@nehalam> <4B33EE40.1020402@majjas.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Berck Nash <flyboy@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from keil-draco.com ([216.193.185.50]:55551 "EHLO
	mail.keil-draco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191AbZLYAGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2009 19:06:40 -0500
In-Reply-To: <4B33EE40.1020402@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 24 December 2009 05:42:08 pm Michael Breuer wrote:
> On 12/24/2009 5:21 PM, Stephen Hemminger wrote:
> > On Thu, 24 Dec 2009 11:28:57 -0500
> >
> > Daniel Hazelton<dhazelton@enter.net>  wrote:
> >> On Thursday 24 December 2009 11:03:56 am Berck Nash wrote:
> >>> Andrew Morton wrote:
> >>>> On Mon, 21 Dec 2009 16:52:10 -0700 "Berck E. Nash"<flyboy@gmail.com>
> >>
> >> wrote:
> >>>>> Since 2.6.32, I've been getting kernel panics under heavy network
> >>>>> load (bittorrent usage).
> >>>>
> >>>> Let's cc the right list and developer.
> >>>>
> >>>> This is a 2.6.31->2.6.32 regression?
> >>>
> >>> I believe so.  Since it's intermittent and difficult to reproduce, it's
> >>> possible (but unlikely) that I simply never triggered it under 2.6.31.
> >>
> >> This is far from new. I have seen this under 2.6.27 when at least one
> >> botnet has been pointed at a server of mine and told to gain access. It
> >> has happened four times in the last six to eight months - and I have no
> >> easy way to capture the logs. But the oops that was posted looks very,
> >> very similar to what I've seen.
> >>
> >> It's always an allocation error in the transmit path that leads to the
> >> panic. Because this is a production machine that I do not have a way to
> >> take down and do testing with I've not reported the problem before.
> >
> > Even though I wrote/maintain the sky driver, I don't work for SysKonnect,
> > and only have access to a limited set of information:
> > the technical manuals (under NDA), and the vendor sk98lin driver. The
> > sky2 driver imitates the receiver timeout of the sk98lin driver; other
> > people have told me that the FIFO hardware implementation is buggy and
> > when it gets full, it gets stuck. Probably the equivalent of a software
> > FIFO where the developer forgets to reserve a slot so that head == tail
> > can mean both empty and full!
> >
> > The workaround with a timer is prone to errors when traffic keeps going,
> > also the vendor doesn't really provide clear instructions on how to
> > unlock it. I do not have access to the hardware errata describing the
> > problem. If I did a more minimal solution would be possible.
> >
> > The easiest advice is avoid sky2 chips with FIFO for any heavy traffic,
> > the next advice is make sure receive flow control is enabled so that
> > receiver doesn't get overrun. If tx timeouts are an issue use a rate
> > limiter like TBF. Do not use the chip with 10 or 100 mbit since the
> > transmitter is more prone to get overrun.
> 
> For this particular issue, I'm only seeing problems when running at 1000
> mbit. 100 appears stable.
> 

Not here - it is crashing under 100. I do have a different NIC available for 
that system and will likely switch to it when I have a chance to work on 
upgrading the install there. The reason I am using the Sky NIC on that system 
is because there are, apparently, two different NIC's on the board itself - an 
nForce one and a Sky2 one...

DRH
