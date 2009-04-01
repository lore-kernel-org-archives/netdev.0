From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12971] New: "tg3 transmit timed out" when
 transmitting at high bitrate
Date: Wed, 1 Apr 2009 16:43:00 -0700
Message-ID: <20090401164300.049a48fc.akpm@linux-foundation.org>
References: <bug-12971-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, dobrev666@gmail.com,
	mcarlson@broadcom.com, mchan@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34108 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753888AbZDAXqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 19:46:16 -0400
In-Reply-To: <bug-12971-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sun, 29 Mar 2009 18:02:04 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12971
> 
>            Summary: "tg3 transmit timed out" when transmitting at high
>                     bitrate
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.29
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: dobrev666@gmail.com
>         Regression: No
> 
> 
> I have laptop - HP compaq 6715s with broadcom lan card (from lspci):
> 10:00.0 Ethernet controller: Broadcom Corporation NetLink BCM5906M Fast
> Ethernet PCI Express (rev 02). I am using slackware 12.2. I compiled kernel
> 2.6.29 from kernel.org. 
> 
> When I try to copy a file trough the LAN from this laptop with a command like
> this:
> scp test.bin 192.168.0.1:/tmp
> 
> Some MBytes are copied and the transmit stops and there is some messages in
> dmesg:
> 
> WARNING: at net/sched/sch_generic.c:226 dev_watchdog+0x1c2/0x1d0()
> Hardware name: HP Compaq 6715s (GR897ES#ABB)
> NETDEV WATCHDOG: eth0 (tg3): transmit timed out
> Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq
> snd_seq_devic
> e snd_pcm_oss snd_mixer_oss ipv6 cpufreq_stats powernow_k8 freq_table ppdev lp
> parpor
> t_pc parport fuse snd_hda_codec_analog pcmcia snd_hda_intel snd_hda_codec tg3
> fan yen
> ta_socket snd_hwdep video rsrc_nonstatic rtc_cmos snd_pcm thermal output
> rtc_core pcm
> cia_core ati_agp processor libphy rtc_lib psmouse i2c_piix4 agpgart container
> snd_tim
> er snd thermal_sys sg serio_raw evdev button battery ac wmi shpchp soundcore
> k8temp s
> nd_page_alloc hwmon
> Pid: 0, comm: swapper Not tainted 2.6.29-smp #1
> Call Trace:
>  [<c01294b6>] warn_slowpath+0x86/0xa0
>  [<c0120030>] ? sd_init_MC+0xa0/0xd0
>  [<c0120fce>] ? __enqueue_entity+0x8e/0xb0
>  [<c03a483f>] ? cpumask_next_and+0x1f/0x40
>  [<c012260a>] ? find_busiest_group+0x18a/0x710
>  [<c011f8e5>] ? enqueue_task+0x15/0x30
>  [<c03a94ed>] ? strlcpy+0x1d/0x60
>  [<c06bfc02>] dev_watchdog+0x1c2/0x1d0
>  [<c014320b>] ? getnstimeofday+0x4b/0x120
>  [<c01320f4>] run_timer_softirq+0x124/0x190
>  [<c06bfa40>] ? dev_watchdog+0x0/0x1d0
>  [<c012e03a>] __do_softirq+0x8a/0x150
>  [<c0132614>] ? update_process_times+0x54/0x70
>  [<c012e13b>] do_softirq+0x3b/0x50
>  [<c012e47b>] irq_exit+0x3b/0x50
>  [<c011467e>] smp_apic_timer_interrupt+0x5e/0x90
>  [<c0103940>] apic_timer_interrupt+0x28/0x30
>  [<c0109978>] ? default_idle+0x38/0x50
>  [<c0109b80>] c1e_idle+0x90/0xf0
>  [<c0109b91>] ? c1e_idle+0xa1/0xf0
>  [<c0101bea>] cpu_idle+0x4a/0x70
>  [<c072f705>] rest_init+0x55/0x60
> ---[ end trace 0c67ed7bcfb14db6 ]---
> tg3: eth0: transmit timed out, resetting
> tg3: DEBUG: MAC_TX_STATUS[00000008] MAC_RX_STATUS[00000000]
> tg3: DEBUG: RDMAC_STATUS[00000000] WDMAC_STATUS[00000000]
> tg3: tg3_stop_block timed out, ofs=1400 enable_bit=2
> tg3: tg3_stop_block timed out, ofs=c00 enable_bit=2
> tg3: tg3_stop_block timed out, ofs=4800 enable_bit=2
> tg3: eth0: Link is down.
> tg3: eth0: Link is up at 100 Mbps, full duplex.
> tg3: eth0: Flow control is on for TX and on for RX.
> 
> After that I cannot send or receive any data through the LAN. There is no ping
> to anywhere.
> These commands fix the problem:
> 
> ip l set dev eth0 down
> ip l set dev eth0 up
> 
> And when I execute `scp test.bin 192.168.0.1:/tmp` there is no network again.
> 
> But this laptop has no problems when receiving data. I can copy with scp from
> other PC connected to the same lan with 11Mbytes/s.
> 
> I have search the web to find a solution with no success.
> I have tried some kernel options like "irqpoll" and "acpi=off" with no success.

I assume that 2.6.28 was OK, and that this is a regression?
