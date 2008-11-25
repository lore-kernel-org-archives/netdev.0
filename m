From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: WARNING: at net/sched/sch_generic.c:219
 dev_watchdog+0xfe/0x17e() with tg3 network
Date: Mon, 24 Nov 2008 17:52:23 -0800
Message-ID: <20081125015223.GA9151@xw6200.broadcom.net>
References: <1226403067.7685.1598.camel@twins>
 <491E49AA.60407@gmail.com> <20081118065006.GC24654@1wt.eu>
 <20081120031101.GD26448@xw6200.broadcom.net>
 <20081120053746.GB15168@1wt.eu>
 <20081120184310.GB27712@xw6200.broadcom.net>
 <20081120212637.GB23844@1wt.eu>
 <20081120215318.GB27907@xw6200.broadcom.net>
 <20081124132744.GB24851@1wt.eu> <20081124215247.GA29696@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Roger Heflin" <rogerheflin@gmail.com>,
	"Peter Zijlstra" <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: "Willy Tarreau" <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4949 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753064AbYKYBwi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2008 20:52:38 -0500
In-Reply-To: <20081124215247.GA29696@1wt.eu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 24, 2008 at 01:52:47PM -0800, Willy Tarreau wrote:
> Hi Matt,
> 
> just a follow-up.
> 
> On Mon, Nov 24, 2008 at 02:27:44PM +0100, Willy Tarreau wrote:
> > Hi Matt,
> > 
> > On Thu, Nov 20, 2008 at 01:53:18PM -0800, Matt Carlson wrote:
> > > > Today, with the notebook connected to a gig switch, I could not reproduce
> > > > the problem, even after one hour of approximately the same workload. I'll
> > > > retry with the original 100 Mbps switch on monday.
> > 
> > fairly easier now with the same switch. I just have to transfer 100k objects
> > over HTTP via this switch to see the problem happen :
> > 
> > tg3: eth0: The system may be re-ordering memory-mapped I/O cycles to the network device, attempting to recover. Please report the problem to the driver maintainer and include system chipset information.
> > tg3: tg3_stop_block timed out, ofs=1400 enable_bit=2
> > tg3: tg3_stop_block timed out, ofs=c00 enable_bit=2
> > tg3: eth0: Link is down.
> > tg3: eth0: Link is up at 100 Mbps, full duplex.
> > tg3: eth0: Flow control is on for TX and on for RX.
> > 
> > The switch is an el-cheapo D-Link 10/100. Note that this time I did not see
> > any warning. Maybe I did not wait long enough though.
> 
> Got it again, just had to be patient to fire a second test :
> 
> WARNING: at net/sched/sch_generic.c:219 dev_watchdog+0x1a4/0x1b0()
> NETDEV WATCHDOG: eth0 (tg3): transmit timed out
> Modules linked in: nfs lockd sunrpc mtdblock mtd_blkdevs slram mtd xt_tcpudp x_tables usbhid usb_storage ehci_hcd uhci_hcd usbcore snd_pcm_oss snd_mixer_oss snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm snd_timer snd soundcore snd_page_alloc tg3 libphy ide_cs yenta_socket rsrc_nonstatic [last unloaded: ip_tables]
> Pid: 0, comm: swapper Not tainted 2.6.27-wt2-wtap #1
>  [<b01254a7>] warn_slowpath+0x67/0x90
>  [<b01741a9>] ? get_slab+0x9/0x70
>  [<b03d21af>] ? pskb_copy+0x2f/0x160
>  [<b03aa332>] ? input_defuzz_abs_event+0x12/0xa0
>  [<b03aa574>] ? input_handle_event+0x14/0x2a0
>  [<b03b3d76>] ? synaptics_process_packet+0x2b6/0x3d0
>  [<b0108a48>] ? native_io_delay+0x8/0x40
>  [<b02ab4c9>] ? strlen+0x9/0x20
>  [<b02a961e>] ? strlcpy+0x1e/0x60
>  [<b03dbfbc>] ? netdev_drivername+0x3c/0x40
>  [<b03e7c84>] dev_watchdog+0x1a4/0x1b0
>  [<b013a27e>] ? run_hrtimer_pending+0xe/0xb0
>  [<b03e7ae0>] ? dev_watchdog+0x0/0x1b0
>  [<b012d548>] ? timer_stats_account_timer+0x38/0x40
>  [<b03e7ae0>] ? dev_watchdog+0x0/0x1b0
>  [<b012dbbc>] run_timer_softirq+0xac/0x170
>  [<b013f863>] ? tick_periodic+0x33/0x70
>  [<b013f8b7>] ? tick_handle_periodic+0x17/0x70
>  [<b03e7ae0>] ? dev_watchdog+0x0/0x1b0
>  [<b0129ae4>] __do_softirq+0x84/0xa0
>  [<b0129b35>] do_softirq+0x35/0x40
>  [<b0129bf6>] irq_exit+0x66/0x70
>  [<b0105869>] do_IRQ+0x49/0x90
>  [<b013bc30>] ? sched_clock_cpu+0xb0/0x100
>  [<b010449b>] common_interrupt+0x23/0x28
>  [<b0305158>] ? acpi_safe_halt+0x1b/0x29
>  [<b0305b07>] acpi_idle_enter_c1+0xa6/0x117
>  [<b03c096b>] cpuidle_idle_call+0x6b/0xa0
>  [<b010206f>] cpu_idle+0x4f/0x70
>  [<b04458dd>] rest_init+0x4d/0x50
>  =======================
> ---[ end trace 1cc3b74458d87dab ]---
> tg3: eth0: transmit timed out, resetting
> tg3: DEBUG: MAC_TX_STATUS[0000000b] MAC_RX_STATUS[00000006]
> tg3: DEBUG: RDMAC_STATUS[00000000] WDMAC_STATUS[00000008]
> tg3: tg3_stop_block timed out, ofs=1400 enable_bit=2
> tg3: tg3_stop_block timed out, ofs=c00 enable_bit=2
> tg3: tg3_stop_block timed out, ofs=4c00 enable_bit=2
> tg3: eth0: Link is down.
> tg3: eth0: Link is up at 100 Mbps, full duplex.
> tg3: eth0: Flow control is on for TX and on for RX.
> 
> The ease with which I reproduce it here clearly indicates that this is
> related to the switch, probably just the fact that it is at 100 Mbps.
> Unfortunately this evening I must go, but I still have one 100 Mbps
> switch somewhere at home, I'll reproduce the same test ASAP in order
> to bisect the issue.
> 
> Regards,
> Willy

Does turning off flow control help at all?


