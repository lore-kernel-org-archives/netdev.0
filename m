From: Ben Greear <greearb@candelatech.com>
Subject: Re: 2.6.7 tulip performance (with NAPI)
Date: Thu, 07 Oct 2004 14:47:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4165B981.8060703@candelatech.com>
References: <41633174.7070805@candelatech.com>	<16740.17875.574967.11417@robur.slu.se>	<41646587.7070401@candelatech.com>	<41649425.1010102@candelatech.com> <16741.45331.743721.822091@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16741.45331.743721.822091@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> Ben Greear writes:
> 
>  > 
>  > int pg_notify_queue_woken(struct net_device* dev) {
>  > 	struct pktgen_interface_info* info = dev->nqw_data;
>  > 	if (info && info->pg_thread->sleeping) {
>  > 		if (getRelativeCurNs() > (info->next_tx_ns - 1000)) {
>  > 			/* See if we should wake up the thread, wake
>  > 			 * slightly early (1000 ns)
>  > 			 */
>  > 			info->pg_thread->sleeping = 0;
>  > 			wake_up_interruptible(&(info->pg_thread->queue));
>  > 		}
>  > 	}
>  > 	return 0;
>  > }
> 
> 
>  Interesting... I got requests for higher performance in flow/DoS testing
>  to be really useful. Probably only preallocation will help here.
> 
>  To be really aggressive we could hack the driver TX handling so at TX 
>  interrupt also refills/refresh the ring but it's not a general solution. 
>  I guess you can use an existing qdisc via dev_queue_xmit() or something 
>  to save CPU in your case.
>  
>  I was sending wire rate from 10 GIGE NIC's from a DUAL XEON w. HT

You must have several PCI-X busses on that system?  From what I can tell,
my dual-xeon system (2.8Ghz, X5DPA-GG motherboard) just can't handle the
PCI bandwidth.  I still have processing power it appears, and I see lots
of hard-start-xmit errors out of the pro/1000 NICs, so I assume I am
able to drive them as hard as they can go...  It may be that receiving
the pkts, as I am doing, also decreases transmit in more than a linear fashion.

One thing I forgot to mention earlier:  I set the pktgen thread to real-time
scheduling with a user-space app.  This helps make sure it wakes up promptly.

>  I'm interested if anyone has done any pktgen performance tests with
>  w. S2IO or other 10G card we need to upgrade the lab equipment. 
>  Both 64 byte pkts and MTU sized pkts is interesting.  Anyone?

Not I, but would be interested as well!

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
