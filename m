From: Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>
Subject: WARNING: CPU: 1 PID: 2485 at
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c:1752
 iwl_trans_pcie_grab_nic_access+0x110/0x120 [iwlwifi]
Date: Fri, 15 Apr 2016 04:07:10 +0200
Message-ID: <20160415020710.GA2700@cz.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Intel Linux Wireless <linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Luca Coelho <luciano.coelho-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Sara Sharon <sara.sharon-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Haim Dreyfuss <haim.dreyfuss-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

so I'm seeing this when wlan0 tries to associate. On 4.6-rc2 + tip.
After that, wifi is dead in the water. Anyone have a clue?

And 4.5 seems fine, I'm typing from it as we speak.

...
[    2.111418] iwlwifi 0000:02:00.0: loaded firmware version 21.302800.0 op_mode iwlmvm
...
[    2.220954] iwlwifi 0000:02:00.0: Detected Intel(R) Dual Band Wireless AC 7265, REV=0x210
[    2.221460] iwlwifi 0000:02:00.0: L1 Enabled - LTR Disabled
[    2.221988] iwlwifi 0000:02:00.0: L1 Enabled - LTR Disabled
...
[  311.776764] iwlwifi 0000:02:00.0: L1 Enabled - LTR Disabled
[  311.777226] iwlwifi 0000:02:00.0: L1 Enabled - LTR Disabled
[  311.837783] iwlwifi 0000:02:00.0: L1 Enabled - LTR Disabled
[  311.838262] iwlwifi 0000:02:00.0: L1 Enabled - LTR Disabled
[  311.853871] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
[  315.606321] wlan0: authenticate with 00:c0:23:b9:ff:10
[  315.609802] wlan0: send auth to 00:c0:23:b9:ff:10 (try 1/3)
[  315.612246] wlan0: authenticated
[  315.612656] iwlwifi 0000:02:00.0 wlan0: disabling HT as WMM/QoS is not supported by the AP
[  315.612946] iwlwifi 0000:02:00.0 wlan0: disabling VHT as WMM/QoS is not supported by the AP
[  315.614655] wlan0: associate with 00:c0:23:b9:ff:10 (try 1/3)
[  315.718696] wlan0: associate with 00:c0:23:b9:ff:10 (try 2/3)
[  315.722311] wlan0: deauthenticated from 00:c0:23:b9:ff:10 while associating (Reason: 6=CLASS2_FRAME_FROM_NONAUTH_STA)
[  316.159994] wlan0: authenticate with 00:c0:23:ba:5a:70
[  316.162826] wlan0: send auth to 00:c0:23:ba:5a:70 (try 1/3)
[  316.166422] wlan0: authenticated
[  316.166864] iwlwifi 0000:02:00.0 wlan0: disabling HT as WMM/QoS is not supported by the AP
[  316.167164] iwlwifi 0000:02:00.0 wlan0: disabling VHT as WMM/QoS is not supported by the AP
[  316.170689] wlan0: associate with 00:c0:23:ba:5a:70 (try 1/3)
[  316.173951] wlan0: RX AssocResp from 00:c0:23:ba:5a:70 (capab=0x121 status=0 aid=4)
[  316.175966] wlan0: associated
[  316.176160] IPv6: ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
[  653.272205] iwlwifi 0000:02:00.0: Failed to wake NIC for hcmd
[  653.272497] iwlwifi 0000:02:00.0: Error sending STATISTICS_CMD: enqueue_hcmd failed: -5
[  653.290868] iwlwifi 0000:02:00.0: Failed to wake NIC for hcmd
[  653.291211] iwlwifi 0000:02:00.0: Error sending STATISTICS_CMD: enqueue_hcmd failed: -5
[  661.124556] iwlwifi 0000:02:00.0: Queue 2 stuck for 10000 ms.
[  661.124748] iwlwifi 0000:02:00.0: Current SW read_ptr 59 write_ptr 63
[  661.142657] ------------[ cut here ]------------
[  661.142816] WARNING: CPU: 1 PID: 2485 at drivers/net/wireless/intel/iwlwifi/pcie/trans.c:1752 iwl_trans_pcie_grab_nic_access+0x110/0x120 [iwlwifi]
[  661.143231] Timeout waiting for hardware access (CSR_GP_CNTRL 0xffffffff)
[  661.143449] Modules linked in: msr hid_generic arc4 kvm_amd kvm irqbypass crct10dif_pclmul crc32_pclmul iwlmvm crc32c_intel mac80211 jitterentropy_rng sha256_generic hmac acpi_cpufreq tpm_infineon drbg amdgpu iwlwifi aesni_intel snd_hda_codec_conexant aes_x86_64 glue_helper lrw snd_hda_codec_generic gf128mul snd_hda_codec_hdmi ablk_helper cryptd psmouse snd_hda_intel evdev joydev input_leds cfg80211 snd_hda_codec serio_raw pcspkr snd_hwdep snd_hda_core tg3 snd_pcm fam15h_power ptp edac_core pps_core xhci_pci k10temp snd_timer ttm xhci_hcd libphy ehci_pci snd ehci_hcd i2c_piix4 sg soundcore battery tpm_tis tpm video processor ac button sd_mod thermal
[  661.145657] CPU: 1 PID: 2485 Comm: iceweasel Tainted: G        W       4.6.0-rc2+ #1
[  661.145905] Hardware name: HP HP EliteBook 745 G3/807E, BIOS N73 Ver. 01.08 01/28/2016
[  661.146159]  0000000000000000 ffffffff812d9e79 ffff88043dc83d78 0000000000000000
[  661.146418]  ffffffff810588ac ffff880424740000 ffff88043dc83dc8 ffff880424747adc
[  661.146677]  ffff88043dc83e00 ffff88009b2301e0 ffff88009b2301f0 ffffffff8105891f
[  661.146937] Call Trace:
[  661.147020]  <IRQ>  [<ffffffff812d9e79>] ? dump_stack+0x5c/0x83
[  661.147223]  [<ffffffff810588ac>] ? __warn+0xec/0x110
[  661.147387]  [<ffffffff8105891f>] ? warn_slowpath_fmt+0x4f/0x60
[  661.147580]  [<ffffffffc03650af>] ? iwl_poll_bit+0x2f/0x70 [iwlwifi]
[  661.147785]  [<ffffffffc0373770>] ? iwl_trans_pcie_grab_nic_access+0x110/0x120 [iwlwifi]
[  661.148045]  [<ffffffffc0371cf7>] ? iwl_trans_pcie_read_mem+0x27/0x90 [iwlwifi]
[  661.148280]  [<ffffffffc036d7d0>] ? iwl_pcie_txq_stuck_timer+0xd0/0x380 [iwlwifi]
[  661.148521]  [<ffffffff8108a438>] ? task_tick_fair+0x4b8/0x920
[  661.148712]  [<ffffffff811311df>] ? perf_event_task_tick+0x6f/0x230
[  661.148915]  [<ffffffffc036d700>] ? iwl_pcie_txq_unmap+0x160/0x160 [iwlwifi]
[  661.149142]  [<ffffffff810b93d0>] ? call_timer_fn+0x30/0x150
[  661.149325]  [<ffffffffc036d700>] ? iwl_pcie_txq_unmap+0x160/0x160 [iwlwifi]
[  661.149552]  [<ffffffff810b99d3>] ? run_timer_softirq+0x223/0x2d0
[  661.149750]  [<ffffffff815ebd9d>] ? __do_softirq+0xdd/0x2c4
[  661.149931]  [<ffffffff8105e195>] ? irq_exit+0x85/0x90
[  661.150098]  [<ffffffff815ebb9e>] ? smp_apic_timer_interrupt+0x3e/0x50
[  661.150308]  [<ffffffff815ea132>] ? apic_timer_interrupt+0x82/0x90
[  661.150507]  <EOI> 
[  661.150573] ---[ end trace 9159ae5cde33d1c4 ]---
[  661.150786] iwl data: 00000000: df 11 13 81 ff ff ff ff ae 0f 0c 81 00 00 00 00  ................
[  661.168775] iwlwifi 0000:02:00.0: FH TRBs(0) = 0x5a5a5a5a
[  661.186643] iwlwifi 0000:02:00.0: FH TRBs(1) = 0x5a5a5a5a
[  661.204498] iwlwifi 0000:02:00.0: FH TRBs(2) = 0x5a5a5a5a
[  661.222649] iwlwifi 0000:02:00.0: FH TRBs(3) = 0x5a5a5a5a
[  661.240715] iwlwifi 0000:02:00.0: FH TRBs(4) = 0x5a5a5a5a
[  661.258767] iwlwifi 0000:02:00.0: FH TRBs(5) = 0x5a5a5a5a
[  661.276772] iwlwifi 0000:02:00.0: FH TRBs(6) = 0x5a5a5a5a
[  661.294687] iwlwifi 0000:02:00.0: FH TRBs(7) = 0x5a5a5a5a
[  661.330307] ------------[ cut here ]------------
[  661.330461] WARNING: CPU: 1 PID: 2485 at drivers/net/wireless/intel/iwlwifi/iwl-trans.h:1161 iwl_pcie_txq_stuck_timer+0x2b2/0x380 [iwlwifi]
[  661.330861] Modules linked in: msr hid_generic arc4 kvm_amd kvm irqbypass crct10dif_pclmul crc32_pclmul iwlmvm crc32c_intel mac80211 jitterentropy_rng sha256_generic hmac acpi_cpufreq tpm_infineon drbg amdgpu iwlwifi aesni_intel snd_hda_codec_conexant aes_x86_64 glue_helper lrw snd_hda_codec_generic gf128mul snd_hda_codec_hdmi ablk_helper cryptd psmouse snd_hda_intel evdev joydev input_leds cfg80211 snd_hda_codec serio_raw pcspkr snd_hwdep snd_hda_core tg3 snd_pcm fam15h_power ptp edac_core pps_core xhci_pci k10temp snd_timer ttm xhci_hcd libphy ehci_pci snd ehci_hcd i2c_piix4 sg soundcore battery tpm_tis tpm video processor ac button sd_mod thermal
[  661.333137] CPU: 1 PID: 2485 Comm: iceweasel Tainted: G        W       4.6.0-rc2+ #1
[  661.333425] Hardware name: HP HP EliteBook 745 G3/807E, BIOS N73 Ver. 01.08 01/28/2016
[  661.333681]  0000000000000000 ffffffff812d9e79 0000000000000000 0000000000000000
[  661.333943]  ffffffff810588ac 0000000000000000 000000000080f0c0 ffff880424740218
[  661.334206]  ffff880424740000 0000000000a02e34 00000000000007e0 ffffffffc036d9b2
[  661.334468] Call Trace:
[  661.334551]  <IRQ>  [<ffffffff812d9e79>] ? dump_stack+0x5c/0x83
[  661.334751]  [<ffffffff810588ac>] ? __warn+0xec/0x110
[  661.334918]  [<ffffffffc036d9b2>] ? iwl_pcie_txq_stuck_timer+0x2b2/0x380 [iwlwifi]
[  661.335164]  [<ffffffff811311df>] ? perf_event_task_tick+0x6f/0x230
[  661.335368]  [<ffffffffc036d700>] ? iwl_pcie_txq_unmap+0x160/0x160 [iwlwifi]
[  661.335597]  [<ffffffff810b93d0>] ? call_timer_fn+0x30/0x150
[  661.335782]  [<ffffffffc036d700>] ? iwl_pcie_txq_unmap+0x160/0x160 [iwlwifi]
[  661.336011]  [<ffffffff810b99d3>] ? run_timer_softirq+0x223/0x2d0
[  661.336210]  [<ffffffff815ebd9d>] ? __do_softirq+0xdd/0x2c4
[  661.336392]  [<ffffffff8105e195>] ? irq_exit+0x85/0x90
[  661.336562]  [<ffffffff815ebb9e>] ? smp_apic_timer_interrupt+0x3e/0x50
[  661.336775]  [<ffffffff815ea132>] ? apic_timer_interrupt+0x82/0x90
[  661.336976]  <EOI> 
[  661.337086] ---[ end trace 9159ae5cde33d1c5 ]---
[  661.372860] iwlwifi 0000:02:00.0: Q 0 is active and mapped to fifo 2 ra_tid 0xa5a5 [90,1515870810]
[  661.408857] ------------[ cut here ]------------
[  661.409014] WARNING: CPU: 1 PID: 2485 at drivers/net/wireless/intel/iwlwifi/iwl-trans.h:1161 iwl_pcie_txq_stuck_timer+0x2b2/0x380 [iwlwifi]
[  661.409420] Modules linked in: msr hid_generic arc4 kvm_amd kvm irqbypass crct10dif_pclmul crc32_pclmul iwlmvm crc32c_intel mac80211 jitterentropy_rng sha256_generic hmac acpi_cpufreq tpm_infineon drbg amdgpu iwlwifi aesni_intel snd_hda_codec_conexant aes_x86_64 glue_helper lrw snd_hda_codec_generic gf128mul snd_hda_codec_hdmi ablk_helper cryptd psmouse snd_hda_intel evdev joydev input_leds cfg80211 snd_hda_codec serio_raw pcspkr snd_hwdep snd_hda_core tg3 snd_pcm fam15h_power ptp edac_core pps_core xhci_pci k10temp snd_timer ttm xhci_hcd libphy ehci_pci snd ehci_hcd i2c_piix4 sg soundcore battery tpm_tis tpm video processor ac button sd_mod thermal
[  661.411677] CPU: 1 PID: 2485 Comm: iceweasel Tainted: G        W       4.6.0-rc2+ #1
[  661.411930] Hardware name: HP HP EliteBook 745 G3/807E, BIOS N73 Ver. 01.08 01/28/2016
[  661.412189]  0000000000000000 ffffffff812d9e79 0000000000000000 0000000000000000
[  661.412455]  ffffffff810588ac 0000000000000001 000000005a5a5a5a ffff880424740218
[  661.412722]  ffff880424740000 0000000000a02e38 00000000000007e2 ffffffffc036d9b2
[  661.412988] Call Trace:
[  661.413075]  <IRQ>  [<ffffffff812d9e79>] ? dump_stack+0x5c/0x83
[  661.413279]  [<ffffffff810588ac>] ? __warn+0xec/0x110
[  661.413448]  [<ffffffffc036d9b2>] ? iwl_pcie_txq_stuck_timer+0x2b2/0x380 [iwlwifi]
[  661.413697]  [<ffffffff811311df>] ? perf_event_task_tick+0x6f/0x230
[  661.413905]  [<ffffffffc036d700>] ? iwl_pcie_txq_unmap+0x160/0x160 [iwlwifi]
[  661.414137]  [<ffffffff810b93d0>] ? call_timer_fn+0x30/0x150
[  661.414325]  [<ffffffffc036d700>] ? iwl_pcie_txq_unmap+0x160/0x160 [iwlwifi]
[  661.414557]  [<ffffffff810b99d3>] ? run_timer_softirq+0x223/0x2d0
[  661.414759]  [<ffffffff815ebd9d>] ? __do_softirq+0xdd/0x2c4
[  661.414944]  [<ffffffff8105e195>] ? irq_exit+0x85/0x90
[  661.415115]  [<ffffffff815ebb9e>] ? smp_apic_timer_interrupt+0x3e/0x50
[  661.415330]  [<ffffffff815ea132>] ? apic_timer_interrupt+0x82/0x90
[  661.415534]  <EOI> 
[  661.415621] ---[ end trace 9159ae5cde33d1c6 ]---
[  661.451288] iwlwifi 0000:02:00.0: Q 1 is active and mapped to fifo 2 ra_tid 0xa5a5 [90,1515870810]
[  661.487025] ------------[ cut here ]------------
[  661.487186] WARNING: CPU: 1 PID: 2485 at drivers/net/wireless/intel/iwlwifi/iwl-trans.h:1161 iwl_pcie_txq_stuck_timer+0x2b2/0x380 [iwlwifi]
[  661.487591] Modules linked in: msr hid_generic arc4 kvm_amd kvm irqbypass crct10dif_pclmul crc32_pclmul iwlmvm crc32c_intel mac80211 jitterentropy_rng sha256_generic hmac acpi_cpufreq tpm_infineon drbg amdgpu iwlwifi aesni_intel snd_hda_codec_conexant aes_x86_64 glue_helper lrw snd_hda_codec_generic gf128mul snd_hda_codec_hdmi ablk_helper cryptd psmouse snd_hda_intel evdev joydev input_leds cfg80211 snd_hda_codec serio_raw pcspkr snd_hwdep snd_hda_core tg3 snd_pcm fam15h_power ptp edac_core pps_core xhci_pci k10temp snd_timer ttm xhci_hcd libphy ehci_pci snd ehci_hcd i2c_piix4 sg soundcore battery tpm_tis tpm video processor ac button sd_mod thermal
[  661.489848] CPU: 1 PID: 2485 Comm: iceweasel Tainted: G        W       4.6.0-rc2+ #1
[  661.490102] Hardware name: HP HP EliteBook 745 G3/807E, BIOS N73 Ver. 01.08 01/28/2016
[  661.490360]  0000000000000000 ffffffff812d9e79 0000000000000000 0000000000000000
[  661.490626]  ffffffff810588ac 0000000000000002 000000005a5a5a5a ffff880424740218
[  661.490892]  ffff880424740000 0000000000a02e3c 00000000000007e4 ffffffffc036d9b2
[  661.491157] Call Trace:
[  661.491241]  <IRQ>  [<ffffffff812d9e79>] ? dump_stack+0x5c/0x83
[  661.491444]  [<ffffffff810588ac>] ? __warn+0xec/0x110
[  661.491614]  [<ffffffffc036d9b2>] ? iwl_pcie_txq_stuck_timer+0x2b2/0x380 [iwlwifi]
[  661.491863]  [<ffffffff811311df>] ? perf_event_task_tick+0x6f/0x230
[  661.492071]  [<ffffffffc036d700>] ? iwl_pcie_txq_unmap+0x160/0x160 [iwlwifi]
[  661.492303]  [<ffffffff810b93d0>] ? call_timer_fn+0x30/0x150
[  661.492491]  [<ffffffffc036d700>] ? iwl_pcie_txq_unmap+0x160/0x160 [iwlwifi]
[  661.492724]  [<ffffffff810b99d3>] ? run_timer_softirq+0x223/0x2d0
[  661.492927]  [<ffffffff815ebd9d>] ? __do_softirq+0xdd/0x2c4
[  661.493111]  [<ffffffff8105e195>] ? irq_exit+0x85/0x90
[  661.493286]  [<ffffffff815ebb9e>] ? smp_apic_timer_interrupt+0x3e/0x50
[  661.493501]  [<ffffffff815ea132>] ? apic_timer_interrupt+0x82/0x90
[  661.493704]  <EOI> 
[  661.493791] ---[ end trace 9159ae5cde33d1c7 ]---
[  661.529378] iwlwifi 0000:02:00.0: Q 2 is active and mapped to fifo 2 ra_tid 0xa5a5 [90,1515870810]
[  661.565101] ------------[ cut here ]------------
[  661.565257] WARNING: CPU: 1 PID: 2485 at drivers/net/wireless/intel/iwlwifi/iwl-trans.h:1161 iwl_pcie_txq_stuck_timer+0x2b2/0x380 [iwlwifi]
[  661.565662] Modules linked in: msr hid_generic arc4 kvm_amd kvm irqbypass crct10dif_pclmul crc32_pclmul iwlmvm crc32c_intel mac80211 jitterentropy_rng sha256_generic hmac acpi_cpufreq tpm_infineon drbg amdgpu iwlwifi aesni_intel snd_hda_codec_conexant aes_x86_64 glue_helper lrw snd_hda_codec_generic gf128mul snd_hda_codec_hdmi ablk_helper cryptd psmouse snd_hda_intel evdev joydev input_leds cfg80211 snd_hda_codec serio_raw pcspkr snd_hwdep snd_hda_core tg3 snd_pcm fam15h_power ptp edac_core pps_core xhci_pci k10temp snd_timer ttm xhci_hcd libphy ehci_pci snd ehci_hcd i2c_piix4 sg soundcore battery tpm_tis tpm video processor ac button sd_mod thermal
[  661.567910] CPU: 1 PID: 2485 Comm: iceweasel Tainted: G        W       4.6.0-rc2+ #1
[  661.568163] Hardware name: HP HP EliteBook 745 G3/807E, BIOS N73 Ver. 01.08 01/28/2016
[  661.568422]  0000000000000000 ffffffff812d9e79 0000000000000000 0000000000000000
[  661.568690]  ffffffff810588ac 0000000000000003 000000005a5a5a5a ffff880424740218
[  661.568956]  ffff880424740000 0000000000a02e40 00000000000007e6 ffffffffc036d9b2
[  661.569221] Call Trace:
[  661.569306]  <IRQ>  [<ffffffff812d9e79>] ? dump_stack+0x5c/0x83
[  661.569508]  [<ffffffff810588ac>] ? __warn+0xec/0x110
[  661.569678]  [<ffffffffc036d9b2>] ? iwl_pcie_txq_stuck_timer+0x2b2/0x380 [iwlwifi]
[  661.569927]  [<ffffffff811311df>] ? perf_event_task_tick+0x6f/0x230
[  661.570136]  [<ffffffffc036d700>] ? iwl_pcie_txq_unmap+0x160/0x160 [iwlwifi]
[  661.570370]  [<ffffffff810b93d0>] ? call_timer_fn+0x30/0x150
[  661.570562]  [<ffffffffc036d700>] ? iwl_pcie_txq_unmap+0x160/0x160 [iwlwifi]
[  661.570793]  [<ffffffff810b99d3>] ? run_timer_softirq+0x223/0x2d0
[  661.570996]  [<ffffffff815ebd9d>] ? __do_softirq+0xdd/0x2c4
[  661.571180]  [<ffffffff8105e195>] ? irq_exit+0x85/0x90
[  661.571352]  [<ffffffff815ebb9e>] ? smp_apic_timer_interrupt+0x3e/0x50
[  661.571567]  [<ffffffff815ea132>] ? apic_timer_interrupt+0x82/0x90
[  661.571770]  <EOI> 
[  661.571855] ---[ end trace 9159ae5cde33d1c8 ]---

