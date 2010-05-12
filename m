From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [BUG] crashes with kvm/nat networking and net-next
Date: Tue, 11 May 2010 20:25:44 -0700
Message-ID: <20100511202544.267d33ee@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Bart De Schuymer <bdschuym@pandora.be>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39305 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752951Ab0ELDZ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 May 2010 23:25:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a regression that is showing up now in net-next, not sure what
changed recently in bridge netfilter that could be causing it?

[ 4593.956206] BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
[ 4593.956219] IP: [<ffffffffa03357a4>] br_nf_forward_finish+0x154/0x170 [bridge]
[ 4593.956232] PGD 195ece067 PUD 1ba005067 PMD 0 
[ 4593.956241] Oops: 0000 [#1] SMP 
[ 4593.956248] last sysfs file: /sys/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/device:08/ATK0110:00/hwmon/hwmon0/temp2_label
[ 4593.956253] CPU 3 
[ 4593.956256] Modules linked in: netconsole configfs hid_belkin tun ntfs vfat msdos fat autofs4 binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm radeon ttm drm_kms_helper drm i2c_algo_bit snd_hda_codec_analog ipv6 snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device psmouse asus_atk0110 snd serio_raw soundcore snd_page_alloc usbhid mvsas libsas scsi_transport_sas floppy sky2 e1000e [last unloaded: netconsole]
[ 4593.956375] 
[ 4593.956380] Pid: 29512, comm: kvm Not tainted 2.6.34-rc7-net #195 P6T DELUXE/System Product Name
[ 4593.956384] RIP: 0010:[<ffffffffa03357a4>]  [<ffffffffa03357a4>] br_nf_forward_finish+0x154/0x170 [bridge]
[ 4593.956395] RSP: 0018:ffff880001e63b78  EFLAGS: 00010246
[ 4593.956399] RAX: 0000000000000608 RBX: ffff880057181700 RCX: ffff8801b813d000
[ 4593.956402] RDX: 0000000000000000 RSI: 0000000000000002 RDI: ffff880057181700
[ 4593.956406] RBP: ffff880001e63ba8 R08: ffff8801b9d97000 R09: ffffffffa0335650
[ 4593.956410] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8801b813d000
[ 4593.956413] R13: ffffffff81ab3940 R14: ffff880057181700 R15: 0000000000000002
[ 4593.956418] FS:  00007fc40d380710(0000) GS:ffff880001e60000(0000) knlGS:0000000000000000
[ 4593.956422] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[ 4593.956426] CR2: 0000000000000018 CR3: 00000001ba1d7000 CR4: 00000000000026e0
[ 4593.956429] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 4593.956433] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 4593.956437] Process kvm (pid: 29512, threadinfo ffff8801ba566000, task ffff8801b8003870)
[ 4593.956441] Stack:
[ 4593.956443]  0000000100000020 ffff880001e63ba0 ffff880001e63ba0 ffff880057181700
[ 4593.956451] <0> ffffffffa0335650 ffffffff81ab3940 ffff880001e63bd8 ffffffffa03350e6
[ 4593.956462] <0> ffff880001e63c40 000000000000024d ffff880057181700 0000000080000000
[ 4593.956474] Call Trace:
[ 4593.956478]  <IRQ> 
[ 4593.956488]  [<ffffffffa0335650>] ? br_nf_forward_finish+0x0/0x170 [bridge]
[ 4593.956496]  [<ffffffffa03350e6>] NF_HOOK_THRESH+0x56/0x60 [bridge]
[ 4593.956504]  [<ffffffffa0335282>] br_nf_forward_arp+0x112/0x120 [bridge]
[ 4593.956511]  [<ffffffff813f7184>] nf_iterate+0x64/0xa0
[ 4593.956519]  [<ffffffffa032f920>] ? br_forward_finish+0x0/0x60 [bridge]
[ 4593.956524]  [<ffffffff813f722c>] nf_hook_slow+0x6c/0x100
[ 4593.956531]  [<ffffffffa032f920>] ? br_forward_finish+0x0/0x60 [bridge]
[ 4593.956538]  [<ffffffffa032f800>] ? __br_forward+0x0/0xc0 [bridge]
[ 4593.956545]  [<ffffffffa032f86d>] __br_forward+0x6d/0xc0 [bridge]
[ 4593.956550]  [<ffffffff813c5d8e>] ? skb_clone+0x3e/0x70
[ 4593.956557]  [<ffffffffa032f462>] deliver_clone+0x32/0x60 [bridge]
[ 4593.956564]  [<ffffffffa032f6b6>] br_flood+0xa6/0xe0 [bridge]
[ 4593.956571]  [<ffffffffa032f800>] ? __br_forward+0x0/0xc0 [bridge]
[ 4593.956578]  [<ffffffffa032f700>] br_flood_forward+0x10/0x20 [bridge]
[ 4593.956586]  [<ffffffffa0330ace>] br_handle_frame_finish+0x23e/0x260 [bridge]
[ 4593.956595]  [<ffffffffa03307ea>] br_handle_frame+0x1aa/0x250 [bridge]
[ 4593.956605]  [<ffffffff81070331>] ? autoremove_wake_function+0x11/0x40
[ 4593.956614]  [<ffffffff813cf537>] __netif_receive_skb+0x187/0x5d0
[ 4593.956622]  [<ffffffff813cfa81>] process_backlog+0x101/0x210
[ 4593.956630]  [<ffffffff813d092d>] net_rx_action+0x10d/0x260
[ 4593.956639]  [<ffffffff81058100>] __do_softirq+0xb0/0x230
[ 4593.956648]  [<ffffffff81009e5c>] call_softirq+0x1c/0x30
[ 4593.956653]  <EOI> 
[ 4593.956662]  [<ffffffff8100bad5>] ? do_softirq+0x65/0xa0
[ 4593.956667]  [<ffffffff813d3e48>] netif_rx_ni+0x28/0x30
[ 4593.956673]  [<ffffffffa03e2196>] tun_chr_aio_write+0x276/0x540 [tun]
[ 4593.956679]  [<ffffffffa03e1f20>] ? tun_chr_aio_write+0x0/0x540 [tun]
[ 4593.956686]  [<ffffffff8110cd0b>] do_sync_readv_writev+0xcb/0x110
[ 4593.956692]  [<ffffffff8120d593>] ? selinux_file_permission+0xf3/0x150
[ 4593.956699]  [<ffffffff81203081>] ? security_file_permission+0x11/0x20
[ 4593.956704]  [<ffffffff8110dd9a>] do_readv_writev+0xca/0x1f0
[ 4593.956710]  [<ffffffff8111c888>] ? vfs_ioctl+0x38/0xd0
[ 4593.956714]  [<ffffffff8111ceda>] ? do_vfs_ioctl+0x8a/0x610
[ 4593.956719]  [<ffffffff8110defe>] vfs_writev+0x3e/0x60
[ 4593.956723]  [<ffffffff8110e02c>] sys_writev+0x4c/0xb0
[ 4593.956730]  [<ffffffff81008f42>] system_call_fastpath+0x16/0x1b
[ 4593.956733] Code: d8 00 00 00 66 81 7c 01 10 08 06 0f 85 fc fe ff ff 44 8b 15 ff 6e 00 00 45 85 d2 0f 84 ec fe ff ff 66 0f 1f 44 00 00 4c 8b 63 28 <8b> 42 18 e9 e5 fe ff ff 0f 1f 40 00 48 89 df e8 68 a1 ff ff e9 
[ 4593.956838] RIP  [<ffffffffa03357a4>] br_nf_forward_finish+0x154/0x170 [bridge]
[ 4593.956848]  RSP <ffff880001e63b78>
[ 4593.956851] CR2: 0000000000000018
[ 4593.956855] ---[ end trace 5703d55ac3604d1c ]---
[ 4593.956859] Kernel panic - not syncing: Fatal exception in interrupt
[ 4593.956864] Pid: 29512, comm: kvm Tainted: G      D    2.6.34-rc7-net #195
[ 4593.956867] Call Trace:
[ 4593.956869]  <IRQ>  [<ffffffff81484ff2>] panic+0x78/0xf1
[ 4593.956880]  [<ffffffff81489449>] oops_end+0xa9/0xb0
[ 4593.956885]  [<ffffffff81033963>] no_context+0xf3/0x260
[ 4593.956891]  [<ffffffff81256664>] ? do_raw_spin_lock+0x54/0x150
[ 4593.956896]  [<ffffffff81033be5>] __bad_area_nosemaphore+0x115/0x1d0
[ 4593.956901]  [<ffffffff81033cae>] bad_area_nosemaphore+0xe/0x10
[ 4593.956907]  [<ffffffff8148bb3f>] do_page_fault+0x28f/0x330
[ 4593.956913]  [<ffffffff814887b5>] page_fault+0x25/0x30
[ 4593.956921]  [<ffffffffa0335650>] ? br_nf_forward_finish+0x0/0x170 [bridge]
[ 4593.956929]  [<ffffffffa03357a4>] ? br_nf_forward_finish+0x154/0x170 [bridge]
[ 4593.956938]  [<ffffffffa0335650>] ? br_nf_forward_finish+0x0/0x170 [bridge]
[ 4593.956951]  [<ffffffffa03350e6>] NF_HOOK_THRESH+0x56/0x60 [bridge]
[ 4593.956963]  [<ffffffffa0335282>] br_nf_forward_arp+0x112/0x120 [bridge]
[ 4593.956972]  [<ffffffff813f7184>] nf_iterate+0x64/0xa0
[ 4593.956983]  [<ffffffffa032f920>] ? br_forward_finish+0x0/0x60 [bridge]
[ 4593.956990]  [<ffffffff813f722c>] nf_hook_slow+0x6c/0x100
[ 4593.956997]  [<ffffffffa032f920>] ? br_forward_finish+0x0/0x60 [bridge]
[ 4593.957005]  [<ffffffffa032f800>] ? __br_forward+0x0/0xc0 [bridge]
[ 4593.957012]  [<ffffffffa032f86d>] __br_forward+0x6d/0xc0 [bridge]
[ 4593.957017]  [<ffffffff813c5d8e>] ? skb_clone+0x3e/0x70
[ 4593.957023]  [<ffffffffa032f462>] deliver_clone+0x32/0x60 [bridge]
[ 4593.957030]  [<ffffffffa032f6b6>] br_flood+0xa6/0xe0 [bridge]
[ 4593.957037]  [<ffffffffa032f800>] ? __br_forward+0x0/0xc0 [bridge]
[ 4593.957044]  [<ffffffffa032f700>] br_flood_forward+0x10/0x20 [bridge]
[ 4593.957052]  [<ffffffffa0330ace>] br_handle_frame_finish+0x23e/0x260 [bridge]
[ 4593.957059]  [<ffffffffa03307ea>] br_handle_frame+0x1aa/0x250 [bridge]
[ 4593.957065]  [<ffffffff81070331>] ? autoremove_wake_function+0x11/0x40
[ 4593.957070]  [<ffffffff813cf537>] __netif_receive_skb+0x187/0x5d0
[ 4593.957076]  [<ffffffff813cfa81>] process_backlog+0x101/0x210
[ 4593.957081]  [<ffffffff813d092d>] net_rx_action+0x10d/0x260
[ 4593.957086]  [<ffffffff81058100>] __do_softirq+0xb0/0x230
[ 4593.957091]  [<ffffffff81009e5c>] call_softirq+0x1c/0x30
[ 4593.957094]  <EOI>  [<ffffffff8100bad5>] ? do_softirq+0x65/0xa0
[ 4593.957102]  [<ffffffff813d3e48>] netif_rx_ni+0x28/0x30
[ 4593.957108]  [<ffffffffa03e2196>] tun_chr_aio_write+0x276/0x540 [tun]
[ 4593.957113]  [<ffffffffa03e1f20>] ? tun_chr_aio_write+0x0/0x540 [tun]
[ 4593.957119]  [<ffffffff8110cd0b>] do_sync_readv_writev+0xcb/0x110
[ 4593.957125]  [<ffffffff8120d593>] ? selinux_file_permission+0xf3/0x150
[ 4593.957130]  [<ffffffff81203081>] ? security_file_permission+0x11/0x20
[ 4593.957135]  [<ffffffff8110dd9a>] do_readv_writev+0xca/0x1f0
[ 4593.957139]  [<ffffffff8111c888>] ? vfs_ioctl+0x38/0xd0
[ 4593.957144]  [<ffffffff8111ceda>] ? do_vfs_ioctl+0x8a/0x610
[ 4593.957148]  [<ffffffff8110defe>] vfs_writev+0x3e/0x60
[ 4593.957153]  [<ffffffff8110e02c>] sys_writev+0x4c/0xb0
[ 4593.957158]  [<ffffffff81008f42>] system_call_fastpath+0x16/0x1b

