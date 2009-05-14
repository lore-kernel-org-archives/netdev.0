From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Yukon2 88E8056 card problem with switch?
Date: Thu, 14 May 2009 08:06:15 -0700
Message-ID: <20090514080615.6419b121@nehalam>
References: <4A0BC769.9010507@aei.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Carsten Aulbert <carsten.aulbert@aei.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45440 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751220AbZENPHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2009 11:07:03 -0400
In-Reply-To: <4A0BC769.9010507@aei.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 May 2009 09:25:29 +0200
Carsten Aulbert <carsten.aulbert@aei.mpg.de> wrote:

> Hi,
> 
> sorry to ask you directly, but I'm running out of options how to solve
> this issue:
> 
> We install our machines fully automatically via Debian's FAI mechanisms
> and hit a problem right at the end of the installation which can also be
> triggered after a standard system install.
> 
> With kernel 2.6.27.21 (vanilla) and logging into the box via ssh and
> calling dmesg, the net watchdog starts barking:
> 
> May 12 09:04:28 gpu01 kernel: [ 3000.040007] ------------[ cut here
> ]------------
> May 12 09:04:28 gpu01 kernel: [ 3000.040011] WARNING: at
> net/sched/sch_generic.c:219 dev_watchdog+0x121/0x1b8()
> May 12 09:04:28 gpu01 kernel: [ 3000.040013] NETDEV WATCHDOG: eth0
> (sky2): transmit timed out
> May 12 09:04:28 gpu01 kernel: [ 3000.040015] Modules linked in:
> ipmi_devintf ipmi_watchdog ipmi_poweroff ipmi_msghandler i2c_i801
> i2c_core sky2
> May 12 09:04:28 gpu01 kernel: [ 3000.040025] Pid: 0, comm: swapper Not
> tainted 2.6.27.21-atlas-generic-noinitrd #1
> May 12 09:04:28 gpu01 kernel: [ 3000.040027]
> May 12 09:04:28 gpu01 kernel: [ 3000.040028] Call Trace:
> May 12 09:04:28 gpu01 kernel: [ 3000.040030]  <IRQ>
> [<ffffffff80237378>] warn_slowpath+0xb4/0xdc
> May 12 09:04:28 gpu01 kernel: [ 3000.040037]  [<ffffffff804d2d00>]
> sk_filter+0x10/0x80
> May 12 09:04:28 gpu01 kernel: [ 3000.040040]  [<ffffffff804e7b1a>]
> ip_route_input+0x63e/0xedf
> May 12 09:04:28 gpu01 kernel: [ 3000.040044]  [<ffffffff803bf7b9>]
> __next_cpu+0x19/0x26
> May 12 09:04:28 gpu01 kernel: [ 3000.040048]  [<ffffffff802302e7>]
> find_busiest_group+0x315/0x7c3
> May 12 09:04:28 gpu01 kernel: [ 3000.040051]  [<ffffffff80232203>]
> try_to_wake_up+0x165/0x177
> May 12 09:04:28 gpu01 kernel: [ 3000.040054]  [<ffffffff8022f0ce>]
> enqueue_task_fair+0xd8/0x130
> May 12 09:04:28 gpu01 kernel: [ 3000.040057]  [<ffffffff804df6ed>]
> dev_watchdog+0x121/0x1b8
> May 12 09:04:28 gpu01 kernel: [ 3000.040060]  [<ffffffff80232203>]
> try_to_wake_up+0x165/0x177
> May 12 09:04:28 gpu01 kernel: [ 3000.040062]  [<ffffffff804df5cc>]
> dev_watchdog+0x0/0x1b8
> May 12 09:04:28 gpu01 kernel: [ 3000.040065]  [<ffffffff8023fa06>]
> run_timer_softirq+0x16e/0x1ee
> May 12 09:04:28 gpu01 kernel: [ 3000.040069]  [<ffffffff8024c075>]
> ktime_get_ts+0x21/0x49
> May 12 09:04:28 gpu01 kernel: [ 3000.040072]  [<ffffffff8023bfad>]
> __do_softirq+0x6a/0xda
> May 12 09:04:28 gpu01 kernel: [ 3000.040075]  [<ffffffff8021163c>]
> call_softirq+0x1c/0x28
> May 12 09:04:28 gpu01 kernel: [ 3000.040078]  [<ffffffff802130fb>]
> do_softirq+0x3c/0x81
> May 12 09:04:28 gpu01 kernel: [ 3000.040082]  [<ffffffff80220326>]
> smp_apic_timer_interrupt+0x8e/0xa7
> May 12 09:04:28 gpu01 kernel: [ 3000.040085]  [<ffffffff80210e43>]
> apic_timer_interrupt+0x83/0x90
> May 12 09:04:28 gpu01 kernel: [ 3000.040086]  <EOI>
> [<ffffffff802170e2>] mwait_idle+0x3c/0x46
> May 12 09:04:28 gpu01 kernel: [ 3000.040092]  [<ffffffff8020ee32>]
> cpu_idle+0x91/0xd1
> May 12 09:04:28 gpu01 kernel: [ 3000.040094]
> May 12 09:04:28 gpu01 kernel: [ 3000.040096] ---[ end trace
> da19323bcd799bc5 ]---
> May 12 09:04:28 gpu01 kernel: [ 3000.040098] sky2 eth0: tx timeout
> May 12 09:04:28 gpu01 kernel: [ 3000.048993] sky2 eth0: transmit ring
> 348 .. 308 report=348 done=348
> May 12 09:04:28 gpu01 kernel: [ 3000.049017] sky2 eth0: disabling interface
> May 12 09:04:28 gpu01 kernel: [ 3000.053439] sky2 eth0: enabling interface
> May 12 09:04:31 gpu01 kernel: [ 3003.153938] sky2 eth0: Link is up at
> 1000 Mbps, full duplex, flow control rx

You are only seeing partial flow control. My recommendation would be to
turn off flow control with:
   ethtool -A eth0 autoneg off rx off tx off



> Most of the time the device seem to heal itself after a couple of
> minutes, but not always. I suspect this is related to switching since I
> don't see this behavior when running a direct link cable between this
> machine and another one.
> 
> On a related note: It seems that autosensing does not work reliably
> also, since our switches do report no pause frames on both tx as well as
> rx because that could potentially cause havoc in our large switching
> network.

It works with other switches, so check cable and try another switch.


> If've tried to make this problem go away via ethtool -A eth0, however so
> far without luck. I've yet to play around with the sky2 module
> parameters, any idea which parameter - if any - could help?

No parameters (by design) in driver.

-- 
