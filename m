From: Michele Baldessari <michele@acksyn.org>
Subject: 3.11rc7 net/ipv6 addrlabel OOPS
Date: Mon, 2 Sep 2013 22:31:28 +0100
Message-ID: <20130902213128.GB14301@marquez.int.rhx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S.  Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palahniuk.acksyn.org ([5.9.7.26]:59157 "EHLO
	palahniuk.acksyn.org" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S932295Ab3IBVjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Sep 2013 17:39:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

with the latest linux master git tree from Linus
(248d296d6d9df384996c2ed95676b367d876d48c - 2 Sep) I can reproduceably oops 
the kernel with the following commands:
ip addrlabel flush
ip addrlabel add prefix ::1/128              label 0
ip addrlabel add prefix ::/0                 label 1

The backtrace is:
[   15.129204] BUG: unable to handle kernel NULL pointer dereference at 0000000000000028
[   15.129220] IP: [<ffffffff815f3720>] ip6addrlbl_add+0x210/0x370
[   15.129235] PGD 114f64067 PUD 115bdc067 PMD 0 
[   15.129248] Oops: 0000 [#1] SMP 
[   15.129257] Modules linked in: nf_conntrack_netbios_ns
nf_conntrack_broadcast ipt_MASQUERADE ip6table_nat nf_nat_ipv6
ip6table_mangle ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat
nf_nat_ipv4 nf_nat iptable_mangle nf_conntrack_ipv4 nf_defrag_ipv4
xt_conntrack nf_conntrack ebtable_filter ebtables ip6table_filter
ip6_tables snd_hda_intel snd_hda_codec snd_hwdep snd_seq snd_seq_device
snd_pcm snd_page_alloc snd_timer joydev pcspkr serio_raw virtio_balloon
microcode snd soundcore i2c_piix4 mperf xfs libcrc32c qxl drm_kms_helper
ttm drm virtio_net virtio_blk i2c_core ata_generic pata_acpi floppy
[   15.129401] CPU: 3 PID: 1122 Comm: ip Not tainted 3.11.0-rc7+ #2
[   15.129407] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   15.129414] task: ffff88011481eac0 ti: ffff8801149ac000 task.ti: ffff8801149ac000
[   15.129422] RIP: 0010:[<ffffffff815f3720>]  [<ffffffff815f3720>] ip6addrlbl_add+0x210/0x370
[   15.129434] RSP: 0018:ffff8801149ad9c8  EFLAGS: 00010246
[   15.129440] RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffff88011453b900
[   15.129447] RDX: 0000000000000007 RSI: 0000000000000000 RDI: 0000000000000246
[   15.129455] RBP: ffff8801149ada18 R08: 0000000000000000 R09: 00000000000002a1
[   15.129578] R10: 00000000127c7901 R11: ffffffff81855500 R12: ffff880119baaa28
[   15.129700] R13: 0000000000000000 R14: 0000000000000000 R15: ffff880114e34ea0
[   15.129828] FS:  00007f4449519740(0000) GS:ffff88011fd80000(0000) knlGS:0000000000000000
[   15.129952] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   15.130125] CR2: 0000000000000028 CR3: 0000000114280000 CR4: 00000000000006e0
[   15.130133] Stack:
[   15.130133]  0000000000000000 0000000000000000 00000000149ada18 ffffffff81cbd940
[   15.130133]  0000000000000001 ffff880119baaa00 ffffffff81cbd940 0000000000000038
[   15.130133]  ffff880119baaa24 ffff880119baaa28 ffff8801149ada98 ffffffff815f3b3e
[   15.130133] Call Trace:
[   15.130133]  [<ffffffff815f3b3e>] ip6addrlbl_newdel+0x24e/0x2d0
[   15.130133]  [<ffffffff8129843e>] ? selinux_capable+0x2e/0x40
[   15.130133]  [<ffffffff8154e669>] rtnetlink_rcv_msg+0x99/0x260
[   15.130133]  [<ffffffff812956c5>] ? sock_has_perm+0x75/0x90
[   15.130133]  [<ffffffff8154e5d0>] ? rtnetlink_rcv+0x30/0x30
[   15.130133]  [<ffffffff8156d0a9>] netlink_rcv_skb+0xa9/0xc0
[   15.130133]  [<ffffffff8154e5c8>] rtnetlink_rcv+0x28/0x30
[   15.130133]  [<ffffffff8156c6fd>] netlink_unicast+0xdd/0x190
[   15.130133]  [<ffffffff8156caaf>] netlink_sendmsg+0x2ff/0x740
[   15.130133]  [<ffffffff815296b9>] sock_sendmsg+0x99/0xd0
[   15.130133]  [<ffffffff812f848e>] ? radix_tree_lookup_slot+0xe/0x10
[   15.130133]  [<ffffffff81529aac>] ___sys_sendmsg+0x36c/0x380
[   15.130133]  [<ffffffff81164e11>] ? handle_mm_fault+0x291/0x660
[   15.130133]  [<ffffffff81646f74>] ? __do_page_fault+0x1f4/0x510
[   15.130133]  [<ffffffff8156c096>] ? netlink_autobind.isra.43+0x106/0x170
[   15.130133]  [<ffffffff8152852f>] ? move_addr_to_user+0xaf/0xd0
[   15.130133]  [<ffffffff8152862c>] ? SYSC_getsockname+0xdc/0xf0
[   15.130133]  [<ffffffff8152a892>] __sys_sendmsg+0x42/0x80
[   15.130133]  [<ffffffff8152a8e2>] SyS_sendmsg+0x12/0x20
[   15.130133]  [<ffffffff8164b9d9>] system_call_fastpath+0x16/0x1b
[   15.130133] Code: 30 83 05 0f a7 9e 00 01 31 db 80 05 02 a7 9e 00 01
31 c0 85 db 0f 85 e0 00 00 00 48 83 c4 28 5b 41 5c 41 5d 41 5e 41 5f 5d
c3 90 <48> 8b 04 25 28 00 00 00 49 8d 57 28 49 c7 47 30 28 00 00 00 49 
[   15.130133] RIP  [<ffffffff815f3720>] ip6addrlbl_add+0x210/0x370
[   15.130133]  RSP <ffff8801149ad9c8>
[   15.130133] CR2: 0000000000000028

I believe I've bisected it down to (although it might very well be that
this patch just brought the root issue to surface):
b67bfe0 - 2013-02-27 - hlist: drop the node parameter from iterators

cheers,
Michele
-- 
Michele Baldessari            <michele@acksyn.org>
C2A5 9DA3 9961 4FFB E01B  D0BC DDD4 DCCB 7515 5C6D
