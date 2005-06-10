From: Ben Greear <greearb@candelatech.com>
Subject: Re: BCM5704 performance questions.
Date: Fri, 10 Jun 2005 14:56:45 -0700
Message-ID: <42AA0C9D.2060006@candelatech.com>
References: <42A8E0FE.3020708@candelatech.com> <1118361376.5838.20.camel@rh4>	<42A8EBDA.6010306@candelatech.com> <1118363861.5838.29.camel@rh4> <42AA016C.9050801@candelatech.com> <42AA0743.1020101@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <42AA0743.1020101@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> 
>> Have you done any tests with 2 tg3 NICs in a single machine to see if 
>> they
>> can run at or near line speed (full duplex)?
> 
> 
> It isn't just a question of two tg3 NICs in the same box is it?  You are 
> running two NICs on the same bus right?  And unless my dimm memory is 
> mistaken, four ports on a card with 5704s means two 5704's a bridge chip 
> right?  So, it would be two tg3 NICs going through the same bridge chip, 
> not just the same bus or same system.  I'd be worrying about DMA 
> latencies on the system and the bridge chip, and perhaps the efficiency 
> of the PCI-X bus usage (not sure - is there anything in your system's 
> chipset to extract that sort of information?)

There will be a bridge chip, and indeed I see better performance when I just
use a 2-port Intel NIC as opposed to a 4 port, even if I am only actively
using 2 of the 4 ports on the 4-port NIC.  For the tg3 hardware I only
have a 4-port NIC.  I do assume that a 2-port tg3 NIC w/out a bridge chip
would be faster..but probably not too much.

> What happens when you turn pktgen around/insideout and source packets 
> from the bridging system to each of the (two other?) systems?

I looped two ports on the same NIC together for the pktgen tests, so there
is only a single machine in question.  With Intel I can source/sink about
960Mbps on two ports simultaneously in this configuration.  With the tg3
NIC I can only do about 750Mbps.

And, the tg3 is in the faster PCI-X slot (133Mhz v/s 100Mhz).  So, to me
it appears that the tg3 hardware and/or driver can only handle about 80%
of the performance that the intel e1000 can produce.  It's possible I have
a particularly sub-optimal configuration for tg3, or maybe a poorly designed
NIC, which is why I'd like to know what others see...

> Since you are bridging, does having CKO enabled really matter?  Mightn't 
> that allow the firmware on the 5704(s) to run a triffle faster?  Or does 
> bridging already not request CKO (I suppose it might).

CKO == IP checksum offload?

Since Dave doesn't want to debug my bridge setup (and I don't blame him),
I am going to try to focus my testing/debug reports on the pktgen tests.
If/when pktgen shows better performance with tg3, I can verify that
I see the same speedups with my proprietary bridging module.  I've no idea
if CKO would help or hinder pktgen, nor have I tried to enable or disable it.

> Are your interface interrupts distributed across the CPUs?

I'm using FC2, basically a default install.  It does seem to have
an irq balance daemon running.  But, I'm not specifically binding IRQs
or anything like that.  pktgen tx is running as a single thread, so the rx
code could run mostly on the other CPU if locking allows...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
