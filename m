From: "Jon Fraser" <J_Fraser@bit-net.com>
Subject: RE: [Question] SMP for Linux
Date: Thu, 17 Oct 2002 13:28:38 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <008601c27602$a1ad8170$3701020a@CONCORDIA>
References: <15790.42618.961289.506241@robur.slu.se>
Reply-To: <J_Fraser@bit-net.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
In-Reply-To: <15790.42618.961289.506241@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


What was your cpu utilization like in the bound vs split scenarios?
Does your e1000 driver have transmit interrupts enabled or disabled?

I'd be really interested to see the results with two flows in opposite
directions.

	Jon

> -----Original Message-----
> From: netdev-bounce@oss.sgi.com [mailto:netdev-bounce@oss.sgi.com]On
> Behalf Of Robert Olsson
> Sent: Thursday, October 17, 2002 8:01 AM
> To: bert hubert
> Cc: Hyochang Nam; niv@us.ibm.com; netdev@oss.sgi.com
> Subject: Re: [Question] SMP for Linux
> 
> 
> 
> bert hubert writes:
>  > On Thu, Oct 17, 2002 at 11:29:28AM +0900, Hyochang Nam wrote:
>  > > Many people helped me to solve the interrupt 
> distribution problem.
>  > > We tested the throughput of Layer 3 forwarding on a SMP machine
>  > > which equips two Zero proessor(2Ghz). This is our results:
>  > >   -------------------------
>  > >        SMP    |  No SMP
>  > >   -------------------------
>  > >     230 Mbps  | 330 Mbps
>  > >   -------------------------
>  > 
>  > There is something called 'irq affinity' which may be 
> interesting for you.
>  > See here: 
> http://www.dell.com/us/en/esg/topics/power_ps1q02-morse.htm
>  > 
>  > /proc/irq/?/smp_affinity
> 
>  Hello!
> 
>  Not always good for routing... Were you still get the 
> problem were one
>  interface is the output device from devices bound to different CPU's.
> 
>  TX-ring can hold skb's from many CPU's so a lot of cache 
> bouncing happens 
>  when kfree and skb_headerinit is run.
> 
>  I've played with some to code to re-route the skb freeing to the CPU
>  where it was processed this to minimize cache bouncing and I've seen 
>  some good effects of this.
> 
>  And to be fair with SMP you should compare multiple flows to 
> see if you 
>  can get any aggregated performance from SMP.
> 
>  An experiment...
>  
>  Single flow eth0->eth1 w. e1000 NAPI. 2.4.20-pre5. PIII @ 2x933 MHz
> 
>  Bound = eth0, eth1 is bound to same CPU.
>  Split = eth0, eth1 is bound to differnt CPU's.
>  Free  = unbound.
> 
>  SMP routing performance
>  =======================
>  
> Bound   Free  Split   "kfree-route"
>  ---------------------------------
>  421     354    331                 kpps
>  491     348    317            437  kpps w. skb recycling
> 
> 
>  UP routing performance
>  ======================
>  494 kpps
>  593 kpps w. skb recycling
> 
> 
>  With SMP test "kfree-route" the interfaces are not bound to 
> any CPU still 
>  we now getting closer to "bound" (where both eth0, eth1 is 
> bond to the same 
>  CPU). 
> 
>  But yes UP is gives higher numbers in this single stream 
> tests. Aggregated
>  throughput tests are to be done.
> 
>  Cheers.
> 
> 						--ro
> 
> 
