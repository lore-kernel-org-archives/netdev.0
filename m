From: Scot Doyle <lkml@scotdoyle.com>
Subject: Kernel panic when using bridge
Date: Thu, 07 Apr 2011 20:20:25 -0500
Message-ID: <4D9E62D9.5010400@scotdoyle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.scotdoyle.com ([74.207.249.244]:39926 "EHLO
	smtp.scotdoyle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757258Ab1DHBbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 21:31:04 -0400
Received: from [10.111.1.2] (97-85-151-118.static.stls.mo.charter.com [97.85.151.118])
	by smtp.scotdoyle.com (Postfix) with ESMTPSA id CD5268C4B
	for <netdev@vger.kernel.org>; Fri,  8 Apr 2011 01:20:26 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This kernel panic occurs when using a bridge. I would be grateful for 
any ideas on how to correct it.

The panic was captured on two servers after three or four days of 
minimal use, both configured as follows:
- unpatched kernel 2.6.39-rc1 (commit 
ecb78ab6f30106ab72a575a25b1cdfd1633b7ca2) with default .config options
- br0 on single intel igb NIC (3 other NIC's unused)
- br0 with ip address on distinct /27 subnet
- br0:1 with ip address on distinct /24 subnet
- br0:2 with ip address on distinct /24 subnet
- no iptables rules
- ebtables not installed

"net/bridge/br_netfilter.c" and "net/ipv4/ip_options.c" (in the current 
2.6.39-rc2 and in net-next-2.6) are identical to the versions used to 
build this kernel.



---------

Server #1

[333271.168869] BUG: unable to handle kernel NULL pointer dereference at 
00000000000000cc
[333271.176790] IP: [<ffffffff8129fb09>] ip_options_compile+0x1c1/0x435
[333271.183142] PGD 0
[333271.185242] Oops: 0000 [#1] SMP
[333271.188564] last sysfs file: /sys/devices/virtual/net/lo/operstate
[333271.194817] CPU 0
[333271.196734] Modules linked in: tun kvm_intel kvm bridge stp loop 
snd_pcm snd_timer snd soundcore snd_page_alloc i7core_edac tpm_tis 
psmouse evdev tpm dcdbas edac_core pcspkr serio_raw processor tpm_bios 
thermal_sys ghes power_meter hed button ext2 mbcache dm_mod raid1 md_mod 
sd_mod crc_t10dif usb_storage uas uhci_hcd mpt2sas igb 
scsi_transport_sas ehci_hcd raid_class scsi_mod dca usbcore bnx2 [last 
unloaded: scsi_wait_scan]
[333271.234890]
[333271.236460] Pid: 0, comm: swapper Not tainted 2.6.39-rc1+ #2 Dell 
Inc. PowerEdge R510/0DPRKF
[333271.244991] RIP: 0010:[<ffffffff8129fb09>]  [<ffffffff8129fb09>] 
ip_options_compile+0x1c1/0x435
[333271.253766] RSP: 0018:ffff88042f203af0  EFLAGS: 00010286
[333271.259150] RAX: 000000000000001c RBX: ffff8804055d9500 RCX: 
ffff880413a5f865
[333271.266354] RDX: 000000000000001f RSI: 0000000000000000 RDI: 
ffffffff817e6180
[333271.273558] RBP: ffff880413a5f863 R08: ffffffffa01f5e89 R09: 
ffff88042f203c58
[333271.280762] R10: 00000000006f53aa R11: 0000000000000293 R12: 
ffff8804055d9528
[333271.287967] R13: 0000000000000027 R14: ffff880413a5f84e R15: 
0000000000000027
[333271.295171] FS:  0000000000000000(0000) GS:ffff88042f200000(0000) 
knlGS:0000000000000000
[333271.303330] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[333271.309148] CR2: 00000000000000cc CR3: 0000000001603000 CR4: 
00000000000026e0
[333271.316353] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[333271.323557] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[333271.330763] Process swapper (pid: 0, threadinfo ffffffff81600000, 
task ffffffff8160b020)
[333271.338920] Stack:
[333271.341011]  0000000000000286 ffff88041c870e00 0000000000000000 
ffffffff817e6180
[333271.348514]  0000000000000282 ffffffff810ec7a8 0000000000000282 
ffff8804055d9528
[333271.356014]  ffff8804055d9500 ffff880404188000 ffff880413a5f84e 
ffff880404188000
[333271.363515] Call Trace:
[333271.366038]  <IRQ>
[333271.368226]  [<ffffffff810ec7a8>] ? __slab_free+0x28/0x14a
[333271.373789]  [<ffffffffa01f9e3a>] ? br_parse_ip_options+0x133/0x1a0 
[bridge]
[333271.380910]  [<ffffffffa01fabd8>] ? br_nf_pre_routing+0x348/0x3cb 
[bridge]
[333271.387856]  [<ffffffff81037106>] ? check_preempt_curr+0x38/0x61
[333271.393934]  [<ffffffff81033dc0>] ? arch_local_irq_save+0x12/0x1b
[333271.400101]  [<ffffffff81298493>] ? nf_iterate+0x41/0x7e
[333271.405490]  [<ffffffff8103eb9c>] ? try_to_wake_up+0x16a/0x17c
[333271.411396]  [<ffffffffa01f5e89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[333271.417997]  [<ffffffffa01f5e89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[333271.424595]  [<ffffffff81298543>] ? nf_hook_slow+0x73/0x114
[333271.430242]  [<ffffffffa01f5e89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[333271.436843]  [<ffffffff811042c0>] ? pollwake+0x49/0x4e
[333271.442056]  [<ffffffffa01f5e89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[333271.448657]  [<ffffffffa01f5e6f>] ? NF_HOOK.clone.4+0x3c/0x56 [bridge]
[333271.455257]  [<ffffffffa01f61e5>] ? br_handle_frame+0x195/0x1ac [bridge]
[333271.462029]  [<ffffffffa01f6050>] ? 
br_handle_frame_finish+0x1c7/0x1c7 [bridge]
[333271.469410]  [<ffffffff8127646f>] ? __netif_receive_skb+0x2a7/0x450
[333271.475749]  [<ffffffff81033dc0>] ? arch_local_irq_save+0x12/0x1b
[333271.481914]  [<ffffffff81276893>] ? netif_receive_skb+0x52/0x58
[333271.487906]  [<ffffffff81276d95>] ? napi_gro_receive+0x1f/0x2f
[333271.493812]  [<ffffffff8127696a>] ? napi_skb_finish+0x1c/0x31
[333271.499634]  [<ffffffffa022afcd>] ? igb_poll+0x6d9/0x9ee [igb]
[333271.505539]  [<ffffffff8103ebae>] ? try_to_wake_up+0x17c/0x17c
[333271.511444]  [<ffffffff81034724>] ? __wake_up_common+0x41/0x78
[333271.517350]  [<ffffffff81276ec0>] ? net_rx_action+0xa4/0x1b1
[333271.523084]  [<ffffffff8104ad0a>] ? __do_softirq+0xb8/0x176
[333271.528731]  [<ffffffff8106a80f>] ? tick_dev_program_event+0x2f/0xec
[333271.535158]  [<ffffffff81333a1c>] ? call_softirq+0x1c/0x30
[333271.540717]  [<ffffffff8100aa57>] ? do_softirq+0x3f/0x84
[333271.546103]  [<ffffffff8104af75>] ? irq_exit+0x3f/0x8f
[333271.551317]  [<ffffffff8100a793>] ? do_IRQ+0x85/0x9e
[333271.556356]  [<ffffffff8132c993>] ? common_interrupt+0x13/0x13
[333271.562259]  <EOI>
[333271.564447]  [<ffffffff8106132c>] ? enqueue_hrtimer+0x3f/0x53
[333271.570268]  [<ffffffffa0307417>] ? arch_local_irq_enable+0x7/0x8 
[processor]
[333271.577476]  [<ffffffffa0307fdf>] ? acpi_idle_enter_bm+0x218/0x250 
[processor]
[333271.584771]  [<ffffffff8125ded9>] ? menu_select+0x169/0x296
[333271.590416]  [<ffffffff8125cfe9>] ? cpuidle_idle_call+0xf4/0x17e
[333271.596495]  [<ffffffff81008298>] ? cpu_idle+0xa2/0xc4
[333271.601709]  [<ffffffff8169db60>] ? start_kernel+0x3b9/0x3c4
[333271.607441]  [<ffffffff8169d3c6>] ? x86_64_start_kernel+0x102/0x10f
[333271.613779] Code: 4d 02 3c 03 0f 86 59 02 00 00 0f b6 d0 44 39 ea 7f 
32 83 c2 03 44 39 ea 0f 8f 45 02 00 00 48 85 db 74 18 48 8b 74 24 10 0f 
b6 c0 <8b> 96 cc 00 00 00 89 54 05 ff 41 80 4c 24 08 04 80 01 04 41 80
[333271.633283] RIP  [<ffffffff8129fb09>] ip_options_compile+0x1c1/0x435
[333271.639717]  RSP <ffff88042f203af0>
[333271.643280] CR2: 00000000000000cc
[333271.646992] ---[ end trace 1e328ecef856727a ]---
[333271.651683] BUG: scheduling while atomic: swapper/0/0x10000100
[333271.657586] Modules linked in: tun kvm_intel kvm bridge stp loop 
snd_pcm snd_timer snd soundcore snd_page_alloc i7core_edac tpm_tis 
psmouse evdev tpm dcdbas edac_core pcspkr serio_raw processor tpm_bios 
thermal_sys ghes power_meter hed button ext2 mbcache dm_mod raid1 md_mod 
sd_mod crc_t10dif usb_storage uas uhci_hcd mpt2sas igb 
scsi_transport_sas ehci_hcd raid_class scsi_mod dca usbcore bnx2 [last 
unloaded: scsi_wait_scan]
[333271.695561] CPU 0
[333271.697479] Modules linked in: tun kvm_intel kvm bridge stp loop 
snd_pcm snd_timer snd soundcore snd_page_alloc i7core_edac tpm_tis 
psmouse evdev tpm dcdbas edac_core pcspkr serio_raw processor tpm_bios 
thermal_sys ghes power_meter hed button ext2 mbcache dm_mod raid1 md_mod 
sd_mod crc_t10dif usb_storage uas uhci_hcd mpt2sas igb 
scsi_transport_sas ehci_hcd raid_class scsi_mod dca usbcore bnx2 [last 
unloaded: scsi_wait_scan]
[333271.735643]
[333271.737215] Pid: 0, comm: swapper Tainted: G      D     2.6.39-rc1+ 
#2 Dell Inc. PowerEdge R510/0DPRKF
[333271.746614] RIP: 0010:[<ffffffffa0307417>]  [<ffffffffa0307417>] 
arch_local_irq_enable+0x7/0x8 [processor]
[333271.756345] RSP: 0018:ffffffff81601eb0  EFLAGS: 00000292
[333271.761729] RAX: 00000000000001a8 RBX: ffffffff8106132c RCX: 
00000000000003e8
[333271.768932] RDX: 000000000000020a RSI: 0000000225c17d03 RDI: 
0000000000067a4a
[333271.776136] RBP: ffff88040450e000 R08: 00000000fffffffd R09: 
0000000002625a00
[333271.783340] R10: 00000000006f53aa R11: 0000000000000293 R12: 
ffffffff8132c98e
[333271.790546] R13: ffff88042f20feb0 R14: ffffffff811a2ede R15: 
ffff88042f20fdc8
[333271.797750] FS:  0000000000000000(0000) GS:ffff88042f200000(0000) 
knlGS:0000000000000000
[333271.805907] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[333271.811726] CR2: 00000000000000cc CR3: 0000000001603000 CR4: 
00000000000026e0
[333271.818930] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[333271.826134] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[333271.833340] Process swapper (pid: 0, threadinfo ffffffff81600000, 
task ffffffff8160b020)
[333271.841498] Stack:
[333271.843589]  ffffffffa0307fdf 0000000000011140 ffffffff8125ded9 
0000000104f6235d
[333271.851087]  ffff88040450e020 ffff88040450e0f0 0000000000000002 
ffffffffffffffff
[333271.858585]  ffffffff8125cfe9 0000000000000000 ffffffff81600000 
ffffffff816812d0
[333271.866082] Call Trace:
[333271.868607]  [<ffffffffa0307fdf>] ? acpi_idle_enter_bm+0x218/0x250 
[processor]
[333271.875901]  [<ffffffff8125ded9>] ? menu_select+0x169/0x296
[333271.881548]  [<ffffffff8125cfe9>] ? cpuidle_idle_call+0xf4/0x17e
[333271.887627]  [<ffffffff81008298>] ? cpu_idle+0xa2/0xc4
[333271.892839]  [<ffffffff8169db60>] ? start_kernel+0x3b9/0x3c4
[333271.898572]  [<ffffffff8169d3c6>] ? x86_64_start_kernel+0x102/0x10f
[333271.904910] Code: 63 1c fb 48 83 c4 38 89 e8 5b 5d 41 5c 41 5d 41 5e 
41 5f c3 0f 09 0f 1f 44 00 00 c3 fa 66 0f 1f 44 00 00 c3 fb 66 0f 1f 44 
00 00 <c3> 48 8b 15 81 70 41 e1 48 8d 42 fd 48 83 f8 01 0f 96 c0 48 ff
[333271.924428] Call Trace:
[333271.926954]  [<ffffffffa0307fdf>] ? acpi_idle_enter_bm+0x218/0x250 
[processor]
[333271.934247]  [<ffffffff8125ded9>] ? menu_select+0x169/0x296
[333271.939893]  [<ffffffff8125cfe9>] ? cpuidle_idle_call+0xf4/0x17e
[333271.945973]  [<ffffffff81008298>] ? cpu_idle+0xa2/0xc4
[333271.951184]  [<ffffffff8169db60>] ? start_kernel+0x3b9/0x3c4
[333271.956915]  [<ffffffff8169d3c6>] ? x86_64_start_kernel+0x102/0x10f
[333271.963513] BUG: unable to handle kernel NULL pointer dereference at 
00000000000000e0
[333271.971428] IP: [<ffffffffa022aca8>] igb_poll+0x3b4/0x9ee [igb]
[333271.977431] PGD 40402d067 PUD 40357f067 PMD 0
[333271.981977] Oops: 0000 [#2] SMP
[333271.985298] last sysfs file: /sys/devices/virtual/net/lo/operstate
[333271.991550] CPU 0
[333271.993467] Modules linked in: tun kvm_intel kvm bridge stp loop 
snd_pcm snd_timer snd soundcore snd_page_alloc i7core_edac tpm_tis 
psmouse evdev tpm dcdbas edac_core pcspkr serio_raw processor tpm_bios 
thermal_sys ghes power_meter hed button ext2 mbcache dm_mod raid1 md_mod 
sd_mod crc_t10dif usb_storage uas uhci_hcd mpt2sas igb 
scsi_transport_sas ehci_hcd raid_class scsi_mod dca usbcore bnx2 [last 
unloaded: scsi_wait_scan]
[333272.031622]
[333272.033193] Pid: 2453, comm: kvm Tainted: G      D     2.6.39-rc1+ 
#2 Dell Inc. PowerEdge R510/0DPRKF
[333272.042504] RIP: 0010:[<ffffffffa022aca8>]  [<ffffffffa022aca8>] 
igb_poll+0x3b4/0x9ee [igb]
[333272.050933] RSP: 0000:ffff88041d87dd70  EFLAGS: 00010203
[333272.056317] RAX: ffff880401d6b458 RBX: ffff880405017080 RCX: 
0000000000000000
[333272.063523] RDX: 0000000000000040 RSI: 0000000000001043 RDI: 
ffff880401d6b458
[333272.070726] RBP: 0000000000000000 R08: 00000000ffffffff R09: 
00000000000515cb
[333272.077930] R10: 0000000000000001 R11: 0000000000000202 R12: 
0000000000000078
[333272.085135] R13: ffffc900126a2208 R14: 0000000000000000 R15: 
ffff8804052f50d0
[333272.092342] FS:  00007ff18dd67760(0000) GS:ffff88042f200000(0000) 
knlGS:0000000000000000
[333272.100499] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[333272.106316] CR2: 00000000000000e0 CR3: 0000000403352000 CR4: 
00000000000026e0
[333272.113522] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[333272.120726] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[333272.127930] Process kvm (pid: 2453, threadinfo ffff88041d87c000, 
task ffff8804101d1410)
[333272.135999] Stack:
[333272.138090]  ffffffff81103f65 00007fff22fa90c0 00007fff22fa9140 
000000000000000e
[333272.145589]  ffffffff81053896 ffff8804052fb740 0000000000000000 
00001043101d1410
[333272.153090]  000000010000000e ffff880401d6b440 ffff880400000000 
ffff880404188740
[333272.160592] Call Trace:
[333272.163118]  [<ffffffff81103f65>] ? set_fd_set+0x31/0x38
[333272.168504]  [<ffffffff81053896>] ? __dequeue_signal+0x15/0x10a
[333272.174498]  [<ffffffff81054b96>] ? send_sigqueue+0xd8/0xec
[333272.180145]  [<ffffffff81276ec0>] ? net_rx_action+0xa4/0x1b1
[333272.185878]  [<ffffffff8105d673>] ? posix_timer_event+0x33/0x3d
[333272.191871]  [<ffffffff810657f4>] ? timekeeping_get_ns+0xe/0x2e
[333272.197863]  [<ffffffff8104ad0a>] ? __do_softirq+0xb8/0x176
[333272.203508]  [<ffffffff81333a1c>] ? call_softirq+0x1c/0x30
[333272.209066]  [<ffffffff8100aa57>] ? do_softirq+0x3f/0x84
[333272.214451]  [<ffffffff8104af75>] ? irq_exit+0x3f/0x8f
[333272.219664]  [<ffffffff8101f280>] ? smp_apic_timer_interrupt+0x78/0x88
[333272.226263]  [<ffffffff813331d3>] ? apic_timer_interrupt+0x13/0x20
[333272.232516]  [<ffffffff81332812>] ? system_call_fastpath+0x16/0x1b
[333272.238766] Code: 89 74 24 3c e9 78 03 00 00 8b 54 24 70 39 54 24 44 
0f 8d 75 03 00 00 ff 44 24 44 0f ae e8 49 8b 6d 00 ff 44 24 40 b9 00 00 
00 00
[333272.252256]  8b 85 e0 00 00 00 49 c7 45 00 00 00 00 00 41 8b 77 0c 
0f 18
[333272.259484] RIP  [<ffffffffa022aca8>] igb_poll+0x3b4/0x9ee [igb]
[333272.265575]  RSP <ffff88041d87dd70>
[333272.269138] CR2: 00000000000000e0
[333272.272529] ---[ end trace 1e328ecef856727b ]---
[333272.277223] Kernel panic - not syncing: Fatal exception in interrupt
[333272.283649] Pid: 2453, comm: kvm Tainted: G      D     2.6.39-rc1+ #2
[333272.290158] Call Trace:
[333272.292685]  [<ffffffff8132ab34>] ? panic+0x92/0x1a1
[333272.297725]  [<ffffffff8132d6f6>] ? oops_end+0xa9/0xb6
[333272.302940]  [<ffffffff8102ca16>] ? no_context+0x1ed/0x1fa
[333272.308499]  [<ffffffff8132f4e3>] ? do_page_fault+0x16b/0x308
[333272.314319]  [<ffffffff81104277>] ? __pollwait+0xd6/0xd6
[333272.319705]  [<ffffffff81104277>] ? __pollwait+0xd6/0xd6
[333272.325090]  [<ffffffff81104277>] ? __pollwait+0xd6/0xd6
[333272.330475]  [<ffffffff8132cc55>] ? page_fault+0x25/0x30
[333272.335863]  [<ffffffffa022aca8>] ? igb_poll+0x3b4/0x9ee [igb]
[333272.341768]  [<ffffffff81103f65>] ? set_fd_set+0x31/0x38
[333272.347154]  [<ffffffff81053896>] ? __dequeue_signal+0x15/0x10a
[333272.353147]  [<ffffffff81054b96>] ? send_sigqueue+0xd8/0xec
[333272.358795]  [<ffffffff81276ec0>] ? net_rx_action+0xa4/0x1b1
[333272.364527]  [<ffffffff8105d673>] ? posix_timer_event+0x33/0x3d
[333272.370520]  [<ffffffff810657f4>] ? timekeeping_get_ns+0xe/0x2e
[333272.376512]  [<ffffffff8104ad0a>] ? __do_softirq+0xb8/0x176
[333272.382158]  [<ffffffff81333a1c>] ? call_softirq+0x1c/0x30
[333272.387716]  [<ffffffff8100aa57>] ? do_softirq+0x3f/0x84
[333272.393102]  [<ffffffff8104af75>] ? irq_exit+0x3f/0x8f
[333272.398315]  [<ffffffff8101f280>] ? smp_apic_timer_interrupt+0x78/0x88
[333272.404915]  [<ffffffff813331d3>] ? apic_timer_interrupt+0x13/0x20
[333272.411167]  [<ffffffff81332812>] ? system_call_fastpath+0x16/0x1b



---------

Server #2

[401314.185779] BUG: unable to handle kernel NULL pointer dereference at 
00000000000000cc
[401314.193674] IP: [<ffffffff8129fb09>] ip_options_compile+0x1c1/0x435
[401314.200009] PGD 0
[401314.202101] Oops: 0000 [#1] SMP
[401314.205412] last sysfs file: 
/sys/devices/virtual/block/md127/md/mismatch_cnt
[401314.212597] CPU 0
[401314.214508] Modules linked in: kvm_intel kvm bridge stp loop tpm_tis 
snd_pcm tpm snd_timer snd soundcore psmouse snd_page_alloc ghes pcspkr 
tpm_bios i7core_edac se
rio_raw evdev processor dcdbas edac_core thermal_sys power_meter hed 
button ext2 mbcache dm_mod raid1 md_mod sd_mod crc_t10dif usb_storage 
uas uhci_hcd mpt2sas igb scs
i_transport_sas ehci_hcd raid_class scsi_mod usbcore bnx2 dca [last 
unloaded: scsi_wait_scan]
[401314.252204]
[401314.253769] Pid: 0, comm: swapper Not tainted 2.6.39-rc1+ #2 Dell 
Inc. PowerEdge R510/0DPRKF
[401314.262276] RIP: 0010:[<ffffffff8129fb09>]  [<ffffffff8129fb09>] 
ip_options_compile+0x1c1/0x435
[401314.271027] RSP: 0018:ffff88042f203af0  EFLAGS: 00010286
[401314.276398] RAX: 0000000000000024 RBX: ffff8804101d8d00 RCX: 
ffff88041db89065
[401314.283583] RDX: 0000000000000027 RSI: 0000000000000000 RDI: 
ffffffff817e6180
[401314.290768] RBP: ffff88041db89063 R08: ffffffffa0197e89 R09: 
ffff88042f203c58
[401314.297955] R10: ffff880404078340 R11: 0000000000000040 R12: 
ffff8804101d8d28
[401314.305140] R13: 0000000000000027 R14: ffff88041db8904e R15: 
0000000000000027
[401314.312324] FS:  0000000000000000(0000) GS:ffff88042f200000(0000) 
knlGS:0000000000000000
[401314.320459] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[401314.326261] CR2: 00000000000000cc CR3: 0000000001603000 CR4: 
00000000000006f0
[401314.333448] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[401314.340632] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[401314.347817] Process swapper (pid: 0, threadinfo ffffffff81600000, 
task ffffffff8160b020)
[401314.355951] Stack:
[401314.358034]  ffff88042ec02900 ffff8804051d8740 0000000000000000 
ffffffff817e6180
[401314.365514]  0000000000000282 ffffffff810ec7a8 0000000000000282 
ffff8804101d8d28
[401314.372992]  ffff8804101d8d00 ffff880404078000 ffff88041db8904e 
ffff880404078000
[401314.380471] Call Trace:
[401314.382988]  <IRQ>
[401314.385170]  [<ffffffff810ec7a8>] ? __slab_free+0x28/0x14a
[401314.390717]  [<ffffffffa019be3a>] ? br_parse_ip_options+0x133/0x1a0 
[bridge]
[401314.397817]  [<ffffffffa019cbd8>] ? br_nf_pre_routing+0x348/0x3cb 
[bridge]
[401314.404745]  [<ffffffff8119d89b>] ? cpumask_next_and+0x2b/0x3a
[401314.410635]  [<ffffffff81298493>] ? nf_iterate+0x41/0x7e
[401314.416007]  [<ffffffffa0197e89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[401314.422590]  [<ffffffffa0197e89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[401314.429171]  [<ffffffff81298543>] ? nf_hook_slow+0x73/0x114
[401314.434800]  [<ffffffffa0197e89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[401314.441383]  [<ffffffffa0197e89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[401314.447965]  [<ffffffffa0197e6f>] ? NF_HOOK.clone.4+0x3c/0x56 [bridge]
[401314.454548]  [<ffffffffa01981e5>] ? br_handle_frame+0x195/0x1ac [bridge]
[401314.461302]  [<ffffffffa0198050>] ? 
br_handle_frame_finish+0x1c7/0x1c7 [bridge]
[401314.468662]  [<ffffffff8127646f>] ? __netif_receive_skb+0x2a7/0x450
[401314.474985]  [<ffffffff81276893>] ? netif_receive_skb+0x52/0x58
[401314.480960]  [<ffffffff81276d95>] ? napi_gro_receive+0x1f/0x2f
[401314.486850]  [<ffffffff8127696a>] ? napi_skb_finish+0x1c/0x31
[401314.492655]  [<ffffffffa01c0fcd>] ? igb_poll+0x6d9/0x9ee [igb]
[401314.498546]  [<ffffffff8109031f>] ? handle_irq_event+0x40/0x55
[401314.504436]  [<ffffffff8132c993>] ? common_interrupt+0x13/0x13
[401314.510326]  [<ffffffff81276ec0>] ? net_rx_action+0xa4/0x1b1
[401314.516043]  [<ffffffff8104ad0a>] ? __do_softirq+0xb8/0x176
[401314.521674]  [<ffffffff8100e06d>] ? paravirt_read_tsc+0x5/0x8
[401314.527478]  [<ffffffff81333a1c>] ? call_softirq+0x1c/0x30
[401314.533022]  [<ffffffff8100aa57>] ? do_softirq+0x3f/0x84
[401314.538392]  [<ffffffff8104af75>] ? irq_exit+0x3f/0x8f
[401314.543588]  [<ffffffff8100a793>] ? do_IRQ+0x85/0x9e
[401314.548613]  [<ffffffff8132c993>] ? common_interrupt+0x13/0x13
[401314.554501]  <EOI>
[401314.556683]  [<ffffffff8106132c>] ? enqueue_hrtimer+0x3f/0x53
[401314.562487]  [<ffffffffa02c7417>] ? arch_local_irq_enable+0x7/0x8 
[processor]
[401314.569673]  [<ffffffffa02c7fdf>] ? acpi_idle_enter_bm+0x218/0x250 
[processor]
[401314.576948]  [<ffffffff8125ded9>] ? menu_select+0x169/0x296
[401314.582577]  [<ffffffff8125cfe9>] ? cpuidle_idle_call+0xf4/0x17e
[401314.588640]  [<ffffffff81008298>] ? cpu_idle+0xa2/0xc4
[401314.593839]  [<ffffffff8169db60>] ? start_kernel+0x3b9/0x3c4
[401314.599554]  [<ffffffff8169d3c6>] ? x86_64_start_kernel+0x102/0x10f
[401314.605875] Code: 4d 02 3c 03 0f 86 59 02 00 00 0f b6 d0 44 39 ea 7f 
32 83 c2 03 44 39 ea 0f 8f 45 02 00 00 48 85 db 74 18 48 8b 74 24 10 0f 
b6 c0 <8b> 96 cc 00 00 00 89 54 05 ff 41 80 4c 24 08 04 80 01 04 41 80
[401314.625301] RIP  [<ffffffff8129fb09>] ip_options_compile+0x1c1/0x435
[401314.631718]  RSP <ffff88042f203af0>
[401314.635271] CR2: 00000000000000cc
[401314.638981] ---[ end trace ee9f25b92857731e ]---
[401314.643661] BUG: scheduling while atomic: swapper/0/0x10000100
[401314.649551] Modules linked in: kvm_intel kvm bridge stp loop tpm_tis 
snd_pcm tpm snd_timer snd soundcore psmouse snd_page_alloc ghes pcspkr 
tpm_bios i7core_edac serio_raw evdev processor dcdbas edac_core 
thermal_sys power_meter hed button ext2 mbcache dm_mod raid1 md_mod 
sd_mod crc_t10dif usb_storage uas uhci_hcd mpt2sas igb 
scsi_transport_sas ehci_hcd raid_class scsi_mod usbcore bnx2 dca [last 
unloaded: scsi_wait_scan]
[401314.687071] CPU 0
[401314.688981] Modules linked in: kvm_intel kvm bridge stp loop tpm_tis 
snd_pcm tpm snd_timer snd soundcore psmouse snd_page_alloc ghes pcspkr 
tpm_bios i7core_edac serio_raw evdev processor dcdbas edac_core 
thermal_sys power_meter hed button ext2 mbcache dm_mod raid1 md_mod 
sd_mod crc_t10dif usb_storage uas uhci_hcd mpt2sas igb 
scsi_transport_sas ehci_hcd raid_class scsi_mod usbcore bnx2 dca [last 
unloaded: scsi_wait_scan]
[401314.726690]
[401314.728255] Pid: 0, comm: swapper Tainted: G      D     2.6.39-rc1+ 
#2 Dell Inc. PowerEdge R510/0DPRKF
[401314.737628] RIP: 0010:[<ffffffffa02c7417>]  [<ffffffffa02c7417>] 
arch_local_irq_enable+0x7/0x8 [processor]
[401314.747333] RSP: 0018:ffffffff81601eb0  EFLAGS: 00000292
[401314.752703] RAX: 000000000001d1bc RBX: ffffffff8106132c RCX: 
00000000000003e8
[401314.759889] RDX: 000000000000006e RSI: 0000000225c17d03 RDI: 
00000000071b46ce
[401314.767075] RBP: ffff880403a82800 R08: 00000000fffffffd R09: 
0000000000000000
[401314.774261] R10: ffff880404078340 R11: 0000000000000040 R12: 
ffffffff8132c98e
[401314.781447] R13: ffff88042f20feb0 R14: ffffffff811a2ede R15: 
ffff88042f20fdc8
[401314.788633] FS:  0000000000000000(0000) GS:ffff88042f200000(0000) 
knlGS:0000000000000000
[401314.796770] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[401314.802573] CR2: 00000000000000cc CR3: 0000000001603000 CR4: 
00000000000006f0
[401314.809761] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[401314.816947] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[401314.824133] Process swapper (pid: 0, threadinfo ffffffff81600000, 
task ffffffff8160b020)
[401314.832269] Stack:
[401314.834353]  ffffffffa02c7fdf 0000000000011140 ffffffff8125ded9 
0000000105fdb064
[401314.841835]  ffff880403a82820 ffff880403a828f0 0000000000000002 
ffffffffffffffff
[401314.849317]  ffffffff8125cfe9 0000000000000000 ffffffff81600000 
ffffffff816812d0
[401314.856798] Call Trace:
[401314.859317]  [<ffffffffa02c7fdf>] ? acpi_idle_enter_bm+0x218/0x250 
[processor]
[401314.866590]  [<ffffffff8125ded9>] ? menu_select+0x169/0x296
[401314.872222]  [<ffffffff8125cfe9>] ? cpuidle_idle_call+0xf4/0x17e
[401314.878286]  [<ffffffff81008298>] ? cpu_idle+0xa2/0xc4
[401314.883483]  [<ffffffff8169db60>] ? start_kernel+0x3b9/0x3c4
[401314.889200]  [<ffffffff8169d3c6>] ? x86_64_start_kernel+0x102/0x10f
[401314.895522] Code: 63 1c fb 48 83 c4 38 89 e8 5b 5d 41 5c 41 5d 41 5e 
41 5f c3 0f 09 0f 1f 44 00 00 c3 fa 66 0f 1f 44 00 00 c3 fb 66 0f 1f 44 
00 00 <c3> 48 8b 15 81 70 45 e1 48 8d 42 fd 48 83 f8 01 0f 96 c0 48 ff
[401314.914953] Call Trace:
[401314.917472]  [<ffffffffa02c7fdf>] ? acpi_idle_enter_bm+0x218/0x250 
[processor]
[401314.924746]  [<ffffffff8125ded9>] ? menu_select+0x169/0x296
[401314.930378]  [<ffffffff8125cfe9>] ? cpuidle_idle_call+0xf4/0x17e
[401314.936444]  [<ffffffff81008298>] ? cpu_idle+0xa2/0xc4
[401314.941642]  [<ffffffff8169db60>] ? start_kernel+0x3b9/0x3c4
[401314.947361]  [<ffffffff8169d3c6>] ? x86_64_start_kernel+0x102/0x10f
[401314.954266] Kernel panic - not syncing: Fatal exception in interrupt
[401314.960680] Pid: 0, comm: swapper Tainted: G      D     2.6.39-rc1+ #2
[401314.967265] Call Trace:
[401314.969785]  <IRQ>  [<ffffffff8132ab34>] ? panic+0x92/0x1a1
[401314.975429]  [<ffffffff8132d6f6>] ? oops_end+0xa9/0xb6
[401314.980630]  [<ffffffff8102ca16>] ? no_context+0x1ed/0x1fa
[401314.986177]  [<ffffffff8132f4e3>] ? do_page_fault+0x16b/0x308
[401314.991982]  [<ffffffff81268a03>] ? sk_wake_async+0x19/0x3c
[401314.997615]  [<ffffffff8126dcea>] ? skb_checksum+0x46/0x1ce
[401315.003246]  [<ffffffff8126befd>] ? skb_clone+0x44/0x12d
[401315.008619]  [<ffffffff810ec6bc>] ? kmem_cache_alloc+0x22/0xe6
[401315.014509]  [<ffffffff810ea70e>] ? virt_to_head_page+0x9/0x2f
[401315.020400]  [<ffffffff810ec8dc>] ? kmem_cache_free+0x12/0xa4
[401315.026208]  [<ffffffffa019f014>] ? br_multicast_rcv+0xbc2/0xbee 
[bridge]
[401315.033050]  [<ffffffff81271ed8>] ? arch_local_irq_save+0x12/0x1b
[401315.039201]  [<ffffffff8132cc55>] ? page_fault+0x25/0x30
[401315.044574]  [<ffffffffa0197e89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[401315.051157]  [<ffffffff8129fb09>] ? ip_options_compile+0x1c1/0x435
[401315.057395]  [<ffffffff810ec7a8>] ? __slab_free+0x28/0x14a
[401315.062943]  [<ffffffffa019be3a>] ? br_parse_ip_options+0x133/0x1a0 
[bridge]
[401315.070047]  [<ffffffffa019cbd8>] ? br_nf_pre_routing+0x348/0x3cb 
[bridge]
[401315.076976]  [<ffffffff8119d89b>] ? cpumask_next_and+0x2b/0x3a
[401315.082867]  [<ffffffff81298493>] ? nf_iterate+0x41/0x7e
[401315.088242]  [<ffffffffa0197e89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[401315.094825]  [<ffffffffa0197e89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[401315.101408]  [<ffffffff81298543>] ? nf_hook_slow+0x73/0x114
[401315.107040]  [<ffffffffa0197e89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[401315.113624]  [<ffffffffa0197e89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[401315.120208]  [<ffffffffa0197e6f>] ? NF_HOOK.clone.4+0x3c/0x56 [bridge]
[401315.126791]  [<ffffffffa01981e5>] ? br_handle_frame+0x195/0x1ac [bridge]
[401315.133549]  [<ffffffffa0198050>] ? 
br_handle_frame_finish+0x1c7/0x1c7 [bridge]
[401315.140911]  [<ffffffff8127646f>] ? __netif_receive_skb+0x2a7/0x450
[401315.147233]  [<ffffffff81276893>] ? netif_receive_skb+0x52/0x58
[401315.153212]  [<ffffffff81276d95>] ? napi_gro_receive+0x1f/0x2f
[401315.159103]  [<ffffffff8127696a>] ? napi_skb_finish+0x1c/0x31
[401315.164911]  [<ffffffffa01c0fcd>] ? igb_poll+0x6d9/0x9ee [igb]
[401315.170804]  [<ffffffff8109031f>] ? handle_irq_event+0x40/0x55
[401315.176695]  [<ffffffff8132c993>] ? common_interrupt+0x13/0x13
[401315.182586]  [<ffffffff81276ec0>] ? net_rx_action+0xa4/0x1b1
[401315.188305]  [<ffffffff8104ad0a>] ? __do_softirq+0xb8/0x176
[401315.193937]  [<ffffffff8100e06d>] ? paravirt_read_tsc+0x5/0x8
[401315.199743]  [<ffffffff81333a1c>] ? call_softirq+0x1c/0x30
[401315.205289]  [<ffffffff8100aa57>] ? do_softirq+0x3f/0x84
[401315.210661]  [<ffffffff8104af75>] ? irq_exit+0x3f/0x8f
[401315.215860]  [<ffffffff8100a793>] ? do_IRQ+0x85/0x9e
[401315.220887]  [<ffffffff8132c993>] ? common_interrupt+0x13/0x13
[401315.226777]  <EOI>  [<ffffffff8106132c>] ? enqueue_hrtimer+0x3f/0x53
[401315.233201]  [<ffffffffa02c7417>] ? arch_local_irq_enable+0x7/0x8 
[processor]
[401315.240390]  [<ffffffffa02c7fdf>] ? acpi_idle_enter_bm+0x218/0x250 
[processor]
[401315.247664]  [<ffffffff8125ded9>] ? menu_select+0x169/0x296
[401315.253296]  [<ffffffff8125cfe9>] ? cpuidle_idle_call+0xf4/0x17e
[401315.259361]  [<ffffffff81008298>] ? cpu_idle+0xa2/0xc4
[401315.264560]  [<ffffffff8169db60>] ? start_kernel+0x3b9/0x3c4
[401315.270279]  [<ffffffff8169d3c6>] ? x86_64_start_kernel+0x102/0x10f
[401315.276602] BUG: scheduling while atomic: swapper/0/0x10000100
[401315.282491] Modules linked in: kvm_intel kvm bridge stp loop tpm_tis 
snd_pcm tpm snd_timer snd soundcore psmouse snd_page_alloc ghes pcspkr 
tpm_bios i7core_edac serio_raw evdev processor dcdbas edac_core 
thermal_sys power_meter hed button ext2 mbcache dm_mod raid1 md_mod 
sd_mod crc_t10dif usb_storage uas uhci_hcd mpt2sas igb 
scsi_transport_sas ehci_hcd raid_class scsi_mod usbcore bnx2 dca [last 
unloaded: scsi_wait_scan]
[401315.320027] CPU 0
[401315.321938] Modules linked in: kvm_intel kvm bridge stp loop tpm_tis 
snd_pcm tpm snd_timer snd soundcore psmouse snd_page_alloc ghes pcspkr 
tpm_bios i7core_edac serio_raw evdev processor dcdbas edac_core 
thermal_sys power_meter hed button ext2 mbcache dm_mod raid1 md_mod 
sd_mod crc_t10dif usb_storage uas uhci_hcd mpt2sas igb 
scsi_transport_sas ehci_hcd raid_class scsi_mod usbcore bnx2 dca [last 
unloaded: scsi_wait_scan]
[401315.359651]
[401315.361216] Pid: 0, comm: swapper Tainted: G      D     2.6.39-rc1+ 
#2 Dell Inc. PowerEdge R510/0DPRKF
[401315.370590] RIP: 0010:[<ffffffffa02c7417>]  [<ffffffffa02c7417>] 
arch_local_irq_enable+0x7/0x8 [processor]
[401315.380296] RSP: 0018:ffffffff81601eb0  EFLAGS: 00000292
[401315.385668] RAX: 000000000001d1bc RBX: ffffffff8106132c RCX: 
00000000000003e8
[401315.392856] RDX: 000000000000006e RSI: 0000000225c17d03 RDI: 
00000000071b46ce
[401315.400043] RBP: ffff880403a82800 R08: 00000000fffffffd R09: 
0000000000000000
[401315.407230] R10: ffff880404078340 R11: 0000000000000040 R12: 
ffffffff8132c98e
[401315.414417] R13: ffff88042f20feb0 R14: ffffffff811a2ede R15: 
ffff88042f20fdc8
[401315.421605] FS:  0000000000000000(0000) GS:ffff88042f200000(0000) 
knlGS:0000000000000000
[401315.429744] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[401315.435549] CR2: 00000000000000cc CR3: 00000004042e8000 CR4: 
00000000000006f0
[401315.442736] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[401315.449923] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[401315.457110] Process swapper (pid: 0, threadinfo ffffffff81600000, 
task ffffffff8160b020)
[401315.465248] Stack:
[401315.467334]  ffffffffa02c7fdf 0000000000011140 ffffffff8125ded9 
0000000105fdb064
[401315.474816]  ffff880403a82820 ffff880403a828f0 0000000000000002 
ffffffffffffffff
[401315.482300]  ffffffff8125cfe9 0000000000000000 ffffffff81600000 
ffffffff816812d0
[401315.489784] Call Trace:
[401315.492306]  [<ffffffffa02c7fdf>] ? acpi_idle_enter_bm+0x218/0x250 
[processor]
[401315.499582]  [<ffffffff8125ded9>] ? menu_select+0x169/0x296
[401315.505215]  [<ffffffff8125cfe9>] ? cpuidle_idle_call+0xf4/0x17e
[401315.511280]  [<ffffffff81008298>] ? cpu_idle+0xa2/0xc4
[401315.516481]  [<ffffffff8169db60>] ? start_kernel+0x3b9/0x3c4
[401315.522199]  [<ffffffff8169d3c6>] ? x86_64_start_kernel+0x102/0x10f
[401315.528522] Code: 63 1c fb 48 83 c4 38 89 e8 5b 5d 41 5c 41 5d 41 5e 
41 5f c3 0f 09 0f 1f 44 00 00 c3 fa 66 0f 1f 44 00 00 c3 fb 66 0f 1f 44 
00 00 <c3> 48 8b 15 81 70 45 e1 48 8d 42 fd 48 83 f8 01 0f 96 c0 48 ff
[401315.547963] Call Trace:
[401315.550482]  [<ffffffffa02c7fdf>] ? acpi_idle_enter_bm+0x218/0x250 
[processor]
[401315.557758]  [<ffffffff8125ded9>] ? menu_select+0x169/0x296
[401315.563392]  [<ffffffff8125cfe9>] ? cpuidle_idle_call+0xf4/0x17e
[401315.569456]  [<ffffffff81008298>] ? cpu_idle+0xa2/0xc4
[401315.574655]  [<ffffffff8169db60>] ? start_kernel+0x3b9/0x3c4
[401315.580374]  [<ffffffff8169d3c6>] ? x86_64_start_kernel+0x102/0x10f
[401315.586862] BUG: unable to handle kernel NULL pointer dereference at 
00000000000000e0
[401315.594758] IP: [<ffffffffa01c0ca8>] igb_poll+0x3b4/0x9ee [igb]
[401315.600745] PGD 4041c6067 PUD 40514b067 PMD 0
[401315.605276] Oops: 0000 [#2] SMP
[401315.608587] last sysfs file: 
/sys/devices/virtual/block/md127/md/mismatch_cnt
[401315.615772] CPU 0
[401315.617682] Modules linked in: kvm_intel kvm bridge stp loop tpm_tis 
snd_pcm tpm snd_timer snd soundcore psmouse snd_page_alloc ghes pcspkr 
tpm_bios i7core_edac serio_raw evdev processor dcdbas edac_core 
thermal_sys power_meter hed button ext2 mbcache dm_mod raid1 md_mod 
sd_mod crc_t10dif usb_storage uas uhci_hcd mpt2sas igb 
scsi_transport_sas ehci_hcd raid_class scsi_mod usbcore bnx2 dca [last 
unloaded: scsi_wait_scan]
[401315.655363]
[401315.656931] Pid: 1563, comm: rsyslogd Tainted: G      D 
2.6.39-rc1+ #2 Dell Inc. PowerEdge R510/0DPRKF
[401315.666650] RIP: 0010:[<ffffffffa01c0ca8>]  [<ffffffffa01c0ca8>] 
igb_poll+0x3b4/0x9ee [igb]
[401315.675057] RSP: 0000:ffff8804024d7d70  EFLAGS: 00010207
[401315.680427] RAX: ffff880401f5ccd8 RBX: ffff880401f5d8c0 RCX: 
0000000000000000
[401315.687612] RDX: 0000000000000040 RSI: 0000000000001043 RDI: 
ffff880401f5ccd8
[401315.694798] RBP: 0000000000000000 R08: 000000a47c6e7c01 R09: 
00000000000000fa
[401315.701983] R10: 0000000000000249 R11: ffffffff81404535 R12: 
0000000000000038
[401315.709168] R13: ffffc900126a28c0 R14: 0000000000000000 R15: 
ffff880404d09380
[401315.716353] FS:  00007f8cf4fca700(0000) GS:ffff88042f200000(0000) 
knlGS:0000000000000000
[401315.724489] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[401315.730292] CR2: 00000000000000e0 CR3: 00000004042e8000 CR4: 
00000000000006f0
[401315.737477] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[401315.744662] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[401315.751847] Process rsyslogd (pid: 1563, threadinfo 
ffff8804024d6000, task ffff88041d9dc2e0)
[401315.760330] Stack:
[401315.762413]  ffffffff81772040 ffffffff81051890 ffff88042f213a80 
ffffffff817c5680
[401315.769892]  ffffffff817c5680 0000000105fdb7ac 0000000000000286 
0000104381051b4a
[401315.777371]  0000000100000039 ffff880401f5ccc0 ffff880400000000 
ffff880404078740
[401315.784850] Call Trace:
[401315.787370]  [<ffffffff81051890>] ? lock_timer_base.clone.20+0x25/0x4c
[401315.793951]  [<ffffffff8132c62d>] ? _raw_spin_lock_irq+0xd/0x1a
[401315.799928]  [<ffffffff81276ec0>] ? net_rx_action+0xa4/0x1b1
[401315.805644]  [<ffffffff810657f4>] ? timekeeping_get_ns+0xe/0x2e
[401315.811620]  [<ffffffff8104ad0a>] ? __do_softirq+0xb8/0x176
[401315.817252]  [<ffffffff81333a1c>] ? call_softirq+0x1c/0x30
[401315.822796]  [<ffffffff8100aa57>] ? do_softirq+0x3f/0x84
[401315.828167]  [<ffffffff8104af75>] ? irq_exit+0x3f/0x8f
[401315.833365]  [<ffffffff8101f280>] ? smp_apic_timer_interrupt+0x78/0x88
[401315.839946]  [<ffffffff813331d3>] ? apic_timer_interrupt+0x13/0x20
[401315.846182]  [<ffffffff81332812>] ? system_call_fastpath+0x16/0x1b
[401315.852416] Code: 89 74 24 3c e9 78 03 00 00 8b 54 24 70 39 54 24 44 
0f 8d 75 03 00 00 ff 44 24 44 0f ae e8 49 8b 6d 00 ff 44 24 40 b9 00 00 
00 00
[401315.865859]  8b 85 e0 00 00 00 49 c7 45 00 00 00 00 00 41 8b 77 0c 
0f 18
[401315.873063] RIP  [<ffffffffa01c0ca8>] igb_poll+0x3b4/0x9ee [igb]
[401315.879136]  RSP <ffff8804024d7d70>
[401315.882689] CR2: 00000000000000e0
[401315.886080] ---[ end trace ee9f25b92857731f ]---
[401315.890761] BUG: scheduling while atomic: rsyslogd/1563/0x10000100
[401315.896997] Modules linked in: kvm_intel kvm bridge stp loop tpm_tis 
snd_pcm tpm snd_timer snd soundcore psmouse snd_page_alloc ghes pcspkr 
tpm_bios i7core_edac serio_raw evdev processor dcdbas edac_core 
thermal_sys power_meter hed button ext2 mbcache dm_mod raid1 md_mod 
sd_mod crc_t10dif usb_storage uas uhci_hcd mpt2sas igb 
scsi_transport_sas ehci_hcd raid_class scsi_mod usbcore bnx2 dca [last 
unloaded: scsi_wait_scan]
[401315.934529] CPU 0
[401315.936441] Modules linked in: kvm_intel kvm bridge stp loop tpm_tis 
snd_pcm tpm snd_timer snd soundcore psmouse snd_page_alloc ghes pcspkr 
tpm_bios i7core_edac serio_raw evdev processor dcdbas edac_core 
thermal_sys power_meter hed button ext2 mbcache dm_mod raid1 md_mod 
sd_mod crc_t10dif usb_storage uas uhci_hcd mpt2sas igb 
scsi_transport_sas ehci_hcd raid_class scsi_mod usbcore bnx2 dca [last 
unloaded: scsi_wait_scan]
[401315.974155]
[401315.975722] Pid: 1563, comm: rsyslogd Tainted: G      D 
2.6.39-rc1+ #2 Dell Inc. PowerEdge R510/0DPRKF
[401315.985442] RIP: 0033:[<00007f8cf6f6b7c9>]  [<00007f8cf6f6b7c9>] 
0x7f8cf6f6b7c8
[401315.992814] RSP: 002b:00007f8cf4fc9d78  EFLAGS: 00000206
[401315.998185] RAX: 0000000000000000 RBX: ffffffff81332812 RCX: 
0000000000000e83
[401316.005372] RDX: 00007f8cf67fd9dc RSI: 000000000000003c RDI: 
00007f8cf65fc2a9
[401316.012560] RBP: 00007f8cf67fd9dc R08: 00007f8cf65fc2a9 R09: 
000000000000061b
[401316.019746] R10: 0000000000000000 R11: 0000000000000000 R12: 
ffffffff813331d3
[401316.026934] R13: ffff8804024d7f78 R14: 00007f8cf67fe880 R15: 
0000000000c63b98
[401316.034122] FS:  00007f8cf4fca700(0000) GS:ffff88042f200000(0000) 
knlGS:0000000000000000
[401316.042261] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[401316.048065] CR2: 00000000000000e0 CR3: 00000004042e8000 CR4: 
00000000000006f0
[401316.055253] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[401316.062440] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[401316.069628] Process rsyslogd (pid: 1563, threadinfo 
ffff8804024d6000, task ffff88041d9dc2e0)
[401316.078112]
[401316.079679] Call Trace:
[401316.082330] Kernel panic - not syncing: Fatal exception in interrupt
[401316.088739] Pid: 1563, comm: rsyslogd Tainted: G      D 
2.6.39-rc1+ #2
[401316.095666] Call Trace:
[401316.098185]  [<ffffffff8132ab34>] ? panic+0x92/0x1a1
[401316.103213]  [<ffffffff8132d6f6>] ? oops_end+0xa9/0xb6
[401316.108414]  [<ffffffff8102ca16>] ? no_context+0x1ed/0x1fa
[401316.113960]  [<ffffffff8132f4e3>] ? do_page_fault+0x16b/0x308
[401316.119767]  [<ffffffff8132cc55>] ? page_fault+0x25/0x30
[401316.125143]  [<ffffffffa01c0ca8>] ? igb_poll+0x3b4/0x9ee [igb]
[401316.131035]  [<ffffffff81051890>] ? lock_timer_base.clone.20+0x25/0x4c
[401316.137617]  [<ffffffff8132c62d>] ? _raw_spin_lock_irq+0xd/0x1a
[401316.143595]  [<ffffffff81276ec0>] ? net_rx_action+0xa4/0x1b1
[401316.149313]  [<ffffffff810657f4>] ? timekeeping_get_ns+0xe/0x2e
[401316.155291]  [<ffffffff8104ad0a>] ? __do_softirq+0xb8/0x176
[401316.160923]  [<ffffffff81333a1c>] ? call_softirq+0x1c/0x30
[401316.166469]  [<ffffffff8100aa57>] ? do_softirq+0x3f/0x84
[401316.171843]  [<ffffffff8104af75>] ? irq_exit+0x3f/0x8f
[401316.177044]  [<ffffffff8101f280>] ? smp_apic_timer_interrupt+0x78/0x88
[401316.183626]  [<ffffffff813331d3>] ? apic_timer_interrupt+0x13/0x20
[401316.189863]  [<ffffffff81332812>] ? system_call_fastpath+0x16/0x1b
