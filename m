From: Ben Greear <greearb@candelatech.com>
Subject: Re: Tulip (DFE-570tx) & keyboard lockup in 2.6.9 and other 2.6 kernels.
Date: Thu, 24 Feb 2005 16:16:33 -0800
Message-ID: <421E6E61.3040005@candelatech.com>
References: <421CF0BA.1020100@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>
To: netdev@oss.sgi.com
In-Reply-To: <421CF0BA.1020100@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> I finally had some time to debug this one a little more
> thoroughly.  On two different machines (Shuttle SB61G1) I
> get the same results, so I do not believe it is bad hardware...
> 
> The bug is as follows:
> 
> I have 1 4-port tulip NIC in the machine.  If I generate traffic
> between two interfaces, it runs fine.  But, if I start running traffic
> on all 4 interfaces, the keyboard quits taking input, and ethernet
> traffic stops on at least a few of the interfaces.  I can still ssh
> into the machine (via the rtl8139 interface), so at least one of the
> processors (I'm using SMP on an P4 HT processor) is working.  I also
> enabled NMI and that does not trigger.

This was my bug.  I was holding a lock that was required for receiving a packet
while calling the hard_start_xmit method.  When an IRQ happened while I was in
the hard_start_xmit method, the IRQ could not grab the lock, and just sat there
spinning...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
