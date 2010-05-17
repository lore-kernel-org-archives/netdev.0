From: Joerg Roedel <joerg.roedel@amd.com>
Subject: Kernel crash with sky2
Date: Mon, 17 May 2010 20:52:28 +0200
Message-ID: <20100517185228.GG9007@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-va3.bigfish.com ([216.32.180.111]:46171 "EHLO
	mail10-va3-R.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754752Ab0EQTWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 15:22:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

I experience the following crash with 2.6.34 in the sky2 code on my
laptop when I plug off the lan-cable and then plug-off the power cable
and switching to battery. It does not happen with acpi=off.
I havn't tested earlier kernels but I can do that if necessary. I did
some initial research and found that the driver assumes that port[1] is
available when the status bits for it are set on the device. Please let
me know if you need any additional information or want me to test
anything.

The crash message is:

[  107.010134] sky2 0000:02:00.0: PCI hardware error (0xffff)
[  107.015614] sky2 0000:02:00.0: PCI Express error (0xffffffff)
[  107.021355] sky2 0000:02:00.0: eth0: ram data read parity error
[  107.027249] sky2 0000:02:00.0: eth0: ram data write parity error
[  107.033253] sky2 0000:02:00.0: eth0: MAC parity error
[  107.038283] sky2 0000:02:00.0: eth0: RX parity error
[  107.043259] sky2 0000:02:00.0: eth0: TCP segmentation error
[  107.048823] BUG: unable to handle kernel NULL pointer dereference at 0000000000000438
[  107.053238] IP: [<ffffffffa0001713>] sky2_hw_error+0x153/0x310 [sky2]
[  107.053238] PGD 139600067 PUD 139643067 PMD 0 
[  107.053238] Oops: 0000 [#1] SMP 
[  107.053238] last sysfs file: /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
[  107.053238] CPU 1 
[  107.053238] Modules linked in: snd_hda_codec_atihdmi snd_hda_codec_idt snd_hda_intel rfcomm snd_pcm_oss snd_hda_2
[  107.053238] 
[  107.053238] Pid: 7, comm: ksoftirqd/1 Not tainted 2.6.34-default #1 307E/HP ProBook 6545b
[  107.053238] RIP: 0010:[<ffffffffa0001713>]  [<ffffffffa0001713>] sky2_hw_error+0x153/0x310 [sky2]
[  107.053238] RSP: 0018:ffff880001e83d78  EFLAGS: 00010202
[  107.053238] RAX: 0000000000000001 RBX: 0000000000ffffff RCX: 00000000000001f4
[  107.053238] RDX: 000000000000000a RSI: 0000000000000202 RDI: ffffffff81a5dc80
[  107.053238] RBP: ffff880001e83db8 R08: 00000000ffffffff R09: 0000000000000000
[  107.053238] R10: 0000000000000000 R11: 0000000000000001 R12: ffff88012862da00
[  107.053238] R13: 0000000000000001 R14: 0000000000000001 R15: 0000000000000000
[  107.053238] FS:  00007ff07987b800(0000) GS:ffff880001e80000(0000) knlGS:0000000000000000
[  107.053238] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  107.053238] CR2: 0000000000000438 CR3: 0000000139641000 CR4: 00000000000006e0
[  107.053238] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  107.053238] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  107.053238] Process ksoftirqd/1 (pid: 7, threadinfo ffff88013badc000, task ffff88013bad1700)
[  107.053238] Stack:
[  107.053238]  ffff88013b488b00 ffff8801284f7000 00000a8800000ad7 00000000ffffffff
[  107.053238] <0> ffff88012862da00 00000000ffffffff ffff88013b4d1000 ffff88013b488b00
[  107.053238] <0> ffff880001e83ed8 ffffffffa000720f 0000000000000082 0000000000000000
[  107.053238] Call Trace:
[  107.053238]  <IRQ> 
[  107.053238]  [<ffffffffa000720f>] sky2_poll+0xeef/0x1020 [sky2]
[  107.053238]  [<ffffffff8101e1bb>] ? lapic_timer_broadcast+0x1b/0x20
[  107.053238]  [<ffffffff8106a76f>] ? __queue_work+0x3f/0x50
[  107.053238]  [<ffffffff8106a7b9>] ? delayed_work_timer_fn+0x39/0x50
[  107.053238]  [<ffffffff8142bffd>] net_rx_action+0xed/0x1f0
[  107.053238]  [<ffffffff81057250>] __do_softirq+0xb0/0x1d0
[  107.053238]  [<ffffffff81003e4c>] call_softirq+0x1c/0x30
[  107.053238]  <EOI> 
[  107.053238]  [<ffffffff810058b5>] ? do_softirq+0x55/0x90
[  107.053238]  [<ffffffff81056dd0>] run_ksoftirqd+0x80/0x130
[  107.053238]  [<ffffffff81056d50>] ? run_ksoftirqd+0x0/0x130
[  107.053238]  [<ffffffff8106e8e6>] kthread+0x96/0xa0
[  107.053238]  [<ffffffff81003d54>] kernel_thread_helper+0x4/0x10
[  107.053238]  [<ffffffff8106e850>] ? kthread+0x0/0xa0
[  107.053238]  [<ffffffff81003d50>] ? kernel_thread_helper+0x0/0x10
[  107.053238] Code: e8 d3 a7 43 e1 85 c0 0f 85 f5 00 00 00 44 89 f0 ba 00 02 00 00 c1 e0 06 0d a0 01 00 00 89 c0 4 
[  107.053238] RIP  [<ffffffffa0001713>] sky2_hw_error+0x153/0x310 [sky2]
[  107.053238]  RSP <ffff880001e83d78>
[  107.053238] CR2: 0000000000000438
[  107.392268] ---[ end trace 8a4d942e73cd8681 ]---
[  107.396866] Kernel panic - not syncing: Fatal exception in interrupt
[  107.403214] Pid: 7, comm: ksoftirqd/1 Tainted: G      D    2.6.34-default #1
[  107.410230] Call Trace:
[  107.412695]  <IRQ>  [<ffffffff8150d49d>] panic+0x7d/0xf7
[  107.418004]  [<ffffffff81511502>] oops_end+0xe2/0xf0
[  107.422970]  [<ffffffff8102dd6b>] no_context+0xfb/0x260
[  107.428174]  [<ffffffff8102dfdd>] __bad_area_nosemaphore+0x10d/0x1c0
[  107.434523]  [<ffffffff8102e0a3>] bad_area_nosemaphore+0x13/0x20
[  107.440513]  [<ffffffff81513aaf>] do_page_fault+0x26f/0x330
[  107.446084]  [<ffffffff815108df>] page_fault+0x1f/0x30
[  107.451202]  [<ffffffffa0001713>] ? sky2_hw_error+0x153/0x310 [sky2]
[  107.457554]  [<ffffffffa00015f6>] ? sky2_hw_error+0x36/0x310 [sky2]
[  107.463811]  [<ffffffffa000720f>] sky2_poll+0xeef/0x1020 [sky2]
[  107.469706]  [<ffffffff8101e1bb>] ? lapic_timer_broadcast+0x1b/0x20
[  107.475980]  [<ffffffff8106a76f>] ? __queue_work+0x3f/0x50
[  107.481457]  [<ffffffff8106a7b9>] ? delayed_work_timer_fn+0x39/0x50
[  107.487698]  [<ffffffff8142bffd>] net_rx_action+0xed/0x1f0
[  107.493183]  [<ffffffff81057250>] __do_softirq+0xb0/0x1d0
[  107.498558]  [<ffffffff81003e4c>] call_softirq+0x1c/0x30
[  107.503868]  <EOI>  [<ffffffff810058b5>] ? do_softirq+0x55/0x90
[  107.509788]  [<ffffffff81056dd0>] run_ksoftirqd+0x80/0x130
[  107.515275]  [<ffffffff81056d50>] ? run_ksoftirqd+0x0/0x130
[  107.520823]  [<ffffffff8106e8e6>] kthread+0x96/0xa0
[  107.525702]  [<ffffffff81003d54>] kernel_thread_helper+0x4/0x10
[  107.531612]  [<ffffffff8106e850>] ? kthread+0x0/0xa0
[  107.536563]  [<ffffffff81003d50>] ? kernel_thread_helper+0x0/0x10
[  107.542657] [drm:drm_fb_helper_panic] *ERROR* panic occurred, switching back to text console
[  107.551054] BUG: scheduling while atomic: ksoftirqd/1/7/0x10000100
[  107.552642] Modules linked in: snd_hda_codec_atihdmi snd_hda_codec_idt snd_hda_intel rfcomm snd_pcm_oss snd_hda_2
[  107.552642] Pid: 7, comm: ksoftirqd/1 Tainted: G      D    2.6.34-default #1
[  107.552642] Call Trace:
[  107.552642]  <IRQ>  [<ffffffff810402d1>] __schedule_bug+0x61/0x70
[  107.552642]  [<ffffffff8150ddec>] schedule+0x6cc/0x800
[  107.552642]  [<ffffffff8104c8ba>] __cond_resched+0x2a/0x40
[  107.552642]  [<ffffffff8150e020>] _cond_resched+0x30/0x40
[  107.552642]  [<ffffffff8111e241>] __kmalloc+0xc1/0x190
[  107.552642]  [<ffffffffa00b5613>] ? T.687+0x13/0x20 [drm_kms_helper]
[  107.552642]  [<ffffffffa00b5613>] T.687+0x13/0x20 [drm_kms_helper]
[  107.552642]  [<ffffffffa00b5707>] drm_crtc_helper_set_config+0xe7/0x880 [drm_kms_helper]
[  107.552642]  [<ffffffffa00b35d4>] drm_fb_helper_force_kernel_mode+0x74/0xa0 [drm_kms_helper]
[  107.552642]  [<ffffffffa00b3663>] drm_fb_helper_panic+0x23/0x30 [drm_kms_helper]
[  107.552642]  [<ffffffff81513bc6>] notifier_call_chain+0x56/0x80
[  107.552642]  [<ffffffff81513c2a>] atomic_notifier_call_chain+0x1a/0x20
[  107.552642]  [<ffffffff8150d4c9>] panic+0xa9/0xf7
[  107.552642]  [<ffffffff81511502>] oops_end+0xe2/0xf0
[  107.552642]  [<ffffffff8102dd6b>] no_context+0xfb/0x260
[  107.552642]  [<ffffffff8102dfdd>] __bad_area_nosemaphore+0x10d/0x1c0
[  107.552642]  [<ffffffff8102e0a3>] bad_area_nosemaphore+0x13/0x20
[  107.552642]  [<ffffffff81513aaf>] do_page_fault+0x26f/0x330
[  107.552642]  [<ffffffff815108df>] page_fault+0x1f/0x30
[  107.552642]  [<ffffffffa0001713>] ? sky2_hw_error+0x153/0x310 [sky2]
[  107.552642]  [<ffffffffa00015f6>] ? sky2_hw_error+0x36/0x310 [sky2]
[  107.552642]  [<ffffffffa000720f>] sky2_poll+0xeef/0x1020 [sky2]
[  107.552642]  [<ffffffff8101e1bb>] ? lapic_timer_broadcast+0x1b/0x20
[  107.552642]  [<ffffffff8106a76f>] ? __queue_work+0x3f/0x50
[  107.552642]  [<ffffffff8106a7b9>] ? delayed_work_timer_fn+0x39/0x50
[  107.552642]  [<ffffffff8142bffd>] net_rx_action+0xed/0x1f0
[  107.552642]  [<ffffffff81057250>] __do_softirq+0xb0/0x1d0
[  107.552642]  [<ffffffff81003e4c>] call_softirq+0x1c/0x30
[  107.552642]  <EOI>  [<ffffffff810058b5>] ? do_softirq+0x55/0x90
[  107.552642]  [<ffffffff81056dd0>] run_ksoftirqd+0x80/0x130
[  107.552642]  [<ffffffff81056d50>] ? run_ksoftirqd+0x0/0x130
[  107.552642]  [<ffffffff8106e8e6>] kthread+0x96/0xa0
[  107.552642]  [<ffffffff81003d54>] kernel_thread_helper+0x4/0x10
[  107.552642]  [<ffffffff8106e850>] ? kthread+0x0/0xa0
[  107.552642]  [<ffffffff81003d50>] ? kernel_thread_helper+0x0/0x10


lspci -vvv -n of the device:

02:00.0 0200: 11ab:436c (rev 10)
	Subsystem: 103c:3080
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 28
	Region 0: Memory at d5200000 (64-bit, non-prefetchable) [size=16K]
	Region 2: I/O ports at 4000 [size=256]
	Expansion ROM at d0000000 [disabled] [size=128K]
	Capabilities: [48] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
	Capabilities: [50] Vital Product Data <?>
	Capabilities: [5c] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable+
		Address: 00000000fee0100c  Data: 4189
	Capabilities: [c0] Express (v2) Legacy Endpoint, MSI 00
		DevCap:	MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
			ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
		DevCtl:	Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
			RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
		LnkCap:	Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <256ns, L1 unlimited
			ClockPM+ Suprise- LLActRep- BwNot-
		LnkCtl:	ASPM L0s L1 Enabled; RCB 128 bytes Disabled- Retrain- CommClk+
			ExtSynch- ClockPM+ AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
	Capabilities: [100] Advanced Error Reporting <?>
	Capabilities: [130] Device Serial Number 70-5a-b6-ff-ff-97-a6-80
	Kernel driver in use: sky2
	Kernel modules: sky2


Thanks,

	Joerg


