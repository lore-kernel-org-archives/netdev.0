From: Borislav Petkov <bp@alien8.de>
Subject: atl1c: WARNING: at net/sched/sch_generic.c:255 dev_watchdog
Date: Wed, 7 Dec 2011 00:27:41 +0100
Message-ID: <20111206232741.GA5368@x1.osrc.amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

this seems like a pretty old issue judging by a quick net search. It
still triggers on latest -rc4 here, below the whole trace. I'm willing
to test patches :).

[14622.820555] atl1c 0000:02:00.0: atl1c: eth0 NIC Link is Up<100 Mbps Full Duplex>
[14632.816280] ------------[ cut here ]------------
[14632.816314] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x237/0x240()
[14632.816323] Hardware name: 30515QG
[14632.816332] NETDEV WATCHDOG: eth0 (atl1c): transmit queue 0 timed out
[14632.816340] Modules linked in: microcode powernow_k8 mperf cpufreq_stats cpufreq_conservative cpufreq_powersave cpufreq_userspace binfmt_misc uinput kvm_amd kvm fuse dm_crypt dm_mod ipv6 vfat fat loop snd_hda_codec_conexant snd_hda_codec_hdmi usbhid cdc_ncm usbnet cdc_wdm cdc_acm arc4 snd_hda_intel snd_hda_codec snd_hwdep rtl8192c_common rtlwifi snd_pcm mac80211 thinkpad_acpi snd_seq snd_timer snd_seq_device radeon ohci_hcd ehci_hcd evdev snd atl1c nvram cfg80211 pcspkr k10temp ttm rfkill soundcore snd_page_alloc video processor drm_kms_helper ac thermal button battery thermal_sys [last unloaded: rtl8192ce]
[14632.816594] Pid: 0, comm: kworker/0:0 Not tainted 3.2.0-rc4+ #32
[14632.816603] Call Trace:
[14632.816611]  <IRQ>  [<ffffffff8104537f>] warn_slowpath_common+0x7f/0xc0
[14632.816640]  [<ffffffff81045476>] warn_slowpath_fmt+0x46/0x50
[14632.816658]  [<ffffffff81399087>] dev_watchdog+0x237/0x240
[14632.816673]  [<ffffffff81055845>] run_timer_softirq+0x195/0x4e0
[14632.816687]  [<ffffffff810557af>] ? run_timer_softirq+0xff/0x4e0
[14632.816700]  [<ffffffff81398e50>] ? pfifo_fast_init+0xa0/0xa0
[14632.816716]  [<ffffffff8104c935>] __do_softirq+0xc5/0x290
[14632.816730]  [<ffffffff81078644>] ? clockevents_program_event+0x74/0x100
[14632.816746]  [<ffffffff8142692c>] call_softirq+0x1c/0x30
[14632.816760]  [<ffffffff81003d75>] do_softirq+0x85/0xc0
[14632.816773]  [<ffffffff8104ce36>] irq_exit+0x96/0xe0
[14632.816786]  [<ffffffff81426fab>] smp_apic_timer_interrupt+0x6b/0x98
[14632.816799]  [<ffffffff814260b0>] apic_timer_interrupt+0x70/0x80
[14632.816807]  <EOI>  [<ffffffff81009f96>] ? native_sched_clock+0x26/0x70
[14632.816842]  [<ffffffffa005f160>] ? acpi_idle_enter_simple+0xd2/0x114 [processor]
[14632.816863]  [<ffffffffa005f165>] ? acpi_idle_enter_simple+0xd7/0x114 [processor]
[14632.816884]  [<ffffffffa005f160>] ? acpi_idle_enter_simple+0xd2/0x114 [processor]
[14632.816902]  [<ffffffff813591cc>] cpuidle_idle_call+0xcc/0x240
[14632.816915]  [<ffffffff8100097b>] ? cpu_idle+0xbb/0x130
[14632.816932]  [<ffffffff8100098f>] cpu_idle+0xcf/0x130
[14632.816946]  [<ffffffff814152ec>] start_secondary+0x1fc/0x203
[14632.816958] ---[ end trace 48e9f392fdd335fa ]---
[14632.842367] atl1c 0000:02:00.0: irq 44 for MSI/MSI-X
[14632.842649] atl1c 0000:02:00.0: atl1c: eth0 NIC Link is Up<100 Mbps Full Duplex>

Thanks.

-- 
Regards/Gruss,
Boris.
