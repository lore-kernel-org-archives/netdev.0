From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [linux-next] NULL pointer dereference in rt6_fill_node
Date: Mon, 30 Jan 2017 06:07:52 -0800
Message-ID: <1485785272.6360.94.camel@edumazet-glaptop3.roam.corp.google.com>
References: <201701302036.GGH60927.MFJLFOOStHOQFV@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34972 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753590AbdA3OIG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 09:08:06 -0500
Received: by mail-pf0-f194.google.com with SMTP id f144so23383728pfa.2
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 06:07:53 -0800 (PST)
In-Reply-To: <201701302036.GGH60927.MFJLFOOStHOQFV@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-01-30 at 20:36 +0900, Tetsuo Handa wrote:
> Hello.
> 
> I'm hitting this with linux-next-20170125. Is this known?
> ----------------------------------------
> [  OK  ] Started Show Plymouth Reboot Screen.
> 
> [  OK  ] Stopped PostgreSQL database server.
> 
> [  OK  ] Stopped Dynamic System Tuning Daemon.
> 
> [  OK  ] Stopped target Network.
> 
>          Stopping LSB: Bring up/down networking...
> 
> [  828.169782] BUG: unable to handle kernel NULL pointer dereference at 00000000000002a4
> [  828.172557] IP: rt6_fill_node.isra.60+0x181/0x5c0
> [  828.174211] PGD 0
> [  828.174212]
> [  828.175467] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
> [  828.177068] Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp vmw_balloon pcspkr vmw_vmci i2c_piix4 shpchp ip_tables xfs libcrc32c sr_mod cdrom ata_generic sd_mod pata_acpi serio_raw vmwgfx drm_kms_helper syscopyarea sysfillrect sysimgblt mptspi fb_sys_fops scsi_transport_spi ttm ata_piix mptscsih drm i2c_core e1000 mptbase libata
> [  828.200197] CPU: 3 PID: 539 Comm: NetworkManager Not tainted 4.10.0-rc5-next-20170125+ #45
> [  828.203094] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
> [  828.206835] task: ffff88006f984100 task.stack: ffffc90005afc000
> [  828.208934] RIP: 0010:rt6_fill_node.isra.60+0x181/0x5c0
> [  828.210701] RSP: 0018:ffffc90005aff938 EFLAGS: 00010246
> [  828.212485] RAX: 0000000000000000 RBX: ffff88006c71ae00 RCX: 0000000000000000
> [  828.214933] RDX: 0000000000000000 RSI: ffffc90005aff95c RDI: ffff880071773ee0
> [  828.217394] RBP: ffffc90005aff9e0 R08: 0000000000000000 R09: 0000000000000004
> [  828.219945] R10: ffff880071773ee4 R11: 0000000000000000 R12: ffff880071983f00
> [  828.222381] R13: 0000000000000000 R14: 0000000000000000 R15: ffff880071773ec0
> [  828.224920] FS:  00007ffaa9733940(0000) GS:ffff880075800000(0000) knlGS:0000000000000000
> [  828.227664] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  828.229670] CR2: 00000000000002a4 CR3: 0000000071269000 CR4: 00000000001406e0
> [  828.232149] Call Trace:
> [  828.232998]  ? slab_kernel_map+0xa0/0x130
> [  828.234468]  rt6_dump_route+0x60/0x70
> [  828.235717]  fib6_dump_node+0x2e/0x60
> [  828.237005]  fib6_walk_continue+0x124/0x140
> [  828.238425]  fib6_walk+0x64/0x90
> [  828.239567]  ? _raw_read_lock_bh+0x6e/0x80
> [  828.240962]  inet6_dump_fib+0x237/0x370
> [  828.242309]  ? inet6_dump_fib+0x4b/0x370
> [  828.243646]  netlink_dump+0x126/0x280
> [  828.244963]  __netlink_dump_start+0x16f/0x210
> [  828.246464]  ? fib6_flush_trees+0x40/0x40
> [  828.247848]  rtnetlink_rcv_msg+0x13b/0x230
> [  828.249275]  ? fib6_flush_trees+0x40/0x40
> [  828.250641]  ? rtnl_newlink+0x880/0x880
> [  828.252021]  netlink_rcv_skb+0x99/0xb0
> [  828.253399]  rtnetlink_rcv+0x25/0x30
> [  828.254646]  netlink_unicast+0x16d/0x200
> [  828.255982]  netlink_sendmsg+0x36b/0x390
> [  828.257348]  ___sys_sendmsg+0x1c9/0x2c0
> [  828.259271]  ? ___cache_free+0x14a/0x5b0
> [  828.261112]  ? __fget+0x117/0x210
> [  828.262777]  ? expand_files+0x2e0/0x2e0
> [  828.264657]  __sys_sendmsg+0x4f/0x90
> [  828.266399]  SyS_sendmsg+0xd/0x20
> [  828.268042]  do_syscall_64+0x67/0x1f0
> [  828.269810]  entry_SYSCALL64_slow_path+0x25/0x25
> [  828.271885] RIP: 0033:0x7ffaa7f639fd
> [  828.273594] RSP: 002b:00007ffc0e0c13b0 EFLAGS: 00000293 ORIG_RAX: 000000000000002e
> [  828.276704] RAX: ffffffffffffffda RBX: 000055f219737bd0 RCX: 00007ffaa7f639fd
> [  828.279712] RDX: 0000000000000000 RSI: 00007ffc0e0c1460 RDI: 000000000000000c
> [  828.282623] RBP: 000055f219737ae0 R08: 0000000000000001 R09: 0000000000001000
> [  828.286019] R10: 0000000000000063 R11: 0000000000000293 R12: 000055f21977e4f0
> [  828.288921] R13: 00007ffc0e0c1460 R14: 0000000000000000 R15: 000055f21977e4f0
> [  828.291766] Code: c7 47 18 00 00 00 00 48 8b 43 18 48 8b 50 48 83 e2 01 74 08 48 8b 40 48 a8 04 74 21 41 c7 47 18 10 00 00 00 48 8b 83 58 01 00 00 <8b> 88 a4 02 00 00 85 c9 74 08 41 c7 47 18 11 00 00 00 41 c6 47
> [  828.299024] RIP: rt6_fill_node.isra.60+0x181/0x5c0 RSP: ffffc90005aff938
> [  828.301732] CR2: 00000000000002a4

Hi Tetsuo, thanks for the report.

Fix was sent few days back  : 
https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=1f17e2f2c8a8be3430813119fa7b633398f6185b
