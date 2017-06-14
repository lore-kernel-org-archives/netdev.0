From: Borislav Petkov <bp@alien8.de>
Subject: WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:316 dev_watchdog
Date: Wed, 14 Jun 2017 12:19:03 +0200
Message-ID: <20170614101903.2h3haesxc6keirgv@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.skyhub.de ([5.9.137.197]:44118 "EHLO mail.skyhub.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750728AbdFNKTL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 06:19:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

when I run a small CPU hotplugging script while I'm logged into the
machine over ssh, I see the dev watchdog timeout below. Driver is
e1000e.

After the eth0 reset, I ifdown/ifup the eth0 interface and it comes back
up again just fine.

Any ideas?

Kernel is -rc5 + tip/master.

...
[   48.954397] Broke affinity for irq 29
[   48.954402] Broke affinity for irq 30
[   48.954407] Broke affinity for irq 31
[   48.955486] smpboot: CPU 3 is now offline
[   48.989339] x86: Booting SMP configuration:
[   48.989864] smpboot: Booting Node 0 Processor 1 APIC 0x1
[   49.009156] smpboot: Booting Node 0 Processor 2 APIC 0x2
[   49.033626] smpboot: Booting Node 0 Processor 3 APIC 0x3
[   62.944886] NETDEV WATCHDOG: eth0 (e1000e): transmit queue 0 timed out
[   62.946579] ------------[ cut here ]------------
[   62.947842] WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:316 dev_watchdog+0x21b/0x220
[   62.947844] Modules linked in: msr cpufreq_powersave cpufreq_userspace cpufreq_conservative binfmt_misc uinput vfat fat l
oop dm_crypt dm_mod dax hid_generic usbhid hid x86_pkg_temp_thermal coretemp kvm_intel arc4 kvm irqbypass crc32_pclmul iwldv
m crc32c_intel iTCO_wdt ghash_clmulni_intel iTCO_vendor_support mac80211 snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_co
dec_generic aesni_intel aes_x86_64 crypto_simd cryptd iwlwifi sdhci_pci snd_hda_intel glue_helper snd_hda_codec intel_cstate
 intel_rapl_perf snd_hwdep sdhci snd_hda_core pcspkr serio_raw i2c_i801 mmc_core snd_pcm sg cfg80211 lpc_ich ehci_pci mfd_co
re thinkpad_acpi snd_timer ehci_hcd wmi nvram thermal snd soundcore xhci_pci led_class ac battery xhci_hcd
[   62.947949] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.12.0-rc5+ #2
[   62.947951] Hardware name: LENOVO 2320CTO/2320CTO, BIOS G2ET86WW (2.06 ) 11/13/2012
[   62.947953] task: ffffffff85814500 task.stack: ffffffff85800000
[   62.947957] RIP: 0010:dev_watchdog+0x21b/0x220
[   62.947959] RSP: 0018:ffffa3ecdd203e48 EFLAGS: 00010296
[   62.947963] RAX: 000000000000003a RBX: 0000000000000000 RCX: 0000000000000000
[   62.947965] RDX: 0000000000000103 RSI: 00000000000000f6 RDI: 0000000000000001
[   62.947967] RBP: ffffa3ecdd203e78 R08: 0000000000000000 R09: 0000000000000001
[   62.947968] R10: 0000000000000000 R11: 0000000000000000 R12: ffffa3ecd3bef480
[   62.947970] R13: 0000000000000000 R14: ffffa3ecd20c4000 R15: 0000000000000001
[   62.947973] FS:  0000000000000000(0000) GS:ffffa3ecdd200000(0000) knlGS:0000000000000000
[   62.947975] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   62.947977] CR2: 00007fa6610d3000 CR3: 000000004f80f000 CR4: 00000000001406f0
[   62.947979] Call Trace:
[   62.947982]  <IRQ>
[   62.947989]  ? qdisc_rcu_free+0x50/0x50
[   62.947996]  call_timer_fn+0x93/0x370
[   62.948004]  ? qdisc_rcu_free+0x50/0x50
[   62.948008]  run_timer_softirq+0x231/0x600
[   62.948014]  ? ktime_get+0x8e/0x110
[   62.948027]  __do_softirq+0x11b/0x496
[   62.948039]  irq_exit+0xb5/0xc0
[   62.948043]  smp_apic_timer_interrupt+0x3d/0x50
[   62.948047]  apic_timer_interrupt+0x90/0xa0
[   62.948053] RIP: 0010:cpuidle_enter_state+0x143/0x3b0
[   62.948055] RSP: 0018:ffffffff85803df0 EFLAGS: 00000206 ORIG_RAX: ffffffffffffff10
[   62.948059] RAX: ffffffff85814500 RBX: 0000000000000005 RCX: 0000000000000001
[   62.948061] RDX: 20c49ba5e353f7cf RSI: 0000000000000001 RDI: ffffffff85814500
[   62.948063] RBP: ffffffff85803e28 R08: ffffa3ecdd217ae4 R09: 0000000000000018
[   62.948064] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000005
[   62.948066] R13: ffffa3ecdd2221d0 R14: ffffffff858b1518 R15: 0000000ea217da13
[   62.948069]  </IRQ>
[   62.948089]  cpuidle_enter+0x17/0x20
[   62.948094]  call_cpuidle+0x23/0x40
[   62.948098]  do_idle+0x188/0x1d0
[   62.948105]  cpu_startup_entry+0x62/0x70
[   62.948111]  rest_init+0xcf/0xe0
[   62.948120]  start_kernel+0x3a9/0x3b6
[   62.948128]  x86_64_start_reservations+0x29/0x2b
[   62.948134]  x86_64_start_kernel+0x187/0x198
[   62.948144]  secondary_startup_64+0x9f/0x9f
[   62.948148]  ? secondary_startup_64+0x9f/0x9f
[   62.948162] Code: 63 8e 18 04 00 00 eb 95 4c 89 f7 c6 05 d6 29 62 00 01 e8 59 6f fd ff 89 d9 4c 89 f6 48 c7 c7 e0 de 6c 8
5 48 89 c2 e8 99 c0 a9 ff <0f> ff eb c3 90 0f 1f 44 00 00 48 c7 47 08 00 00 00 00 55 48 c7 
[   62.948242] ---[ end trace 5af3fdd778e0ef18 ]---
[   62.948463] e1000e 0000:00:19.0 eth0: Reset adapter unexpectedly
[   64.750919] e1000e: eth0 NIC Link is Up 100 Mbps Full Duplex, Flow Control: Rx/Tx


-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
