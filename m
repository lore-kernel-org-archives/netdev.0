From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [Question] SMP for Linux
Date: Thu, 17 Oct 2002 14:00:58 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15790.42618.961289.506241@robur.slu.se>
References: <20021017112928.B20854@toad.postech.ac.kr>
	<20021017100243.GA6569@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Hyochang Nam <cannon@postech.ac.kr>, niv@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20021017100243.GA6569@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


bert hubert writes:
 > On Thu, Oct 17, 2002 at 11:29:28AM +0900, Hyochang Nam wrote:
 > > Many people helped me to solve the interrupt distribution problem.
 > > We tested the throughput of Layer 3 forwarding on a SMP machine
 > > which equips two Zero proessor(2Ghz). This is our results:
 > >   -------------------------
 > >        SMP    |  No SMP
 > >   -------------------------
 > >     230 Mbps  | 330 Mbps
 > >   -------------------------
 > 
 > There is something called 'irq affinity' which may be interesting for you.
 > See here: http://www.dell.com/us/en/esg/topics/power_ps1q02-morse.htm
 > 
 > /proc/irq/?/smp_affinity

 Hello!

 Not always good for routing... Were you still get the problem were one
 interface is the output device from devices bound to different CPU's.

 TX-ring can hold skb's from many CPU's so a lot of cache bouncing happens 
 when kfree and skb_headerinit is run.

 I've played with some to code to re-route the skb freeing to the CPU
 where it was processed this to minimize cache bouncing and I've seen 
 some good effects of this.

 And to be fair with SMP you should compare multiple flows to see if you 
 can get any aggregated performance from SMP.

 An experiment...
 
 Single flow eth0->eth1 w. e1000 NAPI. 2.4.20-pre5. PIII @ 2x933 MHz

 Bound = eth0, eth1 is bound to same CPU.
 Split = eth0, eth1 is bound to differnt CPU's.
 Free  = unbound.

 SMP routing performance
 =======================
 
Bound   Free  Split   "kfree-route"
 ---------------------------------
 421     354    331                 kpps
 491     348    317            437  kpps w. skb recycling


 UP routing performance
 ======================
 494 kpps
 593 kpps w. skb recycling


 With SMP test "kfree-route" the interfaces are not bound to any CPU still 
 we now getting closer to "bound" (where both eth0, eth1 is bond to the same 
 CPU). 

 But yes UP is gives higher numbers in this single stream tests. Aggregated
 throughput tests are to be done.

 Cheers.

						--ro
