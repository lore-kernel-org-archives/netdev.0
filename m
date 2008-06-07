From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: bug report
Date: Sat, 7 Jun 2008 11:47:59 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806071141480.24862@wrl-59.cs.helsinki.fi>
References: <48499731.1080807@gmail.com> <6101e8c40806061844g5b7676d4xb48c5c69ad48391f@mail.gmail.com>
 <20080606225643.8be222a9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Oliver Pinter <oliver.pntr@gmail.com>, zsirmo@zsirmo.hu,
	LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
	netdev <netdev@vger.kernel.org>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Brian Vowell <brian.vowell@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34609 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754152AbYFGIsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jun 2008 04:48:04 -0400
In-Reply-To: <20080606225643.8be222a9.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

...Added Brian Vowell.

On Fri, 6 Jun 2008, Andrew Morton wrote:

> On Sat, 7 Jun 2008 03:44:32 +0200 "Oliver Pinter" <oliver.pntr@gmail.com> wrote:
> 
> > Add Ingon and netdev to CC
> > 
> > 
> > On 6/6/08, Zsiros Attila <zsirmo@gmail.com> wrote:
> > > Hy!
> > >
> > > I have a problem.
> > >
> > > http://www.cyberszeg.hu/log/kern.log
> > > http://www.cyberszeg.hu/log/config-2.6.25.4
> > > http://www.cyberszeg.hu/log/lspci.txt
> > > http://www.cyberszeg.hu/log/ifconfig.txt
> > >
> 
> : Jun  6 14:03:07 www kernel: [ 5897.660390] NETDEV WATCHDOG: eth0: transmit timed out
> : Jun  6 14:03:07 www kernel: [ 5897.660398] tg3: eth0: transmit timed out, resetting
> : Jun  6 14:03:07 www kernel: [ 5897.660432] tg3: DEBUG: MAC_TX_STATUS[0000001e] MAC_RX_STATUS[0000000e]
> : Jun  6 14:03:07 www kernel: [ 5897.660454] tg3: DEBUG: RDMAC_STATUS[00000000] WDMAC_STATUS[00000000]
> : Jun  6 14:03:07 www kernel: [ 5897.762983] tg3: tg3_stop_block timed out, ofs=1800 enable_bit=2
> : Jun  6 14:03:07 www kernel: [ 5897.864168] tg3: tg3_stop_block timed out, ofs=c00 enable_bit=2
> : Jun  6 14:03:07 www kernel: [ 5897.965619] tg3: tg3_stop_block timed out, ofs=4800 enable_bit=2
> 
> That looks like a driver failure.
> 
> : Jun  6 14:03:07 www kernel: [ 5898.096689] tg3: eth0: Link is down.
> : Jun  6 14:03:11 www kernel: [ 5901.633931] tg3: eth0: Link is up at 1000 Mbps, full duplex.
> : Jun  6 14:03:11 www kernel: [ 5901.633937] tg3: eth0: Flow control is on for TX and on for RX.
> : Jun  6 14:04:11 www kernel: [ 6464.556309] clamscan: page allocation failure. order:3, mode:0x4020
> : Jun  6 14:04:11 www kernel: [ 6464.556319] Pid: 24139, comm: clamscan Not tainted 2.6.25.4 #1
> : Jun  6 14:04:11 www kernel: [ 6464.556325] 
> : Jun  6 14:04:11 www kernel: [ 6464.556326] Call Trace:
> : Jun  6 14:04:11 www kernel: [ 6464.556329]  <IRQ>  [__alloc_pages+544/890] __alloc_pages+0x220/0x37a
> : Jun  6 14:04:11 www kernel: [ 6464.556353]  [tcp_v4_do_rcv+186/504] tcp_v4_do_rcv+0xba/0x1f8
> : Jun  6 14:04:11 www kernel: [ 6464.556359]  [ktime_get+12/98] ktime_get+0xc/0x62
> : Jun  6 14:04:11 www kernel: [ 6464.556364]  [__netdev_alloc_skb+23/49] __netdev_alloc_skb+0x17/0x31
> : Jun  6 14:04:11 www kernel: [ 6464.556370]  [__slab_alloc+330/1403] __slab_alloc+0x14a/0x57b
> : Jun  6 14:04:11 www kernel: [ 6464.556374]  [__netdev_alloc_skb+23/49] __netdev_alloc_skb+0x17/0x31
> : Jun  6 14:04:11 www kernel: [ 6464.556379]  [__netdev_alloc_skb+23/49] __netdev_alloc_skb+0x17/0x31
> : Jun  6 14:04:11 www kernel: [ 6464.556384]  [__kmalloc_track_caller+185/190] __kmalloc_track_caller+0xb9/0xbe
> : Jun  6 14:04:11 www kernel: [ 6464.556391]  [__alloc_skb+86/305] __alloc_skb+0x56/0x131
> : Jun  6 14:04:11 www kernel: [ 6464.556395]  [__netdev_alloc_skb+23/49] __netdev_alloc_skb+0x17/0x31
> : Jun  6 14:04:11 www kernel: [ 6464.556408]  [_end+128472975/2130444940] :tg3:tg3_alloc_rx_skb+0x8f/0x17e
> : Jun  6 14:04:11 www kernel: [ 6464.556418]  [_end+128493403/2130444940] :tg3:tg3_poll+0x6e8/0x922
> : Jun  6 14:04:11 www kernel: [ 6464.556426]  [net_rx_action+134/309] net_rx_action+0x86/0x135
> : Jun  6 14:04:11 www kernel: [ 6464.556433]  [__do_softirq+102/212] __do_softirq+0x66/0xd4
> : Jun  6 14:04:11 www kernel: [ 6464.556439]  [call_softirq+28/48] call_softirq+0x1c/0x30
> : Jun  6 14:04:11 www kernel: [ 6464.556444]  [do_softirq+48/107] do_softirq+0x30/0x6b
> : Jun  6 14:04:11 www kernel: [ 6464.556448]  [do_IRQ+114/212] do_IRQ+0x72/0xd4
> : Jun  6 14:04:11 www kernel: [ 6464.556453]  [ret_from_intr+0/10] ret_from_intr+0x0/0xa
> 
> The driver is trying to do a 32 kbyte GFP_ATOMIC memory allocation. 
> rofl, good luck with that.
> 
> But the netwoking code sould survive this.
> 
> <12 billion more page allocation failures>
> 
> Are you using jumbo frames or have you manually set the MTU to
> something enormous?  Because 32k is a pretty crazy amount of memory for
> the driver to be trying to allocate - it's going to fail all over the
> place, as you have discovered.

Same allocation failed problem (among an TCP issue that is nowadays 
fixed) was also reported by Brian Vowell:
  http://bugzilla.kernel.org/show_bug.cgi?id=10767


-- 
 i.
