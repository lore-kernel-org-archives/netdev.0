From: Brent Cook <bcook@bpointsys.com>
Subject: Re: reminder, 2.6.18 window...
Date: Wed, 24 May 2006 15:01:53 -0500
Message-ID: <200605241501.53477.bcook@bpointsys.com>
References: <20060523.182217.59656237.davem@davemloft.net> <4474AE92.3030501@garzik.org> <20060524191442.GG22881@ipom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 70-253-197-251.ded.swbell.net ([70.253.197.251]:63620 "EHLO
	bpointsys.com") by vger.kernel.org with ESMTP id S1751008AbWEXUB7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 May 2006 16:01:59 -0400
To: Phil Dibowitz <phil@ipom.com>
In-Reply-To: <20060524191442.GG22881@ipom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 24 May 2006 14:14, Phil Dibowitz wrote:
> On Wed, May 24, 2006 at 03:05:54PM -0400, Jeff Garzik wrote:
> > Phil Dibowitz wrote:
> > Given any method of clearing statistics across your cluster, I'm certain
> > you can come up with a similar method of obtaining the current statistic
> > (the baseline).
>
> Right, I'm aware there are other ways of doing this - I've written scripts
> to record a hundreds of numbers, and then subtract them from each other.
> But those scripts are work arounds for a feature _lacking_ in the kernel. A
> feature that, as I've mentioned, is supported on any piece of networking
> gear (and of course, lets not forget there's a specific option in the
> kernel config *just* for "behave like a router").
>
> If my patch was invasive and broke things, I would understand the
> hesitation, but this is a feature that allows people to *choose* to do this
> if they need to and the code is pretty self-contained.

I'm with you - this is a useful feature! But there aren't many other things 
I've found that can be cleared from the kernel other than by reloading a 
module, and dmesg -c. I think the object here isn't this particular patch, 
but the can-of-worms that it opens up.

Note that this is just clearing the hardware statistics on the interface, and 
would not require any kind of atomic_increment addition for interfaces that 
support that. It would be kind-of awkward to implement this on drivers that  
increment stats in hardware though (lo, vlan, br, etc.) This also brings up 
the question of resetting the stats for 'netstat -s'

What would be great is if ifconfig, netstat and their ilk just had a -z flag 
instead. This would write a file to the local user's home directory with a 
stats snapshot, and then every subsequent run would auto-calculate against 
the snapshot. You'd also need some way of resetting this when the stats 
actually _do_ reset (driver reload, reboot.) to avoid negative numbers.
That way, you can get what you want without having to write a bunch of 
fragile, awkward scripts, and the kernel isn't throwing away information 
either.

 - Brent
