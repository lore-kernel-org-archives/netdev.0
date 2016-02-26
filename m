From: =?iso-8859-1?q?Asbj=F8rn_Sloth_T=F8nnesen?= <ast@fiberby.net>
Subject: BUG: ixgbe_select_queue: general protection fault in v4.4.3
Date: Fri, 26 Feb 2016 19:58:05 +0000
Message-ID: <1456516685.9718.5@x201s.roaming.asbjorn.biz>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-ENtCLGtbci6R3Iq+wNNU"
Cc: netdev@vger.kernel.org
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.asbjorn.biz ([185.38.24.25]:49601 "EHLO mail.asbjorn.biz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422625AbcBZUOQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2016 15:14:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-ENtCLGtbci6R3Iq+wNNU
Content-Type: text/plain; charset=UTF-8

Hi,

It seams that v4.4.3 doesn't like having lots of vlans,
the fault occurs shortly after enabling forwarding, with in this case just 350 net_devices defined.

The server is now running a known good v4.3.3. The NIC is a X520-DA2.

The issue quite reproducible, but I will first have some spare hardware to do
further tests on some time next week.


[ 1474.416366] general protection fault: 0000 [#1] SMP 
[ 1474.421399] Modules linked in: xt_nat iptable_nat nf_nat_ipv4 nf_nat crct10dif_pclmul crct10dif_common crc32c_intel cryptd 8021q
[ 1474.433211] CPU: 4 PID: 0 Comm: swapper/4 Not tainted 4.4.3-fbcr1 #144
[ 1474.439746] Hardware name: Supermicro A1SAi/A1SRi, BIOS 1.1a 08/27/2015
[ 1474.446370] task: ffff880276188000 ti: ffff880276190000 task.ti: ffff880276190000
[ 1474.453864] RIP: 0010:[<ffffffff81669901>]  [<ffffffff81669901>] __netdev_pick_tx+0x61/0x140
[ 1474.462337] RSP: 0018:ffff88027fd036d8  EFLAGS: 00010286
[ 1474.467657] RAX: ffff88007dc0ff10 RBX: 0000000000000000 RCX: ffffffff816698a0
[ 1474.474800] RDX: 000000000000000c RSI: ffff88007ce98c00 RDI: ffff88007dd44000
[ 1474.481944] RBP: ffff88027fd03708 R08: ffff8802580c0af0 R09: 00000000000005dc
[ 1474.489093] R10: ec2abb211b00c637 R11: 1b00c63741e7d944 R12: ffff88007dd44000
[ 1474.496233] R13: 0000000000000000 R14: 00000000ffffffff R15: ffff010000003333
[ 1474.503559] FS:  0000000000000000(0000) GS:ffff88027fd00000(0000) knlGS:0000000000000000
[ 1474.511920] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1474.517854] CR2: 00007f2b70dd5095 CR3: 0000000001ad6000 CR4: 00000000001006e0
[ 1474.525131] Stack:
[ 1474.527287]  ffff88025911c400 0000000000000000 ffff88007dd44000 ffff88007ce98c00
[ 1474.535036]  0000000000000000 ffff88007dcbca00 ffff88027fd03718 ffffffff8152dcca
[ 1474.542800]  ffff88027fd03748 ffffffff816707ac 0000000000000000 ffff88007dd44000
[ 1474.550554] Call Trace:
[ 1474.553138]  <IRQ> 
[ 1474.555077]  [<ffffffff8152dcca>] ixgbe_select_queue+0x1a/0x20
[ 1474.561433]  [<ffffffff816707ac>] netdev_pick_tx+0x5c/0xd0
[ 1474.567063]  [<ffffffff816708a0>] __dev_queue_xmit+0x80/0x530
[ 1474.572948]  [<ffffffff81670d5b>] dev_queue_xmit+0xb/0x10
[ 1474.578540]  [<ffffffffa0001543>] vlan_dev_hard_start_xmit+0x93/0x110 [8021q]
[ 1474.585827]  [<ffffffff81670566>] dev_hard_start_xmit+0x256/0x3f0
[ 1474.592055]  [<ffffffff81670cec>] __dev_queue_xmit+0x4cc/0x530
[ 1474.598080]  [<ffffffff81670a68>] ? __dev_queue_xmit+0x248/0x530
[ 1474.604224]  [<ffffffff81670d5b>] dev_queue_xmit+0xb/0x10
[ 1474.609762]  [<ffffffffa0001543>] vlan_dev_hard_start_xmit+0x93/0x110 [8021q]
[ 1474.617088]  [<ffffffff81670566>] dev_hard_start_xmit+0x256/0x3f0
[ 1474.623326]  [<ffffffff816908c5>] ? eth_header+0x25/0xc0
[ 1474.628773]  [<ffffffff81670cec>] __dev_queue_xmit+0x4cc/0x530
[ 1474.634801]  [<ffffffff81670d5b>] dev_queue_xmit+0xb/0x10
[ 1474.640348]  [<ffffffff81678901>] neigh_connected_output+0xc1/0xf0
[ 1474.646666]  [<ffffffff816caa12>] ip_finish_output2+0x122/0x300
[ 1474.652772]  [<ffffffff816ca773>] ip_do_fragment+0x793/0x890
[ 1474.658571]  [<ffffffffa006a7b7>] ? nf_nat_ipv4_fn+0x197/0x1f0 [nf_nat_ipv4]
[ 1474.665757]  [<ffffffff816ca8f0>] ? ip_fragment.constprop.49+0x80/0x80
[ 1474.672422]  [<ffffffff816ca8ae>] ip_fragment.constprop.49+0x3e/0x80
[ 1474.678922]  [<ffffffff816cb85d>] ip_finish_output+0xbd/0x1e0
[ 1474.684865]  [<ffffffff816cb989>] NF_HOOK_COND.part.33.constprop.47+0x9/0x10
[ 1474.692112]  [<ffffffff816cc2b0>] ip_output+0xb0/0xc0
[ 1474.697310]  [<ffffffff816cb7a0>] ? __ip_flush_pending_frames.isra.40+0x80/0x80
[ 1474.704886]  [<ffffffff816c8128>] ip_forward_finish+0x48/0x70
[ 1474.710779]  [<ffffffff816c851d>] ip_forward+0x3cd/0x450
[ 1474.716228]  [<ffffffff816c80e0>] ? ip_frag_mem+0x40/0x40
[ 1474.721765]  [<ffffffff816c63ad>] ip_rcv_finish+0x8d/0x320
[ 1474.727442]  [<ffffffff816c6cf3>] ip_rcv+0x2c3/0x370
[ 1474.732543]  [<ffffffff816c6320>] ? inet_del_offload+0x40/0x40
[ 1474.738516]  [<ffffffff8166e481>] __netif_receive_skb_core+0x6f1/0xa40
[ 1474.745232]  [<ffffffff816f71f2>] ? udp4_gro_receive+0x1c2/0x2e0
[ 1474.755275]  [<ffffffff816fefed>] ? inet_gro_receive+0x18d/0x200
[ 1474.761440]  [<ffffffff8166e7e8>] __netif_receive_skb+0x18/0x60
[ 1474.767499]  [<ffffffff8166e858>] netif_receive_skb_internal+0x28/0x90
[ 1474.774165]  [<ffffffff8166f413>] napi_gro_receive+0xc3/0xf0
[ 1474.780023]  [<ffffffff81530927>] ixgbe_clean_rx_irq+0x507/0x920
[ 1474.786174]  [<ffffffff81531ba1>] ixgbe_poll+0x531/0x8d0
[ 1474.791624]  [<ffffffff8166ece2>] net_rx_action+0x1f2/0x330
[ 1474.797395]  [<ffffffff810596d0>] __do_softirq+0xa0/0x2b0
[ 1474.802937]  [<ffffffff81059a2e>] irq_exit+0x9e/0xa0
[ 1474.808046]  [<ffffffff8100722f>] do_IRQ+0x4f/0xd0
[ 1474.812978]  [<ffffffff81825402>] common_interrupt+0x82/0x82
[ 1474.818823]  <EOI> 
[ 1474.820766]  [<ffffffff816296ee>] ? cpuidle_enter_state+0x11e/0x2c0
[ 1474.827547]  [<ffffffff816296dc>] ? cpuidle_enter_state+0x10c/0x2c0
[ 1474.833951]  [<ffffffff816298b2>] cpuidle_enter+0x12/0x20
[ 1474.839540]  [<ffffffff8108d22a>] cpu_startup_entry+0x29a/0x300
[ 1474.845605]  [<ffffffff81037cbd>] start_secondary+0xed/0xf0
[ 1474.851318] Code: 87 a8 03 00 00 49 89 fc 48 85 c0 0f 84 da 00 00 00 8b 96 ac 00 00 00 83 ea 01 48 8d 44 d0 10 4c 8b 38 4d 85 ff 0f 84 c0 00 00 00 <41> 8b 1f 83 fb 01 0f 84 8d 00 00 00 f6 86 91 00 00 00 30 0f 84 
[ 1474.872330] RIP  [<ffffffff81669901>] __netdev_pick_tx+0x61/0x140
[ 1474.878595]  RSP <ffff88027fd036d8>
[ 1474.882784] ---[ end trace 6a6e1080c88377db ]---
[ 1474.887608] Kernel panic - not syncing: Fatal exception in interrupt



[  217.407517] general protection fault: 0000 [#1] SMP 
[  217.412740] Modules linked in: xt_nat iptable_nat nf_nat_ipv4 nf_nat crct10dif_pclmul crct10dif_common crc32c_intel cryptd 8021q
[  217.425240] CPU: 4 PID: 0 Comm: swapper/4 Not tainted 4.4.3-fbcr1 #144
[  217.431845] Hardware name: Supermicro A1SAi/A1SRi, BIOS 1.1a 08/27/2015
[  217.438537] task: ffff880276188000 ti: ffff880276190000 task.ti: ffff880276190000
[  217.446095] RIP: 0010:[<ffffffff81669901>]  [<ffffffff81669901>] __netdev_pick_tx+0x61/0x140
[  217.454702] RSP: 0018:ffff88027fd036d8  EFLAGS: 00010206
[  217.460085] RAX: ffff88007dc38eb0 RBX: 0000000000000000 RCX: ffffffff816698a0
[  217.467290] RDX: 000000000000000c RSI: ffff88007df6dc00 RDI: ffff88007dd88000
[  217.474501] RBP: ffff88027fd03708 R08: ffff88007c82c1f0 R09: 0000000000000053
[  217.481711] R10: ec2abb211b00c637 R11: 1b00c63741e7d944 R12: ffff88007dd88000
[  217.488921] R13: 0000000000000000 R14: 00000000ffffffff R15: 6b7369646632785c
[  217.496260] FS:  0000000000000000(0000) GS:ffff88027fd00000(0000) knlGS:0000000000000000
[  217.504683] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  217.510635] CR2: 00000000006fafb4 CR3: 0000000001ad6000 CR4: 00000000001006e0
[  217.517978] Stack:
[  217.520194]  ffff880259154000 0000000000000000 ffff88007dd88000 ffff88007df6dc00
[  217.528266]  0000000000000000 ffff880258d1f800 ffff88027fd03718 ffffffff8152dcca
[  217.536333]  ffff88027fd03748 ffffffff816707ac 0000000000000000 ffff88007dd88000
[  217.544412] Call Trace:
[  217.547061]  <IRQ> 
[  217.549067]  [<ffffffff8152dcca>] ixgbe_select_queue+0x1a/0x20
[  217.555491]  [<ffffffff816707ac>] netdev_pick_tx+0x5c/0xd0
[  217.561178]  [<ffffffff816708a0>] __dev_queue_xmit+0x80/0x530
[  217.567130]  [<ffffffff81670d5b>] dev_queue_xmit+0xb/0x10
[  217.572739]  [<ffffffffa0001543>] vlan_dev_hard_start_xmit+0x93/0x110 [8021q]
[  217.580079]  [<ffffffff81670566>] dev_hard_start_xmit+0x256/0x3f0
[  217.586380]  [<ffffffff81670cec>] __dev_queue_xmit+0x4cc/0x530
[  217.592418]  [<ffffffff81670d5b>] dev_queue_xmit+0xb/0x10
[  217.598026]  [<ffffffffa0001543>] vlan_dev_hard_start_xmit+0x93/0x110 [8021q]
[  217.605369]  [<ffffffff81670566>] dev_hard_start_xmit+0x256/0x3f0
[  217.611666]  [<ffffffff816908c5>] ? eth_header+0x25/0xc0
[  217.617183]  [<ffffffff81670cec>] __dev_queue_xmit+0x4cc/0x530
[  217.623217]  [<ffffffff81670d5b>] dev_queue_xmit+0xb/0x10
[  217.628823]  [<ffffffff81678901>] neigh_connected_output+0xc1/0xf0
[  217.635205]  [<ffffffff816caa12>] ip_finish_output2+0x122/0x300
[  217.641329]  [<ffffffff816ca773>] ip_do_fragment+0x793/0x890
[  217.647196]  [<ffffffffa00707b7>] ? nf_nat_ipv4_fn+0x197/0x1f0 [nf_nat_ipv4]
[  217.654454]  [<ffffffff816ca8f0>] ? ip_fragment.constprop.49+0x80/0x80
[  217.661184]  [<ffffffff816ca8ae>] ip_fragment.constprop.49+0x3e/0x80
[  217.667745]  [<ffffffff816cb85d>] ip_finish_output+0xbd/0x1e0
[  217.673699]  [<ffffffff816cb989>] NF_HOOK_COND.part.33.constprop.47+0x9/0x10
[  217.680954]  [<ffffffff816cc2b0>] ip_output+0xb0/0xc0
[  217.686213]  [<ffffffff816cb7a0>] ? __ip_flush_pending_frames.isra.40+0x80/0x80
[  217.693859]  [<ffffffff816c8128>] ip_forward_finish+0x48/0x70
[  217.699810]  [<ffffffff816c851d>] ip_forward+0x3cd/0x450
[  217.705329]  [<ffffffff816c80e0>] ? ip_frag_mem+0x40/0x40
[  217.710937]  [<ffffffff816c63ad>] ip_rcv_finish+0x8d/0x320
[  217.716627]  [<ffffffff816c6cf3>] ip_rcv+0x2c3/0x370
[  217.725691]  [<ffffffff816c6320>] ? inet_del_offload+0x40/0x40
[  217.731727]  [<ffffffff8166e481>] __netif_receive_skb_core+0x6f1/0xa40
[  217.738461]  [<ffffffff816f71f2>] ? udp4_gro_receive+0x1c2/0x2e0
[  217.744673]  [<ffffffff816fefed>] ? inet_gro_receive+0x18d/0x200
[  217.750879]  [<ffffffff8166e7e8>] __netif_receive_skb+0x18/0x60
[  217.757005]  [<ffffffff8166e858>] netif_receive_skb_internal+0x28/0x90
[  217.763742]  [<ffffffff8166f413>] napi_gro_receive+0xc3/0xf0
[  217.769604]  [<ffffffff81530927>] ixgbe_clean_rx_irq+0x507/0x920
[  217.775812]  [<ffffffff81531ba1>] ixgbe_poll+0x531/0x8d0
[  217.781328]  [<ffffffff8166ece2>] net_rx_action+0x1f2/0x330
[  217.787103]  [<ffffffff810596d0>] __do_softirq+0xa0/0x2b0
[  217.792708]  [<ffffffff81059a2e>] irq_exit+0x9e/0xa0
[  217.797873]  [<ffffffff8100722f>] do_IRQ+0x4f/0xd0
[  217.802868]  [<ffffffff81825402>] common_interrupt+0x82/0x82
[  217.808731]  <EOI> 
[  217.810731]  [<ffffffff816296ee>] ? cpuidle_enter_state+0x11e/0x2c0
[  217.817593]  [<ffffffff816296dc>] ? cpuidle_enter_state+0x10c/0x2c0
[  217.824064]  [<ffffffff816298b2>] cpuidle_enter+0x12/0x20
[  217.829672]  [<ffffffff8108d22a>] cpu_startup_entry+0x29a/0x300
[  217.835800]  [<ffffffff81037cbd>] start_secondary+0xed/0xf0
[  217.841576] Code: 87 a8 03 00 00 49 89 fc 48 85 c0 0f 84 da 00 00 00 8b 96 ac 00 00 00 83 ea 01 48 8d 44 d0 10 4c 8b 38 4d 85 ff 0f 84 c0 00 00 00 <41> 8b 1f 83 fb 01 0f 84 8d 00 00 00 f6 86 91 00 00 00 30 0f 84 
[  217.866499] RIP  [<ffffffff81669901>] __netdev_pick_tx+0x61/0x140
[  217.872886]  RSP <ffff88027fd036d8>
[  217.876582] ---[ end trace 7fd512cff4ac64c9 ]---
[  217.881408] Kernel panic - not syncing: Fatal exception in interrupt
~. [terminated ipmitool]



[   39.794334] BUG: unable to handle kernel paging request at ffff8802c9f3ff32
[   39.801551] IP: [<ffffffff81669928>] __netdev_pick_tx+0x88/0x140
[   39.807725] PGD 1e6d067 PUD 0 
[   39.811028] Oops: 0000 [#1] SMP 
[   39.814504] Modules linked in: xt_nat iptable_nat nf_nat_ipv4 nf_nat crct10dif_pclmul crct10dif_common crc32c_intel cryptd 8021q
[   39.827010] CPU: 3 PID: 0 Comm: swapper/3 Not tainted 4.4.3-fbcr1 #144
[   39.833616] Hardware name: Supermicro A1SAi/A1SRi, BIOS 1.1a 08/27/2015
[   39.840306] task: ffff880276137380 ti: ffff880276184000 task.ti: ffff880276184000
[   39.847866] RIP: 0010:[<ffffffff81669928>]  [<ffffffff81669928>] __netdev_pick_tx+0x88/0x140
[   39.856465] RSP: 0018:ffff88027fcc36d8  EFLAGS: 00010202
[   39.861850] RAX: 000000005ba5b061 RBX: 000000002a29ae49 RCX: 0000000096ac50cf
[   39.869063] RDX: 000000005ba5b061 RSI: ffff880259357200 RDI: ffff88027fcc367c
[   39.876274] RBP: ffff88027fcc3708 R08: 0000000056ca5f5d R09: 0000000000000000
[   39.883483] R10: 0000000000000000 R11: ffff8802584fa13c R12: ffff88025b3e0000
[   39.890821] R13: 0000000000000000 R14: 00000000ffffffff R15: ffff880275a0a288
[   39.898163] FS:  0000000000000000(0000) GS:ffff88027fcc0000(0000) knlGS:0000000000000000
[   39.906587] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   39.912536] CR2: ffff8802c9f3ff32 CR3: 0000000001ad6000 CR4: 00000000001006e0
[   39.919873] Stack:
[   39.922087]  ffff880259357200 0000000000000000 ffff88025b3e0000 ffff880259357200
[   39.930161]  0000000000000000 ffff880258d99000 ffff88027fcc3718 ffffffff8152dcca
[   39.938402]  ffff88027fcc3748 ffffffff816707ac 0000000000000000 ffff88025b3e0000
[   39.946480] Call Trace:
[   39.949128]  <IRQ> 
[   39.951135]  [<ffffffff8152dcca>] ixgbe_select_queue+0x1a/0x20
[   39.957560]  [<ffffffff816707ac>] netdev_pick_tx+0x5c/0xd0
[   39.963252]  [<ffffffff816708a0>] __dev_queue_xmit+0x80/0x530
[   39.969198]  [<ffffffff81670d5b>] dev_queue_xmit+0xb/0x10
[   39.974797]  [<ffffffffa0001543>] vlan_dev_hard_start_xmit+0x93/0x110 [8021q]
[   39.982140]  [<ffffffff81670566>] dev_hard_start_xmit+0x256/0x3f0
[   39.988438]  [<ffffffff81670cec>] __dev_queue_xmit+0x4cc/0x530
[   39.994479]  [<ffffffff8165b474>] ? consume_skb+0x34/0x90
[   40.000083]  [<ffffffff81670d5b>] dev_queue_xmit+0xb/0x10
[   40.005686]  [<ffffffffa0001543>] vlan_dev_hard_start_xmit+0x93/0x110 [8021q]
[   40.013027]  [<ffffffff81670566>] dev_hard_start_xmit+0x256/0x3f0
[   40.019325]  [<ffffffff816908c5>] ? eth_header+0x25/0xc0
[   40.024845]  [<ffffffff81670cec>] __dev_queue_xmit+0x4cc/0x530
[   40.030887]  [<ffffffff81670d5b>] dev_queue_xmit+0xb/0x10
[   40.036492]  [<ffffffff81678901>] neigh_connected_output+0xc1/0xf0
[   40.042883]  [<ffffffff816caa12>] ip_finish_output2+0x122/0x300
[   40.049008]  [<ffffffff816ca773>] ip_do_fragment+0x793/0x890
[   40.054873]  [<ffffffffa00827b7>] ? nf_nat_ipv4_fn+0x197/0x1f0 [nf_nat_ipv4]
[   40.062129]  [<ffffffff816ca8f0>] ? ip_fragment.constprop.49+0x80/0x80
[   40.068862]  [<ffffffff816ca8ae>] ip_fragment.constprop.49+0x3e/0x80
[   40.075423]  [<ffffffff816cb85d>] ip_finish_output+0xbd/0x1e0
[   40.081375]  [<ffffffff816cb989>] NF_HOOK_COND.part.33.constprop.47+0x9/0x10
[   40.088631]  [<ffffffff816cc2b0>] ip_output+0xb0/0xc0
[   40.093889]  [<ffffffff816cb7a0>] ? __ip_flush_pending_frames.isra.40+0x80/0x80
[   40.101532]  [<ffffffff816c8128>] ip_forward_finish+0x48/0x70
[   40.111372]  [<ffffffff816c851d>] ip_forward+0x3cd/0x450
[   40.116888]  [<ffffffff816c80e0>] ? ip_frag_mem+0x40/0x40
[   40.122487]  [<ffffffff816c63ad>] ip_rcv_finish+0x8d/0x320
[   40.128183]  [<ffffffff816c6cf3>] ip_rcv+0x2c3/0x370
[   40.133354]  [<ffffffff816c6320>] ? inet_del_offload+0x40/0x40
[   40.139389]  [<ffffffff8166e481>] __netif_receive_skb_core+0x6f1/0xa40
[   40.146122]  [<ffffffff816f71f2>] ? udp4_gro_receive+0x1c2/0x2e0
[   40.152337]  [<ffffffff816fefed>] ? inet_gro_receive+0x18d/0x200
[   40.158548]  [<ffffffff8166e7e8>] __netif_receive_skb+0x18/0x60
[   40.164675]  [<ffffffff8166e858>] netif_receive_skb_internal+0x28/0x90
[   40.171409]  [<ffffffff8166f413>] napi_gro_receive+0xc3/0xf0
[   40.177277]  [<ffffffff81530927>] ixgbe_clean_rx_irq+0x507/0x920
[   40.183492]  [<ffffffff81531ba1>] ixgbe_poll+0x531/0x8d0
[   40.189008]  [<ffffffff8166ece2>] net_rx_action+0x1f2/0x330
[   40.194784]  [<ffffffff810596d0>] __do_softirq+0xa0/0x2b0
[   40.200390]  [<ffffffff81059a2e>] irq_exit+0x9e/0xa0
[   40.205563]  [<ffffffff8100722f>] do_IRQ+0x4f/0xd0
[   40.210562]  [<ffffffff81825402>] common_interrupt+0x82/0x82
[   40.216420]  <EOI> 
[   40.218419]  [<ffffffff816296ee>] ? cpuidle_enter_state+0x11e/0x2c0
[   40.225278]  [<ffffffff816296dc>] ? cpuidle_enter_state+0x10c/0x2c0
[   40.231753]  [<ffffffff816298b2>] cpuidle_enter+0x12/0x20
[   40.237359]  [<ffffffff8108d22a>] cpu_startup_entry+0x29a/0x300
[   40.243486]  [<ffffffff81037cbd>] start_secondary+0xed/0xf0
[   40.249266] Code: c0 00 00 00 41 8b 1f 83 fb 01 0f 84 8d 00 00 00 f6 86 91 00 00 00 30 0f 84 87 00 00 00 8b 86 a4 00 00 00 48 0f af d8 48 c1 eb 20 <41> 0f b7 44 5f 18 41 8b 94 24 8c 03 00 00 39 c2 0f 86 8b 00 00 
[   40.274187] RIP  [<ffffffff81669928>] __netdev_pick_tx+0x88/0x140
[   40.280572]  RSP <ffff88027fcc36d8>
[   40.284264] CR2: ffff8802c9f3ff32
[   40.287784] ---[ end trace 3cc901be4814b235 ]---
[   40.292603] Kernel panic - not syncing: Fatal exception in interrupt
~. [terminated ipmitool]



[   35.828029] BUG: unable to handle kernel paging request at ffff8802d1ed444e
[   35.835255] IP: [<ffffffff81669928>] __netdev_pick_tx+0x88/0x140
[   35.841429] PGD 1e6d067 PUD 0 
[   35.844732] Oops: 0000 [#1] SMP 
[   35.848206] Modules linked in: xt_nat iptable_nat nf_nat_ipv4 nf_nat crct10dif_pclmul crct10dif_common crc32c_intel cryptd 8021q
[   35.860704] CPU: 2 PID: 0 Comm: swapper/2 Not tainted 4.4.3-fbcr1 #144
[   35.867302] Hardware name: Supermicro A1SAi/A1SRi, BIOS 1.1a 08/27/2015
[   35.873994] task: ffff880276136900 ti: ffff880276180000 task.ti: ffff880276180000
[   35.881553] RIP: 0010:[<ffffffff81669928>]  [<ffffffff81669928>] __netdev_pick_tx+0x88/0x140
[   35.890152] RSP: 0018:ffff88027fc836d8  EFLAGS: 00010206
[   35.895535] RAX: 00000000a691cbff RBX: 000000003b5a792b RCX: 00000000488f622d
[   35.902741] RDX: 00000000a691cbff RSI: ffff8802593c2500 RDI: ffff88027fc8367c
[   35.909950] RBP: ffff88027fc83708 R08: 000000005cd77ce7 R09: 0000000000000000
[   35.917160] R10: 0000000000000000 R11: ffff880259db263c R12: ffff88025ad24000
[   35.924499] R13: 0000000000000000 R14: 00000000ffffffff R15: ffff88025b3851e0
[   35.931841] FS:  0000000000000000(0000) GS:ffff88027fc80000(0000) knlGS:0000000000000000
[   35.940263] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   35.946215] CR2: ffff8802d1ed444e CR3: 0000000001ad6000 CR4: 00000000001006e0
[   35.953551] Stack:
[   35.955763]  ffff8802593c2500 0000000000000000 ffff88025ad2400 ffff8802593c2500
[   35.964081]  0000000000000000 ffff88007cdd9600 ffff88027fc83718 ffffffff8152dcca
[   35.972158]  ffff88027fc83748 ffffffff816707ac 0000000000000000 ffff88025ad24000
[   35.980235] Call Trace:
[   35.982882]  <IRQ> 
[   35.984882]  [<ffffffff8152dcca>] ixgbe_select_queue+0x1a/0x20
[   35.991307]  [<ffffffff816707ac>] netdev_pick_tx+0x5c/0xd0
[   35.997001]  [<ffffffff816708a0>] __dev_queue_xmit+0x80/0x530
[   36.002953]  [<ffffffff81670d5b>] dev_queue_xmit+0xb/0x10
[   36.008562]  [<ffffffffa0001543>] vlan_dev_hard_start_xmit+0x93/0x110 [8021q]
[   36.015906]  [<ffffffff81670566>] dev_hard_start_xmit+0x256/0x3f0
[   36.022204]  [<ffffffff81670cec>] __dev_queue_xmit+0x4cc/0x530
[   36.028244]  [<ffffffff8165b474>] ? consume_skb+0x34/0x90
[   36.033849]  [<ffffffff81670d5b>] dev_queue_xmit+0xb/0x10
[   36.039456]  [<ffffffffa0001543>] vlan_dev_hard_start_xmit+0x93/0x110 [8021q]
[   36.046801]  [<ffffffff81670566>] dev_hard_start_xmit+0x256/0x3f0
[   36.053099]  [<ffffffff816908c5>] ? eth_header+0x25/0xc0
[   36.058615]  [<ffffffff81670cec>] __dev_queue_xmit+0x4cc/0x530
[   36.064648]  [<ffffffff81670d5b>] dev_queue_xmit+0xb/0x10
[   36.070249]  [<ffffffff81678901>] neigh_connected_output+0xc1/0xf0
[   36.076636]  [<ffffffff816caa12>] ip_finish_output2+0x122/0x300
[   36.082763]  [<ffffffff816ca773>] ip_do_fragment+0x793/0x890
[   36.088628]  [<ffffffffa00847b7>] ? nf_nat_ipv4_fn+0x197/0x1f0 [nf_nat_ipv4]
[   36.095884]  [<ffffffff816ca8f0>] ? ip_fragment.constprop.49+0x80/0x80
[   36.102618]  [<ffffffff816ca8ae>] ip_fragment.constprop.49+0x3e/0x80
[   36.109176]  [<ffffffff816cb85d>] ip_finish_output+0xbd/0x1e0
[   36.115140]  [<ffffffff816cb989>] NF_HOOK_COND.part.33.constprop.47+0x9/0x10
[   36.122394]  [<ffffffff816cc2b0>] ip_output+0xb0/0xc0
[   36.127663]  [<ffffffff816cb7a0>] ? __ip_flush_pending_frames.isra.40+0x80/0x80
[   36.139272]  [<ffffffff816c8128>] ip_forward_finish+0x48/0x70
[   36.145218]  [<ffffffff816c851d>] ip_forward+0x3cd/0x450
[   36.150731]  [<ffffffff816c80e0>] ? ip_frag_mem+0x40/0x40
[   36.156336]  [<ffffffff816c63ad>] ip_rcv_finish+0x8d/0x320
[   36.162021]  [<ffffffff816c6cf3>] ip_rcv+0x2c3/0x370
[   36.167187]  [<ffffffff816c6320>] ? inet_del_offload+0x40/0x40
[   36.173222]  [<ffffffff8166e481>] __netif_receive_skb_core+0x6f1/0xa40
[   36.179957]  [<ffffffff816f71f2>] ? udp4_gro_receive+0x1c2/0x2e0
[   36.186168]  [<ffffffff816fefed>] ? inet_gro_receive+0x18d/0x200
[   36.192380]  [<ffffffff8166e7e8>] __netif_receive_skb+0x18/0x60
[   36.198500]  [<ffffffff8166e858>] netif_receive_skb_internal+0x28/0x90
[   36.205234]  [<ffffffff8166f413>] napi_gro_receive+0xc3/0xf0
[   36.211102]  [<ffffffff81530927>] ixgbe_clean_rx_irq+0x507/0x920
[   36.217315]  [<ffffffff81531ba1>] ixgbe_poll+0x531/0x8d0
[   36.222836]  [<ffffffff810599f6>] ? irq_exit+0x66/0xa0
[   36.228180]  [<ffffffff8100722f>] ? do_IRQ+0x4f/0xd0
[   36.233348]  [<ffffffff81820001>] ? acpi_os_unmap_iomem+0x4b/0xd4
[   36.239648]  [<ffffffff8166ece2>] net_rx_action+0x1f2/0x330
[   36.245426]  [<ffffffff810596d0>] __do_softirq+0xa0/0x2b0
[   36.251025]  [<ffffffff81059a2e>] irq_exit+0x9e/0xa0
[   36.256189]  [<ffffffff8100722f>] do_IRQ+0x4f/0xd0
[   36.261181]  [<ffffffff81825402>] common_interrupt+0x82/0x82
[   36.267077]  <EOI> 
[   36.269237]  [<ffffffff816296ee>] ? cpuidle_enter_state+0x11e/0x2c0
[   36.276096]  [<ffffffff816296dc>] ? cpuidle_enter_state+0x10c/0x2c0
[   36.282561]  [<ffffffff816298b2>] cpuidle_enter+0x12/0x20
[   36.288160]  [<ffffffff8108d22a>] cpu_startup_entry+0x29a/0x300
[   36.294288]  [<ffffffff81037cbd>] start_secondary+0xed/0xf0
[   36.300068] Code: c0 00 00 00 41 8b 1f 83 fb 01 0f 84 8d 00 00 00 f6 86 91 00 00 00 30 0f 84 87 00 00 00 8b 86 a4 00 00 00 48 0f af d8 48 c1 eb 20 <41> 0f b7 44 5f 18 41 8b 94 24 8c 03 00 00 39 c2 0f 86 8b 00 00 
[   36.324988] RIP  [<ffffffff81669928>] __netdev_pick_tx+0x88/0x140
[   36.331376]  RSP <ffff88027fc836d8>
[   36.335065] CR2: ffff8802d1ed444e
[   36.338586] ---[ end trace 41265291881caf2b ]---
[   36.343405] Kernel panic - not syncing: Fatal exception in interrupt



[   39.661631] BUG: unable to handle kernel paging request at ffff8802aafa2792
[   39.668853] IP: [<ffffffff81669928>] __netdev_pick_tx+0x88/0x140
[   39.675029] PGD 1e6d067 PUD 0 
[   39.678329] Oops: 0000 [#1] SMP 
[   39.681804] Modules linked in: xt_nat iptable_nat nf_nat_ipv4 nf_nat crct10dif_pclmul crct10dif_common crc32c_intel cryptd 8021q
[   39.694304] CPU: 7 PID: 0 Comm: swapper/7 Not tainted 4.4.3-fbcr1 #144
[   39.700910] Hardware name: Supermicro A1SAi/A1SRi, BIOS 1.1a 08/27/2015
[   39.707602] task: ffff880276189f80 ti: ffff88027619c000 task.ti: ffff88027619c000
[   39.715157] RIP: 0010:[<ffffffff81669928>]  [<ffffffff81669928>] __netdev_pick_tx+0x88/0x140
[   39.723759] RSP: 0018:ffff88027fdc36d8  EFLAGS: 00010207
[   39.729151] RAX: 00000000663d2e33 RBX: 000000002817718d RCX: 00000000593957f0
[   39.736372] RDX: 00000000663d2e33 RSI: ffff88025aed4500 RDI: ffff88027fdc367c
r[   39.743588] RBP: ffff88027fdc3708 R08: 00000000255b4c8d R09: 0000000000000000
[   39.750828] R10: 0000000000000000 R11: ffff8802575714bc R12: ffff88007de04000
[   39.758165] R13: 0000000000000000 R14: 00000000ffffffff R15: ffff88025acb4460
[   39.765506] FS:  0000000000000000(0000) GS:ffff88027fdc0000(0000) knlGS:0000000000000000
[   39.773929] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   39.779880] CR2: ffff8802aafa2792 CR3: 0000000001ad6000 CR4: 00000000001006e0
[   39.787222] Stack:
[   39.789439]  ffff88025aed4500 0000000000000000 ffff88007de04000 ffff88025aed4500
[   39.797521]  0000000000000000 ffff88007ced4800 ffff88027fdc3718 ffffffff8152dcca
[   39.805599]  ffff88027fdc3748 ffffffff816707ac 0000000000000000 ffff88007de04000
[   39.813674] Call Trace:
[   39.816321]  <IRQ> 
[   39.818328]  [<ffffffff8152dcca>] ixgbe_select_queue+0x1a/0x20
[   39.824753]  [<ffffffff816707ac>] netdev_pick_tx+0x5c/0xd0
[   39.830445]  [<ffffffff816708a0>] __dev_queue_xmit+0x80/0x530
[   39.836390]  [<ffffffff81670d5b>] dev_queue_xmit+0xb/0x10
[   39.841990]  [<ffffffffa0001543>] vlan_dev_hard_start_xmit+0x93/0x110 [8021q]
[   39.849334]  [<ffffffff81670566>] dev_hard_start_xmit+0x256/0x3f0
[   39.855632]  [<ffffffff81670cec>] __dev_queue_xmit+0x4cc/0x530
[   39.861673]  [<ffffffff8165b474>] ? consume_skb+0x34/0x90
[   39.867275]  [<ffffffff81670d5b>] dev_queue_xmit+0xb/0x10
[   39.872874]  [<ffffffffa0001543>] vlan_dev_hard_start_xmit+0x93/0x110 [8021q]
[   39.880210]  [<ffffffff81670566>] dev_hard_start_xmit+0x256/0x3f0
[   39.886509]  [<ffffffff816908c5>] ? eth_header+0x25/0xc0
[   39.892026]  [<ffffffff81670cec>] __dev_queue_xmit+0x4cc/0x530
[   39.898058]  [<ffffffff81670d5b>] dev_queue_xmit+0xb/0x10
[   39.903656]  [<ffffffff81678901>] neigh_connected_output+0xc1/0xf0
[   39.910106]  [<ffffffff816caa12>] ip_finish_output2+0x122/0x300
[   39.916231]  [<ffffffff816ca773>] ip_do_fragment+0x793/0x890
[   39.922099]  [<ffffffffa00987b7>] ? nf_nat_ipv4_fn+0x197/0x1f0 [nf_nat_ipv4]
e[   39.929384]  [<ffffffff816ca8f0>] ? ip_fragment.constprop.49+0x80/0x80
[   39.936154]  [<ffffffff816ca8ae>] ip_fragment.constprop.49+0x3e/0x80
[   39.942716]  [<ffffffff816cb85d>] ip_finish_output+0xbd/0x1e0
[   39.948668]  [<ffffffff816cb989>] NF_HOOK_COND.part.33.constprop.47+0x9/0x10
[   39.955923]  [<ffffffff816cc2b0>] ip_output+0xb0/0xc0
[   39.961181]  [<ffffffff816cb7a0>] ? __ip_flush_pending_frames.isra.40+0x80/0x80
[   39.972730]  [<ffffffff816c8128>] ip_forward_finish+0x48/0x70
[   39.978678]  [<ffffffff816c851d>] ip_forward+0x3cd/0x450
[   39.984196]  [<ffffffff816c80e0>] ? ip_frag_mem+0x40/0x40
[   39.989796]  [<ffffffff816c63ad>] ip_rcv_finish+0x8d/0x320
[   39.995493]  [<ffffffff816c6cf3>] ip_rcv+0x2c3/0x370
[   40.000660]  [<ffffffff816c6320>] ? inet_del_offload+0x40/0x40
[   40.006695]  [<ffffffff8166e481>] __netif_receive_skb_core+0x6f1/0xa40
[   40.013432]  [<ffffffff816f71f2>] ? udp4_gro_receive+0x1c2/0x2e0
[   40.019644]  [<ffffffff816fefed>] ? inet_gro_receive+0x18d/0x200
[   40.025855]  [<ffffffff8166e7e8>] __netif_receive_skb+0x18/0x60
[   40.031982]  [<ffffffff8166e858>] netif_receive_skb_internal+0x28/0x90
[   40.038718]  [<ffffffff8166f413>] napi_gro_receive+0xc3/0xf0
[   40.044583]  [<ffffffff81530927>] ixgbe_clean_rx_irq+0x507/0x920
[   40.050798]  [<ffffffff81531ba1>] ixgbe_poll+0x531/0x8d0
[   40.056317]  [<ffffffff813a7adc>] ? serial8250_tx_chars+0x14c/0x1a0
[   40.062789]  [<ffffffff8166ece2>] net_rx_action+0x1f2/0x330
[   40.068572]  [<ffffffff810596d0>] __do_softirq+0xa0/0x2b0
[   40.074177]  [<ffffffff81059a2e>] irq_exit+0x9e/0xa0
[   40.079350]  [<ffffffff8100722f>] do_IRQ+0x4f/0xd0
[   40.084351]  [<ffffffff81825402>] common_interrupt+0x82/0x82
[   40.090217]  <EOI> 
[   40.092215]  [<ffffffff816296ee>] ? cpuidle_enter_state+0x11e/0x2c0
[   40.099075]  [<ffffffff816296dc>] ? cpuidle_enter_state+0x10c/0x2c0
[   40.105549]  [<ffffffff816298b2>] cpuidle_enter+0x12/0x20
[   40.111155]  [<ffffffff8108d22a>] cpu_startup_entry+0x29a/0x300
[   40.117281]  [<ffffffff81037cbd>] start_secondary+0xed/0xf0
[   40.123061] Code: c0 00 00 00 41 8b 1f 83 fb 01 0f 84 8d 00 00 00 f6 86 91 00 00 00 30 0f 84 87 00 00 00 8b 86 a4 00 00 00 48 0f af d8 48 c1 eb 20 <41> 0f b7 44 5f 18 41 8b 94 24 8c 03 00 00 39 c2 0f 86 8b 00 00 
[   40.147979] RIP  [<ffffffff81669928>] __netdev_pick_tx+0x88/0x140
[   40.154367]  RSP <ffff88027fdc36d8>
[   40.158058] CR2: ffff8802aafa2792
[   40.161580] ---[ end trace 1a04c8420e596e42 ]---
[   40.161586] BUG: unable to handle kernel paging request at 00000100005e0001
[   40.161594] IP: [<ffffffff81669901>] __netdev_pick_tx+0x61/0x140
[   40.161595] PGD 0 
[   40.161597] Oops: 0000 [#2] SMP 
[   40.161604] Modules linked in: xt_nat iptable_nat nf_nat_ipv4 nf_nat crct10dif_pclmul crct10dif_common crc32c_intel cryptd 8021q
[   40.161607] CPU: 4 PID: 0 Comm: swapper/4 Tainted: G      D         4.4.3-fbcr1 #144
[   40.161608] Hardware name: Supermicro A1SAi/A1SRi, BIOS 1.1a 08/27/2015
[   40.161609] task: ffff880276188000 ti: ffff880276190000 task.ti: ffff880276190000
[   40.161612] RIP: 0010:[<ffffffff81669901>]  [<ffffffff81669901>] __netdev_pick_tx+0x61/0x140
[   40.161614] RSP: 0018:ffff88027fd036d8  EFLAGS: 00010202
[   40.161615] RAX: ffff880275e5c3d0 RBX: 0000000000000000 RCX: ffffffff816698a0
[   40.161616] RDX: 000000000000000c RSI: ffff8802577fa300 RDI: ffff88007de04000
[   40.161617] RBP: ffff88027fd03708 R08: 0000000000018200 R09: ffffffff8165a674
[   40.161618] R10: ec2abb211b00c637 R11: 1b00c63741e7d944 R12: ffff88007de04000
[   40.161619] R13: 0000000000000000 R14: 00000000ffffffff R15: 00000100005e0001
[   40.161620] FS:  0000000000000000(0000) GS:ffff88027fd00000(0000) knlGS:0000000000000000
[   40.161621] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   40.161622] CR2: 00000100005e0001 CR3: 0000000001ad6000 CR4: 00000000001006e0
[   40.161623] Stack:
[   40.161626]  ffff88007dc99400 0000000000000000 ffff88007de04000 ffff8802577fa300
[   40.161628]  0000000000000000 ffff88007ced4800 ffff88027fd03718 ffffffff8152dcca
[   40.161630]  ffff88027fd03748 ffffffff816707ac 0000000000000000 ffff88007de04000
[   40.161631] Call Trace:
[   40.161637]  <IRQ> 
[   40.161637]  [<ffffffff8152dcca>] ixgbe_select_queue+0x1a/0x20
[   40.161640]  [<ffffffff816707ac>] netdev_pick_tx+0x5c/0xd0
[   40.161642]  [<ffffffff816708a0>] __dev_queue_xmit+0x80/0x530
[   40.161644]  [<ffffffff81670d5b>] dev_queue_xmit+0xb/0x10
[   40.161649]  [<ffffffffa0001543>] vlan_dev_hard_start_xmit+0x93/0x110 [8021q]
[   40.161651]  [<ffffffff81670566>] dev_hard_start_xmit+0x256/0x3f0
[   40.161653]  [<ffffffff81670cec>] __dev_queue_xmit+0x4cc/0x530
[   40.161656]  [<ffffffff8165b474>] ? consume_skb+0x34/0x90
[   40.161658]  [<ffffffff81670d5b>] dev_queue_xmit+0xb/0x10
[   40.161661]  [<ffffffffa0001543>] vlan_dev_hard_start_xmit+0x93/0x110 [8021q]
[   40.161663]  [<ffffffff81670566>] dev_hard_start_xmit+0x256/0x3f0
[   40.161666]  [<ffffffff816908c5>] ? eth_header+0x25/0xc0
[   40.161668]  [<ffffffff81670cec>] __dev_queue_xmit+0x4cc/0x530
[   40.161670]  [<ffffffff81670d5b>] dev_queue_xmit+0xb/0x10
[   40.161673]  [<ffffffff81678901>] neigh_connected_output+0xc1/0xf0
[   40.161676]  [<ffffffff816caa12>] ip_finish_output2+0x122/0x300
[   40.161678]  [<ffffffff816ca773>] ip_do_fragment+0x793/0x890
[   40.161681]  [<ffffffffa00987b7>] ? nf_nat_ipv4_fn+0x197/0x1f0 [nf_nat_ipv4]
[   40.161683]  [<ffffffff816ca8f0>] ? ip_fragment.constprop.49+0x80/0x80
[   40.161685]  [<ffffffff816ca8ae>] ip_fragment.constprop.49+0x3e/0x80
[   40.161687]  [<ffffffff816cb85d>] ip_finish_output+0xbd/0x1e0
[   40.161689]  [<ffffffff816cb989>] NF_HOOK_COND.part.33.constprop.47+0x9/0x10
[   40.161691]  [<ffffffff816cc2b0>] ip_output+0xb0/0xc0
[   40.161694]  [<ffffffff816cb7a0>] ? __ip_flush_pending_frames.isra.40+0x80/0x80
[   40.161696]  [<ffffffff816c8128>] ip_forward_finish+0x48/0x70
[   40.161698]  [<ffffffff816c851d>] ip_forward+0x3cd/0x450
[   40.161700]  [<ffffffff816c80e0>] ? ip_frag_mem+0x40/0x40
[   40.161701]  [<ffffffff816c63ad>] ip_rcv_finish+0x8d/0x320
[   40.161703]  [<ffffffff816c6cf3>] ip_rcv+0x2c3/0x370
[   40.161705]  [<ffffffff816c6320>] ? inet_del_offload+0x40/0x40
[   40.161708]  [<ffffffff8166e481>] __netif_receive_skb_core+0x6f1/0xa40
[   40.161710]  [<ffffffff816f71f2>] ? udp4_gro_receive+0x1c2/0x2e0
[   40.161713]  [<ffffffff816fefed>] ? inet_gro_receive+0x18d/0x200
[   40.161715]  [<ffffffff8166e7e8>] __netif_receive_skb+0x18/0x60
[   40.161717]  [<ffffffff8166e858>] netif_receive_skb_internal+0x28/0x90
[   40.161719]  [<ffffffff8166f413>] napi_gro_receive+0xc3/0xf0
[   40.161721]  [<ffffffff81530927>] ixgbe_clean_rx_irq+0x507/0x920
[   40.161724]  [<ffffffff81531ba1>] ixgbe_poll+0x531/0x8d0
[   40.161727]  [<ffffffff810599f6>] ? irq_exit+0x66/0xa0
[   40.161730]  [<ffffffff8100722f>] ? do_IRQ+0x4f/0xd0
[   40.161733]  [<ffffffff81820001>] ? acpi_os_unmap_iomem+0x4b/0xd4
[   40.161735]  [<ffffffff8166ece2>] net_rx_action+0x1f2/0x330
[   40.161737]  [<ffffffff810596d0>] __do_softirq+0xa0/0x2b0
[   40.161740]  [<ffffffff81059a2e>] irq_exit+0x9e/0xa0
[   40.161741]  [<ffffffff8100722f>] do_IRQ+0x4f/0xd0
[   40.161744]  [<ffffffff81825402>] common_interrupt+0x82/0x82
[   40.161748]  <EOI> 
[   40.161748]  [<ffffffff816296ee>] ? cpuidle_enter_state+0x11e/0x2c0
[   40.161750]  [<ffffffff816296dc>] ? cpuidle_enter_state+0x10c/0x2c0
[   40.161752]  [<ffffffff816298b2>] cpuidle_enter+0x12/0x20
[   40.161755]  [<ffffffff8108d22a>] cpu_startup_entry+0x29a/0x300
[   40.161758]  [<ffffffff81037cbd>] start_secondary+0xed/0xf0
[   40.161782] Code: 87 a8 03 00 00 49 89 fc 48 85 c0 0f 84 da 00 00 00 8b 96 ac 00 00 00 83 ea 01 48 8d 44 d0 10 4c 8b 38 4d 85 ff 0f 84 c0 00 00 00 <41> 8b 1f 83 fb 01 0f 84 8d 00 00 00 f6 86 91 00 00 00 30 0f 84 
[   40.161785] RIP  [<ffffffff81669901>] __netdev_pick_tx+0x61/0x140
[   40.161785]  RSP <ffff88027fd036d8>
[   40.161786] CR2: 00000100005e0001
[   40.161790] ---[ end trace 1a04c8420e596e43 ]---
[   40.161791] Kernel panic - not syncing: Fatal exception in interrupt
[   41.221709] Shutting down cpus with NMI

-- 
Best regards
Asbjørn Sloth Tønnesen
Network Engineer
Fiberby ApS - AS42541

--=-ENtCLGtbci6R3Iq+wNNU--
