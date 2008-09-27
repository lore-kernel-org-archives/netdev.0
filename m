From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 11663] New: via-rhine warn_on_slowpath (eth0:
 Transmit timed out, status 0000, PHY status 786d, resetting...)
Date: Sat, 27 Sep 2008 15:35:41 -0700
Message-ID: <20080927153541.58290a83.akpm@linux-foundation.org>
References: <bug-11663-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, domen@coderock.org,
	Roger Luethi <rl@hellgate.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34858 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753425AbYI0Wfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Sep 2008 18:35:45 -0400
In-Reply-To: <bug-11663-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

> On Sat, 27 Sep 2008 13:49:23 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=11663
> 
>            Summary: via-rhine warn_on_slowpath (eth0: Transmit timed out,
>                     status 0000, PHY status 786d, resetting...)
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.26
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: low
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: domen@coderock.org
> 
> 
> Latest working kernel version: /
> Earliest failing kernel version: /
> Distribution: Slackware
> Hardware Environment:
> 00:0a.0 Ethernet controller: VIA Technologies, Inc. VT6105 [Rhine-III] (rev 8b)
> 00:0b.0 Ethernet controller: VIA Technologies, Inc. VT6105 [Rhine-III] (rev 8b)
> 00:0a.0 0200: 1106:3106 (rev 8b)
>         Subsystem: 1106:0105
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 32 (750ns min, 2000ns max), Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 5
>         Region 0: I/O ports at a000 [size=256]
>         Region 1: Memory at e2000000 (32-bit, non-prefetchable) [size=256]
>         Capabilities: [44] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
> PME(D0+,D1+,D2+,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Kernel driver in use: via-rhine
>         Kernel modules: via-rhine
> 
> 00:0b.0 0200: 1106:3106 (rev 8b)
>         Subsystem: 1106:0105
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 32 (750ns min, 2000ns max), Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 12
>         Region 0: I/O ports at a400 [size=256]
>         Region 1: Memory at e2001000 (32-bit, non-prefetchable) [size=256]
>         Capabilities: [44] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
> PME(D0+,D1+,D2+,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Kernel driver in use: via-rhine
>         Kernel modules: via-rhine
> 
> Software Environment: /
> Problem Description:
> Warning in kernel log:
> [163481.000027] NETDEV WATCHDOG: eth0: transmit timed out
> [163481.000187] eth0: Transmit timed out, status 0000, PHY status 786d,
> resetting...
> [163481.000887] eth0: link up, 100Mbps, full-duplex, lpa 0x43E1
> [163481.000912] ------------[ cut here ]------------
> [163481.000916] WARNING: at
> /home/domen/kernel/linux-2.6.26/net/sched/sch_generic.c:222
> dev_watchdog+0xba/0xd0()
> [163481.000920] Modules linked in: tcp_diag inet_diag snd_seq_dummy snd_seq_oss
> snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss l2cap ipv6 binfmt_misc
> it87 hwmon_vid hwmon psmouse fuse ati_remote2 hci_usb bluetooth usbhid hid
> snd_mpu401 snd_cs4232 snd_opl3_lib snd_hwdep ns558 snd_cs4231_lib fan rtc_cmos
> rtc_core rtc_lib parport_pc parport thermal snd_via82xx gameport snd_ac97_codec
> ac97_bus button processor snd_pcm snd_timer snd_page_alloc snd_mpu401_uart
> snd_rawmidi snd_seq_device i2c_viapro i2c_core snd soundcore ehci_hcd via_agp
> via_rhine uhci_hcd mii agpgart shpchp evdev
> [163481.000975] Pid: 0, comm: swapper Not tainted 2.6.26 #2
> [163481.000982]  [<c011a60f>] warn_on_slowpath+0x5f/0x90
> [163481.001001]  [<f0838115>] rhine_enable_linkmon+0x45/0xa0 [via_rhine]
> [163481.001022]  [<f0839aa3>] mdio_read+0xb3/0xc0 [via_rhine]
> [163481.001032]  [<c011b50b>] printk+0x1b/0x20
> [163481.001039]  [<f081352d>] mii_check_media+0x13d/0x1e0 [mii]
> [163481.001051]  [<c0141130>] default_enable+0x10/0x20
> [163481.001063]  [<c01410cd>] check_irq_resend+0x1d/0x70
> [163481.001069]  [<c0140965>] __enable_irq+0x55/0x60
> [163481.001074]  [<f0838abd>] init_registers+0xad/0xd0 [via_rhine]
> [163481.001083]  [<f083a359>] rhine_tx_timeout+0xc9/0x100 [via_rhine]
> [163481.001094]  [<c0352dfa>] dev_watchdog+0xba/0xd0
> [163481.001099]  [<c0122570>] run_timer_softirq+0x110/0x160
> [163481.001113]  [<c011ee52>] __do_softirq+0x42/0x90
> [163481.001118]  [<c011eec7>] do_softirq+0x27/0x30
> [163481.001123]  [<c011f1c5>] irq_exit+0x45/0x60
> [163481.001126]  [<c0104cc9>] do_IRQ+0x39/0x70
> [163481.001134]  [<c012e102>] enqueue_hrtimer+0x72/0xf0
> [163481.001140]  [<f0a027d5>] acpi_processor_idle+0x0/0x3e3 [processor]
> [163481.001158]  [<c0103113>] common_interrupt+0x23/0x28
> [163481.001167]  [<f0a02a3f>] acpi_processor_idle+0x26a/0x3e3 [processor]
> [163481.001177]  [<f0a027d5>] acpi_processor_idle+0x0/0x3e3 [processor]
> [163481.001187]  [<c0101aa7>] cpu_idle+0x37/0x80
> [163481.001194]  =======================
> [163481.001197] ---[ end trace b2677aed7c2c6876 ]---
> 
> 
> Steps to reproduce: dunno
> 


