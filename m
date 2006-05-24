From: Jeff Garzik <jeff@garzik.org>
Subject: Re: reminder, 2.6.18 window...
Date: Wed, 24 May 2006 16:08:50 -0400
Message-ID: <4474BD52.6020604@garzik.org>
References: <20060523.182217.59656237.davem@davemloft.net> <4474AE92.3030501@garzik.org> <20060524191442.GG22881@ipom.com> <200605241501.53477.bcook@bpointsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Phil Dibowitz <phil@ipom.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34443 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932260AbWEXUIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 16:08:55 -0400
To: Brent Cook <bcook@bpointsys.com>
In-Reply-To: <200605241501.53477.bcook@bpointsys.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brent Cook wrote:
> Note that this is just clearing the hardware statistics on the interface, and 
> would not require any kind of atomic_increment addition for interfaces that 
> support that. It would be kind-of awkward to implement this on drivers that  
> increment stats in hardware though (lo, vlan, br, etc.) This also brings up 
> the question of resetting the stats for 'netstat -s'

If you don't atomically clear the statistics, then you are leaving open 
a window where the stats could easily be corrupted, if the network 
interface is under load.

This 'clearing' operation has implications on the rest of the statistics 
usage.

More complexity, and breaking of apps, when we could just use the 
existing, working system?  I'll take the "do nothing, break nothing, 
everything still works" route any day.


> What would be great is if ifconfig, netstat and their ilk just had a -z flag 
> instead. This would write a file to the local user's home directory with a 
> stats snapshot, and then every subsequent run would auto-calculate against 
> the snapshot. You'd also need some way of resetting this when the stats 
> actually _do_ reset (driver reload, reboot.) to avoid negative numbers.
> That way, you can get what you want without having to write a bunch of 
> fragile, awkward scripts, and the kernel isn't throwing away information 
> either.

See...  this opens doors to tons of complexity.

	Jeff


