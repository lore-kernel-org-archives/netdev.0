From: Ryan Whelan <rcwhelan@gmail.com>
Subject: Kernel Panic in IPv6 vxlan
Date: Tue, 26 Nov 2013 16:41:08 -0500
Message-ID: <CAM3m09T2tuFCMjzdJq7AVBDnPeK0kVKt51JXsE954cHO6u_u2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:39353 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754556Ab3KZVlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 16:41:11 -0500
Received: by mail-lb0-f169.google.com with SMTP id y6so4897568lbh.14
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 13:41:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm not sure if this is the right place to report this- please correct
me if I'm mistaken.

When creating a vxlan interface with an IPv6 multicast group but not
specifying an underlying device, the kernel panics when the vxlan
interface is brought up.  This doesn't happen with an IPv4 multicast
group.  Linux 3.12.1 x86_64

`ip link add vxlan0 type vxlan id 42 group ff0e::110`
`ip link set vxlan0 up`

[  192.037669] BUG: unable to handle kernel NULL pointer dereference
at 0000000000000080
[  192.041392] IP: [<ffffffff8135fb85>] ipv6_sock_mc_join+0x29/0x171
[  192.043865] PGD 0
[  192.044693] Oops: 0000 [#1] SMP
[  192.046020] Modules linked in: nfsd auth_rpcgss oid_registry
nfs_acl nfs lockd fscache sunrpc loop coretemp crc32c_intel vmwgfx ttm
ghash_clmulni_intel aesni_intel aes_x86_64 joydev ablk_helper drm
snd_pcm cryptd lrw snd_page_alloc snd_timer gf128mul glue_helper snd
processor hid_generic psmouse soundcore ehci_pci thermal_sys
parport_pc parport usbhid pcspkr serio_raw hid shpchp evdev i2c_piix4
i2c_core microcode button ac ext4 crc16 jbd2 mbcache dm_mod sg sd_mod
sr_mod cdrom crc_t10dif crct10dif_common ata_generic floppy e1000
uhci_hcd ehci_hcd usbcore usb_common mptspi ata_piix
scsi_transport_spi mptscsih mptbase libata scsi_mod
[  192.064123] CPU: 1 PID: 173 Comm: kworker/1:2 Not tainted 3.12.1 #1
[  192.065625] Hardware name: VMware, Inc. VMware Virtual
Platform/440BX Desktop Reference Platform, BIOS 6.00 09/20/2012
[  192.068087] Workqueue: vxlan vxlan_igmp_join
[  192.069154] task: ffff8800175727f0 ti: ffff88001775a000 task.ti:
ffff88001775a000
[  192.070848] RIP: 0010:[<ffffffff8135fb85>]  [<ffffffff8135fb85>]
ipv6_sock_mc_join+0x29/0x171
[  192.072733] RSP: 0018:ffff88001775bdc8  EFLAGS: 00010246
[  192.073871] RAX: ffffffff8145f160 RBX: ffff8800175dc8c0 RCX: ffff880017a32870
[  192.075440] RDX: ffff8800175dc838 RSI: 0000000000000000 RDI: ffff880014052800
[  192.077089] RBP: ffff8800175dc838 R08: ffff88001775a000 R09: 00000000000032e8
[  192.078752] R10: 00000000000032e8 R11: 00000000000032e8 R12: ffff880014052800
[  192.080426] R13: 0000000000000000 R14: ffffffff81678340 R15: 0000000000000000
[  192.082071] FS:  0000000000000000(0000) GS:ffff880017a20000(0000)
knlGS:0000000000000000
[  192.083955] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  192.085244] CR2: 0000000000000080 CR3: 000000000160b000 CR4: 00000000000407e0
[  192.086882] Stack:
[  192.087362]  0000000000000000 ffff8800175dc8c0 ffff880014052800
ffff880017160000
[  192.089190]  0000000000000000 0000000000000000 0000000000000000
ffffffff81293269
[  192.091022]  ffff8800175727f0 ffff8800177413c0 ffff8800173bbef8
ffff88001755ea40
[  192.093443] Call Trace:
[  192.094056]  [<ffffffff81293269>] ? vxlan_igmp_join+0x77/0xa3
[  192.095399]  [<ffffffff8104bc07>] ? process_one_work+0x191/0x294
[  192.096791]  [<ffffffff8104c0b9>] ? worker_thread+0x121/0x1e7
[  192.098127]  [<ffffffff8104bf98>] ? rescuer_thread+0x269/0x269
[  192.099405]  [<ffffffff81050ae1>] ? kthread+0x81/0x89
[  192.100480]  [<ffffffff81050a60>] ? __kthread_parkme+0x5d/0x5d
[  192.101848]  [<ffffffff8138e3fc>] ? ret_from_fork+0x7c/0xb0
[  192.103135]  [<ffffffff81050a60>] ? __kthread_parkme+0x5d/0x5d
[  192.104493] Code: 5e c3 41 57 41 56 41 55 41 54 49 89 fc 55 48 89
d5 53 41 55 80 3a ff 4c 8b af 98 02 00 00 4c 8b 77 30 0f 85 30 01 00
00 41 89 f7 <49> 8b 9d 80 00 00 00 eb 28 45 85 ff 74 06 44 39 7b 10 75
19 48
[  192.112812] RIP  [<ffffffff8135fb85>] ipv6_sock_mc_join+0x29/0x171
[  192.114208]  RSP <ffff88001775bdc8>
[  192.114978] CR2: 0000000000000080
[  192.115813] BUG: unable to handle kernel NULL pointer dereference
at 000000000000006e
[  192.117676] IP: [<ffffffff8134f89f>] ip6_route_output+0x50/0x76
[  192.119045] PGD 0
[  192.119564] Oops: 0000 [#2] SMP
[  192.120856] Modules linked in: nfsd auth_rpcgss oid_registry
nfs_acl nfs lockd fscache sunrpc loop coretemp crc32c_intel vmwgfx ttm
ghash_clmulni_intel aesni_intel aes_x86_64 joydev ablk_helper drm
snd_pcm cryptd lrw snd_page_alloc snd_timer gf128mul glue_helper snd
processor hid_generic psmouse soundcore ehci_pci thermal_sys
parport_pc parport usbhid pcspkr serio_raw hid shpchp evdev i2c_piix4
i2c_core microcode button ac ext4 crc16 jbd2 mbcache dm_mod sg sd_mod
sr_mod cdrom crc_t10dif crct10dif_common ata_generic floppy e1000
uhci_hcd ehci_hcd usbcore usb_common mptspi ata_piix
scsi_transport_spi mptscsih mptbase libata scsi_mod
[  192.137768] CPU: 1 PID: 173 Comm: kworker/1:2 Tainted: G      D
 3.12.1 #1
[  192.139489] Hardware name: VMware, Inc. VMware Virtual
Platform/440BX Desktop Reference Platform, BIOS 6.00 09/20/2012
[  192.141859] Workqueue: vxlan vxlan_igmp_join
[  192.142860] task: ffff8800175727f0 ti: ffff88001775a000 task.ti:
ffff88001775a000
[  192.144565] RIP: 0010:[<ffffffff8134f89f>]  [<ffffffff8134f89f>]
ip6_route_output+0x50/0x76
[  192.146499] RSP: 0018:ffff880017a23a00  EFLAGS: 00010286
[  192.149207] RAX: 0000000000000001 RBX: ffff880017a23b28 RCX: 00000000000000e0
[  192.151009] RDX: 0000000000000000 RSI: ffff880014052800 RDI: ffff880017a23b3c
[  192.152666] RBP: ffff880014052800 R08: 00000000000006c0 R09: 0000000000000000
[  192.154308] R10: 0000000016000000 R11: ffff880014052800 R12: ffffffff81678340
[  192.155951] R13: ffffffff81678340 R14: ffff880014052800 R15: ffff88001520e050
[  192.157612] FS:  0000000000000000(0000) GS:ffff880017a20000(0000)
knlGS:0000000000000000
[  192.159484] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  192.160834] CR2: 000000000000006e CR3: 000000000160b000 CR4: 00000000000407e0
[  192.162509] Stack:
[  192.163022]  ffff880017a23b00 ffff880017a23b28 ffff8800175dc000
ffffffff81343dea
[  192.164974]  ffff8800170d6780 0000000000000972 ffff88001777b5c0
00000000f9437ecf
[  192.166901]  ffffffff8105f050 ffff8800170ce0c0 0000000000006e49
0000000000008000
[  192.168821] Call Trace:
[  192.169430]  <IRQ>
[  192.169909]  [<ffffffff81343dea>] ? ip6_dst_lookup_tail+0x3c/0x1a7
[  192.171425]  [<ffffffff8105f050>] ? wakeup_preempt_entity.isra.46+0x18/0x28
[  192.172940]  [<ffffffff81294433>] ? vxlan_xmit_one+0x311/0x6de
[  192.174230]  [<ffffffff8105a6cf>] ? ttwu_do_wakeup+0xf/0xc1
[  192.175452]  [<ffffffff8105c189>] ? try_to_wake_up+0x17e/0x190
[  192.176716]  [<ffffffff812951bb>] ? vxlan_rcv+0x29d/0x2c2
[  192.177951]  [<ffffffff812c2b4d>] ? __copy_skb_header+0x95/0x28f
[  192.179716]  [<ffffffff81294e7d>] ? vxlan_xmit+0x67d/0x71e
[  192.181003]  [<ffffffff812c31ba>] ? __kmalloc_reserve.isra.43+0x2a/0x6d
[  192.182535]  [<ffffffff810fb5d0>] ? virt_to_head_page+0x5/0x27
[  192.183889]  [<ffffffff810fb860>] ? ksize+0x12/0x1e
[  192.184989]  [<ffffffff812c38e7>] ? __alloc_skb+0xb5/0x1a9
[  192.186191]  [<ffffffff812d012e>] ? dev_hard_start_xmit+0x271/0x3ec
[  192.187573]  [<ffffffff812d059c>] ? dev_queue_xmit+0x2f3/0x3c8
[  192.188894]  [<ffffffff812d81cd>] ? neigh_resolve_output+0xe3/0x121
[  192.190254]  [<ffffffff81344b0f>] ? ip6_finish_output2+0x2b3/0x30e
[  192.191600]  [<ffffffff8135da41>] ? mld_sendpack+0x176/0x27c
[  192.192860]  [<ffffffff8135eebf>] ? add_grec+0x37d/0x3c3
[  192.194115]  [<ffffffff8135f27e>] ? mld_ifc_timer_expire+0x1a9/0x1d8
[  192.195592]  [<ffffffff8135f0d5>] ? igmp6_timer_handler+0x5e/0x5e
[  192.197006]  [<ffffffff810407bf>] ? call_timer_fn+0x4b/0xf6
[  192.198316]  [<ffffffff8135f0d5>] ? igmp6_timer_handler+0x5e/0x5e
[  192.199637]  [<ffffffff81040db0>] ? run_timer_softirq+0x189/0x1ce
[  192.200982]  [<ffffffff8107cd81>] ? tick_sched_do_timer+0x25/0x25
[  192.202369]  [<ffffffff8103ae4c>] ? __do_softirq+0xe8/0x201
[  192.203648]  [<ffffffff81076224>] ? ktime_get+0x5f/0x6b
[  192.204867]  [<ffffffff8107b565>] ? clockevents_program_event+0x9a/0xb6
[  192.206393]  [<ffffffff8138fb1c>] ? call_softirq+0x1c/0x30
[  192.207662]  [<ffffffff81003b7c>] ? do_softirq+0x2c/0x60
[  192.208923]  [<ffffffff8103b02a>] ? irq_exit+0x3b/0x7f
[  192.210130]  [<ffffffff81023c39>] ? smp_apic_timer_interrupt+0x2c/0x37
[  192.211658]  [<ffffffff8138f04a>] ? apic_timer_interrupt+0x6a/0x70
[  192.213021]  <EOI>
[  192.213456]  [<ffffffff81054909>] ? up+0xc/0x35
[  192.214589]  [<ffffffff8138a1e9>] ? oops_end+0x5e/0xa7
[  192.215723]  [<ffffffff813826f5>] ? no_context+0x24f/0x27a
[  192.216930]  [<ffffffff8138c336>] ? __do_page_fault+0x359/0x3d7
[  192.218215]  [<ffffffff810611c0>] ? find_busiest_group+0x26/0x1aa
[  192.219560]  [<ffffffff813898b2>] ? page_fault+0x22/0x30
[  192.220737]  [<ffffffff8135fb85>] ? ipv6_sock_mc_join+0x29/0x171
[  192.222113]  [<ffffffff81389320>] ? _raw_spin_lock_bh+0xe/0x1c
[  192.223488]  [<ffffffff81293269>] ? vxlan_igmp_join+0x77/0xa3
[  192.224820]  [<ffffffff8104bc07>] ? process_one_work+0x191/0x294
[  192.227456]  [<ffffffff8104c0b9>] ? worker_thread+0x121/0x1e7
[  192.228776]  [<ffffffff8104bf98>] ? rescuer_thread+0x269/0x269
[  192.230065]  [<ffffffff81050ae1>] ? kthread+0x81/0x89
[  192.231171]  [<ffffffff81050a60>] ? __kthread_parkme+0x5d/0x5d
[  192.232466]  [<ffffffff8138e3fc>] ? ret_from_fork+0x7c/0xb0
[  192.233737]  [<ffffffff81050a60>] ? __kthread_parkme+0x5d/0x5d
[  192.235013] Code: 8d 7b 14 e8 e8 fb 01 00 a8 32 0f 95 c0 0f b6 c0
48 8b 53 2c 48 0b 53 24 74 05 83 c8 04 eb 1a 48 85 ed 74 15 48 8b 95
98 02 00 00 <8a> 52 6e c0 ea 05 0f b6 d2 c1 e2 03 09 d0 48 89 de 4c 89
e7 48
[  192.243063] RIP  [<ffffffff8134f89f>] ip6_route_output+0x50/0x76
[  192.244516]  RSP <ffff880017a23a00>
[  192.245355] CR2: 000000000000006e
[  192.246205] ---[ end trace d2f5dcf3ce91b4cf ]---
[  192.247572] Kernel panic - not syncing: Fatal exception in interrupt
