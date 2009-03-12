From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 19:25:04 +0000
Message-ID: <20090312192504.GB16611@shareable.org>
References: <49B82566.3070909@weinigel.se> <20090311171354.04c7a63d@nehalam> <49B8E6D4.2030702@weinigel.se> <20090312.055523.193191701.davem@davemloft.net> <49B91A7B.7050303@weinigel.se> <20090312151211.GB24995@hmsreliant.think-freely.org> <49B93777.7030202@weinigel.se> <20090312174933.GC24995@hmsreliant.think-freely.org> <49B95386.2030600@weinigel.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	s.hauer@pengutronix.de, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: Christer Weinigel <christer@weinigel.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.shareable.org ([80.68.89.115]:32799 "EHLO
	mail2.shareable.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754769AbZCLTZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 15:25:14 -0400
Content-Disposition: inline
In-Reply-To: <49B95386.2030600@weinigel.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christer Weinigel wrote:
> > You don't need klibc, you can use regular glibc, and even build
> > statically if you like.  You'll have to use dig or host to do name
> > lookups, but thats also pretty easy to do.  This really is easier
> > than you think it is :)
> 
> Size, size, size.  The killer in the embedded world which rules out 
> glibc.  And have you tried to link glibc statically with something that 
> uses gethostbyname lately?  It is no longer possible since the 
> introduction of all the introduction of the dynamic name lookup crap 
> (ok, it's not really crap, I just feel like it's crap every time I try 
> to link a networking application statically).

In other words, glibc doesn't work on some embedded targets even if
you have plenty of room: they don't support dynamic libs.

> uclibc also seems to have issues with networking and statically linked 
> binaries, but I just haven't had time to figure out why yet.

I've never had an issue with uclibc and networking.

> In my opion, having a "hwaddrs=eth0=00:de:ad:be:ef:01" would be 
> consistent and maintainable.  But opinions differ.

I believe the party line on such things is "use udev". 

Of course, realistically you can't use udev on little embedded systems
and you probably wouldn't use it inside initrd either.  Oh well!

To fix the device name with udev you often match on MAC address :-)

> Once again, in your opinion it is a hack, I don't consider it more a 
> hack than assigning the IP address on the command line.  And I wouldn't 
> call the in kernel stuff useless.

That's a good point.

If assigning the MAC to a particular device "eth0" is dubious -
someone said because device names aren't guaranteed.  Well, why is
assigning the IP address ok?

> Yes, and the next time I would have to fix this on an embedded board, I 
> could probably have spent the time on figure out how to do something 
> slightly more generic, but since it won't have a chance of getting into 
> the kernel, I probably won't.

Another good point: There have been complaints, of a sort, that
embedded developers don't feed back enough of their work upstream.

It's not surprising if this is typical of the objections.

I'm totally failing to see why _if_ setting the IP address on the
kernel command line, for the kernel to apply, is ok, but the MAC is
not.  Both or neither.  Fair enough that the IP option was put in a
long time ago, before policies changed.  But as long as that
capability is there and used and useful, it's ridiculous that it can't
be marginally improved.

-- Jamie