...

[  663.717404] iwlwifi 0000:02:00.0: Q 30 is active and mapped to fifo 2 ra_tid 0xa5a5 [90,1515870810]
[  696.349979] iwlwifi 0000:02:00.0: Failed to wake NIC for hcmd
[  696.350314] iwlwifi 0000:02:00.0: Error sending STATISTICS_CMD: enqueue_hcmd failed: -5
[  696.368395] iwlwifi 0000:02:00.0: Failed to wake NIC for hcmd
[  696.368655] iwlwifi 0000:02:00.0: Error sending STATISTICS_CMD: enqueue_hcmd failed: -5
[  719.417826] iwlwifi 0000:02:00.0: Failed to wake NIC for hcmd
[  719.418110] iwlwifi 0000:02:00.0: Error sending STATISTICS_CMD: enqueue_hcmd failed: -5
[  719.436495] iwlwifi 0000:02:00.0: Failed to wake NIC for hcmd
[  719.436765] iwlwifi 0000:02:00.0: Error sending STATISTICS_CMD: enqueue_hcmd failed: -5
[  732.474561] iwlwifi 0000:02:00.0: Failed to wake NIC for hcmd
[  732.474892] iwlwifi 0000:02:00.0: Error sending STATISTICS_CMD: enqueue_hcmd failed: -5
[  732.492952] iwlwifi 0000:02:00.0: Failed to wake NIC for hcmd
[  732.493163] iwlwifi 0000:02:00.0: Error sending STATISTICS_CMD: enqueue_hcmd failed: -5
[  745.528645] iwlwifi 0000:02:00.0: Failed to wake NIC for hcmd
[  745.528908] iwlwifi 0000:02:00.0: Error sending STATISTICS_CMD: enqueue_hcmd failed: -5
[  745.547015] iwlwifi 0000:02:00.0: Failed to wake NIC for hcmd
[  745.547259] iwlwifi 0000:02:00.0: Error sending STATISTICS_CMD: enqueue_hcmd failed: -5
[  758.581935] iwlwifi 0000:02:00.0: Failed to wake NIC for hcmd
[  758.582190] iwlwifi 0000:02:00.0: Error sending STATISTICS_CMD: enqueue_hcmd failed: -5
[  758.600251] iwlwifi 0000:02:00.0: Failed to wake NIC for hcmd
[  758.600480] iwlwifi 0000:02:00.0: Error sending STATISTICS_CMD: enqueue_hcmd failed: -5
[  771.635874] iwlwifi 0000:02:00.0: Failed to wake NIC for hcmd
[  771.636135] iwlwifi 0000:02:00.0: Error sending STATISTICS_CMD: enqueue_hcmd failed: -5
[  771.654359] iwlwifi 0000:02:00.0: Failed to wake NIC for hcmd
[  771.654617] iwlwifi 0000:02:00.0: Error sending STATISTICS_CMD: enqueue_hcmd failed: -5
[  784.689656] iwlwifi 0000:02:00.0: Failed to wake NIC for hcmd
[  784.689950] iwlwifi 0000:02:00.0: Error sending STATISTICS_CMD: enqueue_hcmd failed: -5
[  784.707989] iwlwifi 0000:02:00.0: Failed to wake NIC for hcmd
[  784.708199] iwlwifi 0000:02:00.0: Error sending STATISTICS_CMD: enqueue_hcmd failed: -5
[  797.748413] iwlwifi 0000:02:00.0: Failed to wake NIC for hcmd
[  797.748739] iwlwifi 0000:02:00.0: Error sending STATISTICS_CMD: enqueue_hcmd failed: -5
[  797.766851] iwlwifi 0000:02:00.0: Failed to wake NIC for hcmd
[  797.767089] iwlwifi 0000:02:00.0: Error sending STATISTICS_CMD: enqueue_hcmd failed: -5
[  810.806073] iwlwifi 0000:02:00.0: Failed to wake NIC for hcmd
[  810.806395] iwlwifi 0000:02:00.0: Error sending STATISTICS_CMD: enqueue_hcmd failed: -5
[  810.824452] iwlwifi 0000:02:00.0: Failed to wake NIC for hcmd
[  810.824677] iwlwifi 0000:02:00.0: Error sending STATISTICS_CMD: enqueue_hcmd failed: -5

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply. Srsly.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
