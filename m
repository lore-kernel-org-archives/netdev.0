From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG or cosmic ray] WARNING: at net/sched/sch_generic.c:222
 dev_watchdog+0xe8/0x100()
Date: Fri, 6 Jun 2008 03:15:11 -0700
Message-ID: <20080606031511.8f83359c.akpm@linux-foundation.org>
References: <200806050727.m557RaIH007153@post.webmailer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: c4p7n1@capitanio.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54468 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753832AbYFFKPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 06:15:49 -0400
In-Reply-To: <200806050727.m557RaIH007153@post.webmailer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(cc netdev)

On Thu, 5 Jun 2008 09:27:36 +0200 (MEST) c4p7n1@capitanio.org wrote:

> I've got this on rc3. It's _not_ reproducible even on heavy load.
> After that the Ethernet PCIe chip went into a borken state until next reboot.
> 
> [   46.316926] r8169: eth0: link up
> [   48.901435] [drm] Initialized drm 1.1.0 20060810
> [   48.904771] PCI: Setting latency timer of device 0000:00:02.0 to 64
> [   48.908103] [drm] Initialized i915 1.6.0 20060119 on minor 0
> [   49.544674] NET: Registered protocol family 17
> [  125.004020] NETDEV WATCHDOG: eth0: transmit timed out
> [  125.004043] ------------[ cut here ]------------
> [  125.004049] WARNING: at net/sched/sch_generic.c:222 dev_watchdog+0xe8/0x100()
> [  125.004053] Modules linked in: af_packet i915 drm rfcomm l2cap bluetooth acpi_cpufreq cpufreq_powersave cpufreq_stats cpufreq_userspace cpufreq_conservative wmi sbs sbshc iptable_filter ip_tables x_tables fuse usbhid hid joydev snd_hda_intel snd_pcm_oss snd_mixer_oss snd_pcm snd_page_alloc snd_hwdep snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq video psmouse output snd_timer snd_seq_device snd r8169 backlight evdev soundcore uhci_hcd ehci_hcd iTCO_wdt iTCO_vendor_support usbcore
> [  125.004143] Pid: 0, comm: swapper Not tainted 2.6.26-rc3c4p7n1-00308-g75d3bce #1
> [  125.004153]  [<c0125aaf>] warn_on_slowpath+0x5f/0x90
> [  125.004168]  [<c0138e00>] autoremove_wake_function+0x0/0x40
> [  125.004179]  [<c011ae7b>] __wake_up_common+0x4b/0x80
> [  125.004192]  [<c011ccae>] __wake_up+0x3e/0x60
> [  125.004201]  [<c012626b>] wake_up_klogd+0x3b/0x40
> [  125.004209]  [<c0126966>] vprintk+0x346/0x3b0
> [  125.004221]  [<c012ee47>] lock_timer_base+0x27/0x60
> [  125.004230]  [<c0135e10>] delayed_work_timer_fn+0x0/0x20
> [  125.004238]  [<c012ef8d>] __mod_timer+0x9d/0xb0
> [  125.004248]  [<c0136044>] queue_delayed_work_on+0x84/0xc0
> [  125.004258]  [<c0392818>] dev_watchdog+0xe8/0x100
> [  125.004267]  [<c012e8de>] run_timer_softirq+0x15e/0x1d0
> [  125.004274]  [<c0392730>] dev_watchdog+0x0/0x100
> [  125.004282]  [<c0142870>] tick_handle_oneshot_broadcast+0x100/0x120
> [  125.004292]  [<c0392730>] dev_watchdog+0x0/0x100
> [  125.004302]  [<c012ab13>] __do_softirq+0x63/0xc0
> [  125.004310]  [<c012aba7>] do_softirq+0x37/0x40
> [  125.004317]  [<c012ad18>] irq_exit+0x68/0x80
> [  125.004323]  [<c0106370>] do_IRQ+0x40/0x70
> [  125.004333]  [<c0104767>] common_interrupt+0x23/0x28
> [  125.004344]  [<c01300d8>] prepare_signal+0x28/0x170
> [  125.004352]  [<c02e67ed>] acpi_idle_enter_bm+0x28c/0x2f6
> [  125.004365]  [<c0372cab>] cpuidle_idle_call+0x7b/0xc0
> [  125.004373]  [<c0372c30>] cpuidle_idle_call+0x0/0xc0
> [  125.004381]  [<c010275a>] cpu_idle+0x5a/0xe0
> [  125.004395]  =======================
> [  125.004399] ---[ end trace b7a56030e016660f ]---
> [  125.682725] r8169: eth0: link up
> ...
> [ 1337.654531] NETDEV WATCHDOG: eth0: transmit timed out
> [ 1338.333962] r8169: eth0: link up
> 
> ...
> 
> rmmod r8169 && modprobe r8169
> 
> [ 1504.171195] ACPI: PCI interrupt for device 0000:02:00.0 disabled
> [ 1515.491199] r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
> [ 1515.491285] ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 16 (level, low) -> IRQ 16
> [ 1515.494466] PCI: cache line size of 32 is not supported by device 0000:02:00.0
> [ 1515.494539] ACPI: PCI interrupt for device 0000:02:00.0 disabled
> [ 1515.495561] r8169: probe of 0000:02:00.0 failed with error -22
> 
> lspci
> 02:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL8101E PCI Express Fast Ethernet controller [10ec:8136] (rev ff) (prog-if ff)
>         !!! Unknown header type 7f
> 
> -------------------
> 
> after a reboot:
> 
> [  833.345672] r8169: eth0: link up
> [  835.599177] NET: Registered protocol family 17
> ...
> [ 1355.282122] r8169: eth0: link down
> [ 1381.528391] r8169: eth0: link up
> ...
> 
> 02:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL8101E PCI Express Fast Ethernet controller [10ec:8136] (rev 02)
>         Subsystem: Toshiba America Info Systems Unknown device [1179:ff64]
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0, Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 220
>         Region 0: I/O ports at 3000 [size=256]
>         Region 2: Memory at 90010000 (64-bit, prefetchable) [size=4K]
>         Region 4: Memory at 90000000 (64-bit, prefetchable) [size=64K]
>         Capabilities: [40] Power Management version 7
>                 Flags: PMEClk- DSI+ D1+ D2- AuxCurrent=375mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable+
>                 Address: 00000000fee0300c  Data: 41e9
>         Capabilities: [70] Express Endpoint IRQ 1
>                 Device: Supported: MaxPayload 256 bytes, PhantFunc 0, ExtTag-
>                 Device: Latency L0s <512ns, L1 <64us
>                 Device: AtnBtn- AtnInd- PwrInd-
>                 Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
>                 Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                 Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
>                 Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 0
>                 Link: Latency L0s <512ns, L1 <64us
>                 Link: ASPM L1 Enabled RCB 64 bytes CommClk+ ExtSynch-
>                 Link: Speed 2.5Gb/s, Width x1
>         Capabilities: [ac] MSI-X: Enable- Mask- TabSize=2
>                 Vector table: BAR=4 offset=00000000
>                 PBA: BAR=4 offset=00000800
>         Capabilities: [cc] Vital Product Data
>         Capabilities: [100] Advanced Error Reporting
>         Capabilities: [140] Virtual Channel
>         Capabilities: [160] Device Serial Number 00-00-ff-ff-00-00-00-08
> 
> 

