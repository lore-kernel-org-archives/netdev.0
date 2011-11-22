From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2 tx watchdog timeout with 1Gb speed
Date: Mon, 21 Nov 2011 16:05:43 -0800
Message-ID: <20111121160543.2ae9c04c@nehalam.linuxnetplumber.net>
References: <20111120232118.GA29748@ntm.wq.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Milan Kocian <milon@wq.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33284 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752633Ab1KVAFv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Nov 2011 19:05:51 -0500
In-Reply-To: <20111120232118.GA29748@ntm.wq.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Nov 2011 00:21:18 +0100
Milan Kocian <milon@wq.cz> wrote:

> hi all,
> 
> I switched my home pc from 100Mb/s to 1000Mb/s and I see 
> this warning below.
> 
> The original kernel was 2.6.39.4 then I tested 3.1.1 with the same
> result. (self compiled 32bit vanilla). The workaround is to force 10/100 speed
> on my new switch (hp).
> 
> lspci:
> 
> 03:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8056 PCI-E Gigabit Ethernet Controller (rev 13)
>         Subsystem: Giga-byte Technology Device e000
>         Flags: bus master, fast devsel, latency 0, IRQ 45
>         Memory at f5000000 (64-bit, non-prefetchable) [size=16K]
>         I/O ports at 9000 [size=256]
>         [virtual] Expansion ROM at 80300000 [disabled] [size=128K]
>         Capabilities: [48] Power Management version 3
>         Capabilities: [50] Vital Product Data
>         Capabilities: [5c] MSI: Enable+ Count=1/1 Maskable- 64bit+
>         Capabilities: [e0] Express Legacy Endpoint, MSI 00
>         Capabilities: [100] Advanced Error Reporting
>         Kernel driver in use: sky2
> 
> 
> Nov 20 21:32:54 milu kernel: sky2 0000:03:00.0: eth0: Link is up at 1000 Mbps, full duplex, flow control both
> Nov 20 21:35:29 milu kernel: ------------[ cut here ]------------
> Nov 20 21:35:29 milu kernel: WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x1fa/0x206()
> Nov 20 21:35:29 milu kernel: Hardware name: 965GM-S2
> Nov 20 21:35:29 milu kernel: NETDEV WATCHDOG: eth0 (sky2): transmit queue 0 timed out
> Nov 20 21:35:29 milu kernel: Modules linked in: parport_pc parport fuse nfsd ipv6 nfs lockd auth_rpcgss nfs_acl sunrpc usbhid snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_intel8x0 sg snd_ac97_codec sr_mod ac97_bus cdrom sky2 snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss intel_agp snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device snd bitrev i2c_i801 crc32 intel_gtt uhci_hcd i2c_core ehci_hcd soundcore usbcore agpgart evdev snd_page_alloc
> Nov 20 21:35:29 milu kernel: Pid: 0, comm: swapper Not tainted 3.1.1 #2
> Nov 20 21:35:29 milu kernel: Call Trace:
> Nov 20 21:35:29 milu kernel: [<c102cd5d>] ? warn_slowpath_common+0x6c/0x94
> Nov 20 21:35:29 milu kernel: [<c1254deb>] ? dev_watchdog+0x1fa/0x206
> Nov 20 21:35:29 milu kernel: [<c1254deb>] ? dev_watchdog+0x1fa/0x206
> Nov 20 21:35:29 milu kernel: [<c102ce0e>] ? warn_slowpath_fmt+0x33/0x37
> Nov 20 21:35:29 milu kernel: [<c1254deb>] ? dev_watchdog+0x1fa/0x206
> Nov 20 21:35:29 milu kernel: [<c1254bf1>] ? qdisc_reset+0x2d/0x2d
> Nov 20 21:35:29 milu kernel: [<c1036434>] ? run_timer_softirq+0xc6/0x1c4
> Nov 20 21:35:29 milu kernel: [<c1027e9b>] ? run_rebalance_domains+0x148/0x169
> Nov 20 21:35:29 milu kernel: [<c103163b>] ? __do_softirq+0x6e/0xea
> Nov 20 21:35:29 milu kernel: [<c10315cd>] ? remote_softirq_receive+0x11/0x11
> Nov 20 21:35:29 milu kernel: <IRQ>  [<c1031906>] ? irq_exit+0x5b/0x67
> Nov 20 21:35:29 milu kernel: [<c101631f>] ? smp_apic_timer_interrupt+0x51/0x81
> Nov 20 21:35:29 milu kernel: [<c12ccd96>] ? apic_timer_interrupt+0x2a/0x30
> Nov 20 21:35:29 milu kernel: [<c13f007b>] ? asus_hides_smbus_hostbridge+0xcb/0x249
> Nov 20 21:35:29 milu kernel: [<c1008732>] ? mwait_idle+0x41/0x51
> Nov 20 21:35:29 milu kernel: [<c10015d8>] ? cpu_idle+0x74/0x84
> Nov 20 21:35:29 milu kernel: [<c13d6638>] ? start_kernel+0x28a/0x28f
> Nov 20 21:35:29 milu kernel: [<c13d615e>] ? loglevel+0x2b/0x2b
> Nov 20 21:35:29 milu kernel: ---[ end trace ef84175f674c7842 ]---
> Nov 20 21:35:29 milu kernel: sky2 0000:03:00.0: eth0: tx timeout
> Nov 20 21:35:29 milu kernel: sky2 0000:03:00.0: eth0: transmit ring 52 .. 30 report=52 done=52
> Nov 20 21:35:32 milu kernel: sky2 0000:03:00.0: eth0: Link is up at 1000 Mbps, full duplex, flow control both
> Nov 20 21:37:13 milu kernel: sky2 0000:03:00.0: eth0: tx timeout
> Nov 20 21:37:13 milu kernel: sky2 0000:03:00.0: eth0: transmit ring 37 .. 15 report=37 done=37
> Nov 20 21:37:16 milu kernel: sky2 0000:03:00.0: eth0: Link is up at 1000 Mbps, full duplex, flow control both
> 
> Any suggestion ? As I said its home machine so I can test what you want :-).

I haven't seen this, is it under heavy or light traffic.
Are you running something that might cause device to miss interrupts?
