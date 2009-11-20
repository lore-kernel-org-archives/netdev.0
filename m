From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [BUG] netxen: Stops working between 2.6.30 and 2.6.31-rc1
Date: Fri, 20 Nov 2009 08:48:23 -0800
Message-ID: <m1tywprvl4.fsf@fess.ebiederm.org>
References: <20091119163908.GJ14661@jayr.de>
	<7608421F3572AB4292BB2532AE89D5658B0B95BD5C@AVEXMB1.qlogic.org>
	<20091119183607.GK14661@jayr.de> <m1ocmyt2ly.fsf@fess.ebiederm.org>
	<20091120075258.GM14661@jayr.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dhananjay Phadke <dhananjay.phadke@qlogic.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Amit Salecha <amit.salecha@qlogic.com>
To: Jens Rosenboom <me@jayr.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:47762 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753376AbZKTQsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 11:48:24 -0500
In-Reply-To: <20091120075258.GM14661@jayr.de> (Jens Rosenboom's message of "Fri\, 20 Nov 2009 08\:52\:58 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jens Rosenboom <me@jayr.de> writes:

> On Thu, Nov 19, 2009 at 05:19:05PM -0800, Eric W. Biederman wrote:
>> Jens Rosenboom <me@jayr.de> writes:
>> 
>> > On Thu, Nov 19, 2009 at 10:07:21AM -0800, Dhananjay Phadke wrote:
>> >> > My netxen 10G card stops working somewhere between 2.6.30 and 2.6.31-rc1.
>> >> > With the
>> >> > newer kernel I can see packets been received on the switch it is
>> >> > connected to, but
>> >> > the kernel doesn't report any sent packets in the interface counters and
>> >> > nothing
>> >> > is being received either.
>> >> > 
>> >> > I've tried to bisect this, but only seems the end up with kernels that do
>> >> > not boot
>> >> > at all because some SCSI stuff goes bad.
>> >> 
>> >> Any particular reason for using -rc1 kernel and not 2.6.31 stable kernel?
>> >
>> > Sorry, I forgot to mention that all later kernels that I tested
>> > including 2.6.31 and the current net-2.6 also fail, so the badness 
>> > comes in somewhere in between 2.6.30 and 2.6.31-rc1.
>> >
>> > I also noticed that the newer kernel allocate four interrupts for the
>> > card instead of only one, but none of them seem to get triggered, the
>> > /proc/interrupts counters all stay at zero.
>> 
>> Hmm.  Have you tried disabling msi's? aka putting nomsi on the kernel
>> command line.
>
> I hadn't before but tried it now, but no difference. The kernel still seems to
> allocate four interrupts:

Weird. MSI's definitely weren't disabled.  Looking a little farther at
your quoted setup MSI work on your board.  This is definitely
something specific to the driver.  Except for a few initialization
races that are an issue for bonding I am running 2.6.31 just fine.


>  kernel: [    2.980300] bus: 'pci': add driver netxen_nic
>  kernel: [    2.980329] bus: 'pci': driver_probe_device: matched device 0000:22:00.0 with driver netxen_nic
>  kernel: [    2.980333] bus: 'pci': really_probe: probing driver netxen_nic with device 0000:22:00.0
>  kernel: [    2.980446] netxen_nic 0000:22:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
>  kernel: [    2.980459] netxen_nic 0000:22:00.0: setting latency timer to 64
>  kernel: [    2.981505] netxen_nic 0000:22:00.0: 128MB memory map
>  kernel: [    2.981611] netxen_nic 0000:22:00.0: firmware: using built-in firmware nxromimg.bin
>  kernel: [    4.144018] netxen_nic 0000:22:00.0: loading firmware from nxromimg.bin
>  kernel: [   10.108208] NetXen XGb XFP Board S/N IF72MK0200  Chip rev 0x25
>  kernel: [   10.108211] netxen_nic 0000:22:00.0: firmware version 3.4.336
>  kernel: [   10.108262]   alloc irq_desc for 37 on node 0
>  kernel: [   10.108265]   alloc kstat_irqs on node 0
>  kernel: [   10.108273] netxen_nic 0000:22:00.0: irq 37 for MSI/MSI-X
>  kernel: [   10.108275]   alloc irq_desc for 38 on node 0
>  kernel: [   10.108277]   alloc kstat_irqs on node 0
>  kernel: [   10.108281] netxen_nic 0000:22:00.0: irq 38 for MSI/MSI-X
>  kernel: [   10.108284]   alloc irq_desc for 39 on node 0
>  kernel: [   10.108286]   alloc kstat_irqs on node 0
>  kernel: [   10.108289] netxen_nic 0000:22:00.0: irq 39 for MSI/MSI-X
>  kernel: [   10.108291]   alloc irq_desc for 40 on node 0
>  kernel: [   10.108293]   alloc kstat_irqs on node 0
>  kernel: [   10.108296] netxen_nic 0000:22:00.0: irq 40 for MSI/MSI-X
>  kernel: [   10.108311] netxen_nic 0000:22:00.0: using msi-x interrupts
>  kernel: [   10.108371] device: 'eth2': device_add
>  kernel: [   10.108442] PM: Adding info for No Bus:eth2
>  kernel: [   10.109197] netxen_nic 0000:22:00.0: eth2: XGbE port initialized
>  kernel: [   10.109219] driver: '0000:22:00.0': driver_bound: bound to device 'netxen_nic'
>  kernel: [   10.109226] bus: 'pci': really_probe: bound device 0000:22:00.0 to driver netxen_nic
>
> # grep eth2 /proc/interrupts
>  37:          0          0          0          0   PCI-MSI-edge      eth2[0]
>  38:          0          0          0          0   PCI-MSI-edge      eth2[1]
>  39:          0          0          0          0   PCI-MSI-edge      eth2[2]
>  40:          0          0          0          0   PCI-MSI-edge      eth2[3]
> # ethtool eth2
> Settings for eth2:
> 	Supported ports: [ FIBRE ]
> 	Supported link modes:   
> 	Supports auto-negotiation: No
> 	Advertised link modes:  10000baseT/Full 
> 	Advertised auto-negotiation: No
> 	Speed: 10000Mb/s
> 	Duplex: Full
> 	Port: FIBRE
> 	PHYAD: 0
> 	Transceiver: external
> 	Auto-negotiation: off
> 	Supports Wake-on: d
> 	Wake-on: d
> 	Link detected: yes
> # ethtool -i eth2
> driver: netxen_nic
> version: 4.0.30
> firmware-version: 3.4.336
> bus-info: 0000:22:00.0
> # uname -rvmpi
> 2.6.31.6 #5 SMP Wed Nov 18 09:15:48 CET 2009 x86_64 Dual-Core AMD Opteron(tm) Processor 2212 AuthenticAMD GNU/Linux

On my working setup I have:
driver: netxen_nic
version: 4.0.30
firmware-version: 4.0.305
bus-info: 0000:06:00.0

4.0.305 looks like the latest publicly available version on qlogic's
website.  If that will work on your card I recommend you pull it down
and update your firmware.

My card is: NetXen Dual XGb SFP+ LP Board S/N SF86BK0008  Chip rev 0x41
Which is a bit different at the physical hardware level.

Eric
