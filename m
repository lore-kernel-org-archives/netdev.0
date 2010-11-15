From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: the future of ethtool
Date: Mon, 15 Nov 2010 20:18:46 +0000
Message-ID: <1289852326.2586.32.camel@bwh-desktop>
References: <4CE18CEA.5080502@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:52348 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932833Ab0KOUSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 15:18:49 -0500
In-Reply-To: <4CE18CEA.5080502@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-11-15 at 14:41 -0500, Jeff Garzik wrote:
> Thanks for accepting ethtool maintainership.
> 
> There are two key unresolved issues with ethtool that are worth noting 
> to the next maintainer.  Both of these come from years of user and 
> customer complaints.
> 
> 1) ethtool command line interface.
> 
> For 1,001 minor reasons of user taste and expectation, people tend to 
> complain about the command line interface.  Due to script usage it is 
> set in stone, and has been since before my tenure.  But users 
> continually request something more flexible, often, in particular, 
> wanting to set multiple settings in one execution, or wanting to apply 
> the same setting to multiple interface in one execution.
> 
> Obviously one can script this, but, it is probably the #1 user request.

Thinking further along those lines, it would be useful to have ethtool
API bindings for Perl/Python/whatever, though those belong outside of
the current ethtool package.  I tried doing that for use in my own
scripts and it looks reasonably practical, though I'm not volunteering
to maintain such bindings.

> My thought was to create "nictool", a new tool with more flexible 
> command line interface, using the same old ethtool ioctls currently in 
> use today.  ('nictool' also solves a minor naming complaint from 
> wireless and other people, who use ethtool on non-ethernet network 
> interfaces)

I agree, some of the ethtool operations are very Ethernet-specific but
enough of them are applicable to other media that this makes sense.

I've recently been looking at FreeBSD where the sort of configuration we
do through ethtool is invoked through ifconfig, but then ifconfig is
effectively deprecated on Linux...

> 2) multiple settings and the ethtool kernel interface
> 
> Another common complaint is related to multiple settings, and associated 
> hardware NIC resets.
> 
> Many ethtool driver implementations look like this:
> 
> 	ethtool_op_do_something()
> 		stop RX/TX
> 		apply settings
> 		perform full NIC reset, consuming much time
> 		start RX/TX
> 
> The problem arises when the user wishes to change multiple hardware 
> attributes at the same time.  A user wishing to change 4 attributes 
> could wind up with 4 ethtool(1) invocations, with 4 accompanying 
> hardware NIC resets.  Time consuming, inefficient, and unnecessary.

Right.  In fact the begin() and complete() operations look like they
were meant to support this sort of optimisation.  Is that the case?

Ben.

> Obviously the world has not ended without these changes, but these items 
> do cause continued complaints from users, and we're here to be 
> responsive to users presumably ;-)


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

