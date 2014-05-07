From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Wed, 7 May 2014 14:59:38 +0100
Message-ID: <20140507145938.79110827@alan.etchedpixels.co.uk>
References: <1399328773-6531-9-git-send-email-andi@firstfloor.org>
	<20140505.231229.136734008603421707.davem@davemloft.net>
	<20140506032114.GP2382@two.firstfloor.org>
	<20140505.232327.578134514220748085.davem@davemloft.net>
	<1399351148.8767.84.camel@empanada>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tom Zanussi <tom.zanussi@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399351148.8767.84.camel@empanada>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> But why go to all that trouble when there's a perfectly good networking
> stack in the kernel?  Even if most of these options aren't things that
> would be useful to most systems, being able to turn them off and save
> 1/3 of the kernel text size for tiny systems like this does makes a big
> difference...

There are a vast number of low memory devices for various platforms and
FPGA devices. I've also been looking at this for some other projects and
there is a reason I went back and started playing with 2.11BSD. 

> So why bothers 3.15+ Linux kernel? Why not use an old kernel e.g. 2.4.x?
> 2.4.x kernel doesn't have so many new features you want to get rid of here.

Simple answer. 2.11BSD is vastly superior on a small system to 2.4.x
Linux. Also 2.4 is old and lightly maintained. Even forking 3.15 into
bloatix and embedded Linux (ELKS2 ;-)) would make more sense.

2/11BSD has the advantage that you don't need virtual memory and you
don't have the cost of page tables which are mostly useless on a device
that small these days because I/O speeds are so much higher. It has a
bloatfree userspace, although it does need chunks of the openbsd security
work backporting.

Forking a current Linux would give you all the modern stuff wanted like
USB, SPI, eMMC etc but comes with all the debloating work and some
annoying assumptions about memory. Do the fork off GregKH's next long
term kernel and it wouldn't be that horrific to maintain until there is a
clear picture about uses and whether it justifies merging ?

> Another poster commented that 16MB of DRAM would be cheaper than
> the 2MB of ram you have on these boards, probably one that fits
> your size profile is available as well.

16MB of DRAM means adding a chip to your system. You've just exceeded the
space, power and cost budget on the very low end. In many cases like FPGA
systems you can't even add DRAM without major hoop jumping.

On the Linux side there's also a ton of other stuff with vm handling that
could be done far better for a small x86 device if the kernel was split
(for now anyway). If it gets a lot of users then DaveM's arguments about
unjustified maintenance hassle go away and it an then get re-merged.

> 2MB is just a rediculous restriction.

Linux used to run fine in 2MB ;-)

> And last time I checked Linux wasn't a special purpose operating
> system, but lucky for you I hear there are lots of those around.

Server, desktop, tablet and even phone main OS devices are "special
purpose" in the big picture of processor use. Even today 2MB is "big
computer" to an awful lot of people!

Alan
