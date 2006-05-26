From: Andi Kleen <ak@suse.de>
Subject: Re: reminder, 2.6.18 window...
Date: Fri, 26 May 2006 11:46:54 +0200
Message-ID: <200605261146.54436.ak@suse.de>
References: <20060523.182217.59656237.davem@davemloft.net> <200605241501.53477.bcook@bpointsys.com> <4474BD52.6020604@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Brent Cook <bcook@bpointsys.com>, Phil Dibowitz <phil@ipom.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:32735 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1750706AbWEZJsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 05:48:01 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <4474BD52.6020604@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 24 May 2006 22:08, Jeff Garzik wrote:
> Brent Cook wrote:
> > Note that this is just clearing the hardware statistics on the interface, and 
> > would not require any kind of atomic_increment addition for interfaces that 
> > support that. It would be kind-of awkward to implement this on drivers that  
> > increment stats in hardware though (lo, vlan, br, etc.) This also brings up 
> > the question of resetting the stats for 'netstat -s'
> 
> If you don't atomically clear the statistics, then you are leaving open 
> a window where the stats could easily be corrupted, if the network 
> interface is under load.

It could be handled by RCU with some moderately complex code  
(clear and clear again after a RCU quiescent period) 

But the real problem is that the user will always miss events during
the clear operation. That is why it is inherently racy.

An atomic user visible get-and-clear wouldn't have this problem, but it would be probably 
nasty to implement lockless without risking livelock on a busy system. And 
I also doubt it would have a nice user interface in the file system.

And really is it that hard to do a before-after diff?  I don't think so.


> 
> See...  this opens doors to tons of complexity.

Agreed.

-Andi
