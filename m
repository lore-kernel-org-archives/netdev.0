From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: 2.6.7 tulip performance (with NAPI)
Date: Thu, 7 Oct 2004 23:11:47 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16741.45331.743721.822091@robur.slu.se>
References: <41633174.7070805@candelatech.com>
	<16740.17875.574967.11417@robur.slu.se>
	<41646587.7070401@candelatech.com>
	<41649425.1010102@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <41649425.1010102@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ben Greear writes:

 > 
 > int pg_notify_queue_woken(struct net_device* dev) {
 > 	struct pktgen_interface_info* info = dev->nqw_data;
 > 	if (info && info->pg_thread->sleeping) {
 > 		if (getRelativeCurNs() > (info->next_tx_ns - 1000)) {
 > 			/* See if we should wake up the thread, wake
 > 			 * slightly early (1000 ns)
 > 			 */
 > 			info->pg_thread->sleeping = 0;
 > 			wake_up_interruptible(&(info->pg_thread->queue));
 > 		}
 > 	}
 > 	return 0;
 > }


 Interesting... I got requests for higher performance in flow/DoS testing
 to be really useful. Probably only preallocation will help here.

 To be really aggressive we could hack the driver TX handling so at TX 
 interrupt also refills/refresh the ring but it's not a general solution. 
 I guess you can use an existing qdisc via dev_queue_xmit() or something 
 to save CPU in your case.
 
 I was sending wire rate from 10 GIGE NIC's from a DUAL XEON w. HT

 I'm interested if anyone has done any pktgen performance tests with
 w. S2IO or other 10G card we need to upgrade the lab equipment. 
 Both 64 byte pkts and MTU sized pkts is interesting.  Anyone?

 Cheers.
						--ro
