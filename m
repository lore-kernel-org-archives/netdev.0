From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC:  Removing busy-spin in pktgen.
Date: Tue, 24 Oct 2006 09:28:35 -0700
Message-ID: <453E3F33.1090709@candelatech.com>
References: <453D582C.9020705@candelatech.com> <17725.55765.509953.762136@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:60545 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S932426AbWJXQ1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2006 12:27:16 -0400
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <17725.55765.509953.762136@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> Ben Greear writes:
>  > I'm planning to re-merge my long-lost pktgen branch with the kernel
>  > tree's pktgen.
>  > 
>  > I believe the main difference is that my out-of-tree pktgen does not do the
>  > busy-spin, but waits on a queue for the net-device to wake it's tx-queue
>  > when over-driving a NIC.
>  > 
>  > To implement this, I added a hook in the netdev-wake-queue logic and let
>  > pktgen register itself as interested....
>  > 
>  > Is there any interest in adding this sort of feature to the official
>  > pktgen?
>
>  Hello!
>
>  So question is, pktgen hooks in netif_wake_queue or let pktgen busy-spin?
>
>  My first instinct is to avoid the hook in general code and pktgen let spin 
>  to only affect testing.
>   
Ok.  For my testing, I often run pktgen at slower speeds and need to run 
other applications
with good performance as well, so it hurts to give pktgen an entire CPU 
to just spin.  I'm
going to go ahead and port over the no-spin logic and hooks, but I'll 
try to keep that patch
easily separated from the rest of the changes I make to pktgen so 
perhaps the other changes
can be incorporated.

Thanks,
Ben

>  
>  Cheers.
> 					--ro
>   


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


