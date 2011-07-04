From: TB <lkml@techboom.com>
Subject: divide error: 0000, in bictcp_cong_avoid, kernel 2.6.39
Date: Mon, 04 Jul 2011 10:23:00 -0400
Message-ID: <4E11CCC4.2010404@techboom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s040.panelboxmanager.com ([72.55.186.60]:43742 "EHLO
	s040.panelboxmanager.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754319Ab1GDPDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 11:03:06 -0400
Received: from [68.67.52.186] (helo=[192.168.100.149])
	by s040.panelboxmanager.com with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.69)
	(envelope-from <lkml@techboom.com>)
	id 1Qdk43-000grq-Pw
	for netdev@vger.kernel.org; Mon, 04 Jul 2011 10:23:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[1819042.176427] divide error: 0000 [#1] SMP

[1819042.176462] last sysfs file:
/sys/devices/pci0000:00/0000:00:1f.2/host6/scsi_host/host6/proc_name
[1819042.176511] CPU 0

[1819042.176518] Modules linked in:
 i2c_i801
 i2c_core
 evdev
 button
 [last unloaded: scsi_wait_scan]

[1819042.176600]
[1819042.176621] Pid: 14810, comm: nginx Not tainted 2.6.39 #1
 Supermicro X8DT3
/X8DT3

[1819042.176676] RIP: 0010:[<ffffffff81516499>]
 [<ffffffff81516499>] bictcp_cong_avoid+0x281/0x2bc
[1819042.176731] RSP: 0018:ffff88043fc03a50  EFLAGS: 00010246
[1819042.176758] RAX: 0000000000000000 RBX: ffff88001f84fa90 RCX:
0000000000000000
[1819042.176803] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
000000000000c170
[1819042.176847] RBP: 0000000000000025 R08: 00000000000000b5 R09:
00000000000068f2
[1819042.176892] R10: ffff88001e914c00 R11: 0000000000007f0a R12:
ffff88001f84f6c0
[1819042.176936] R13: 000000011b24cfc6 R14: 0000000000010015 R15:
000000000000003d
[1819042.176980] FS: 00007fa411dd4700(0000) GS:ffff88043fc00000(0000)
knlGS:0000000000000000
[1819042.177027] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[1819042.177055] CR2: 00000000058f8f76 CR3: 000000011c252000 CR4:
00000000000006f0
[1819042.177099] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[1819042.177143] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
[1819042.177188] Process nginx (pid: 14810, threadinfo ffff8806ce9a0000,
task ffff88042f42f620)
[1819042.177234] Stack:
[1819042.177255]  ffff88001f84f9d0
 ffffffff81801620
 0000000000000282
 ffffffff81038dae

[1819042.177311]  0000000000000b0c
 ffffffff81054aa5
 ffff8800864cddc0
 ffff88001f84f6c0

[1819042.177368]  ffffffff81801620
 0000000000000406
 ffff88001f84f6c0
 ffffffff81801620

[1819042.177424] Call Trace:
[1819042.177446]  <IRQ>

[1819042.177474]  [<ffffffff81038dae>] ? ns_to_timeval+0x9/0x27
[1819042.177503]  [<ffffffff81054aa5>] ? getnstimeofday+0x55/0xaf
[1819042.177534]  [<ffffffff814ed04d>] ? tcp_ack+0x18b5/0x1a89
[1819042.177563]  [<ffffffff814ed84a>] ? tcp_rcv_established+0xd1/0xa13
[1819042.177593]  [<ffffffff814f5a5f>] ? tcp_v4_do_rcv+0x1b2/0x382
[1819042.177623]  [<ffffffff814d2774>] ? nf_iterate+0x40/0x78
[1819042.177651]  [<ffffffff814f60bc>] ? tcp_v4_rcv+0x48d/0x7a6
[1819042.177680]  [<ffffffff814da2d6>] ? ip_local_deliver_finish+0xae/0x13f
[1819042.177711]  [<ffffffff814b6179>] ? __netif_receive_skb+0x33a/0x369
[1819042.177741]  [<ffffffff814b7a3d>] ? netif_receive_skb+0x67/0x6d
[1819042.177771]  [<ffffffff814b7fb5>] ? napi_gro_receive+0x9d/0xab
[1819042.177800]  [<ffffffff814b7b12>] ? napi_skb_finish+0x1c/0x31
[1819042.177829]  [<ffffffff813edd3c>] ? igb_poll+0x7d5/0xb2e
[1819042.177859]  [<ffffffff81040c8c>] ? lock_timer_base+0x26/0x4c
[1819042.177888]  [<ffffffff814b80f2>] ? net_rx_action+0xa7/0x212
[1819042.177924]  [<ffffffff8103a43b>] ? __do_softirq+0xbe/0x184
[1819042.177954]  [<ffffffff8156d18c>] ? call_softirq+0x1c/0x30
[1819042.177983]  [<ffffffff81003ec9>] ? do_softirq+0x31/0x63
[1819042.178011]  [<ffffffff8103a1bc>] ? irq_exit+0x3f/0x9e
[1819042.178039]  [<ffffffff810037df>] ? do_IRQ+0x98/0xae
[1819042.178068]  [<ffffffff8156ba13>] ? common_interrupt+0x13/0x13
[1819042.178095]  <EOI>

[1819042.178122]  [<ffffffff812c07b2>] ? blk_finish_plug+0xb/0x2a
[1819042.178151]  [<ffffffff812d1e0d>] ? copy_user_generic_string+0x2d/0x40
[1819042.178184]  [<ffffffff8108785a>] ? file_read_actor+0xb9/0x136
[1819042.178213]  [<ffffffff81089243>] ? generic_file_aio_read+0x3a3/0x606
[1819042.178246]  [<ffffffff814a7f05>] ? sock_alloc_inode+0xaa/0xaa
[1819042.178278]  [<ffffffff81239eaa>] ? xfs_file_aio_read+0x219/0x26d
[1819042.178312]  [<ffffffff810c6bda>] ? do_sync_read+0xb0/0xf2
[1819042.178344]  [<ffffffff810c7072>] ? do_readv_writev+0x15f/0x174
[1819042.178377]  [<ffffffff810c7598>] ? vfs_read+0xaa/0x12e
[1819042.178405]  [<ffffffff810c7673>] ? sys_pread64+0x57/0x77
[1819042.178434]  [<ffffffff8156c03b>] ? system_call_fastpath+0x16/0x1b
[1819042.178463] Code:
29 e9 31 d2 89 e8 f7 f1 41 39 84 24 d0 03 00 00 76 08 41 89 84 24 d0 03
00 00
41 8b 84 24 d0 03 00 00 31 d2 c1 e0 04 0f b7 4b 2c f7>
f1 ba 01 00 00 00 85 c0 0f 45 d0 41 89 94 24 d0 03 00 00 41

[1819042.178736] RIP
 [<ffffffff81516499>] bictcp_cong_avoid+0x281/0x2bc
[1819042.178769]  RSP <ffff88043fc03a50>
[1819042.179048] ---[ end trace ebccdce72afe641d ]---
[1819042.179106] Kernel panic - not syncing: Fbictcp_cong_avoidatal
exception in interrupt
[1819042.179166] Pid: 14810, comm: nginx Tainted: G      D
2.6.39bakhoss #1
[1819042.179226] Call Trace:
[1819042.179279]  <IRQ>
 [<ffffffff81569594>] ? panic+0x9d/0x1a0
[1819042.179374]  [<ffffffff81004f80>] ? oops_end+0x61/0xac
[1819042.179432]  [<ffffffff8156ba13>] ? common_interrupt+0x13/0x13
[1819042.179497]  [<ffffffff810353da>] ? kmsg_dump+0x46/0xec
[1819042.179555]  [<ffffffff81004fbe>] ? oops_end+0x9f/0xac
[1819042.179613]  [<ffffffff8100313c>] ? do_divide_error+0x7f/0x89
[1819042.179672]  [<ffffffff81516499>] ? bictcp_cong_avoid+0x281/0x2bc
[1819042.179732]  [<ffffffff814b8a67>] ? dev_hard_start_xmit+0x3fc/0x581
[1819042.179793]  [<ffffffff814dc310>] ? ip_options_build+0x149/0x149
[1819042.179852]  [<ffffffff8156ceb5>] ? divide_error+0x15/0x20
[1819042.179911]  [<ffffffff81516499>] ? bictcp_cong_avoid+0x281/0x2bc
[1819042.179971]  [<ffffffff81038dae>] ? ns_to_timeval+0x9/0x27
[1819042.180030]  [<ffffffff81054aa5>] ? getnstimeofday+0x55/0xaf
[1819042.180089]  [<ffffffff814ed04d>] ? tcp_ack+0x18b5/0x1a89
[1819042.180150]  [<ffffffff814ed84a>] ? tcp_rcv_established+0xd1/0xa13
[1819042.180210]  [<ffffffff814f5a5f>] ? tcp_v4_do_rcv+0x1b2/0x382
[1819042.180270]  [<ffffffff814d2774>] ? nf_iterate+0x40/0x78
[1819042.180328]  [<ffffffff814f60bc>] ? tcp_v4_rcv+0x48d/0x7a6
[1819042.180394]  [<ffffffff814da2d6>] ? ip_local_deliver_finish+0xae/0x13f
[1819042.180457]  [<ffffffff814b6179>] ? __netif_receive_skb+0x33a/0x369
[1819042.180518]  [<ffffffff814b7a3d>] ? netif_receive_skb+0x67/0x6d
[1819042.180581]  [<ffffffff814b7fb5>] ? napi_gro_receive+0x9d/0xab
[1819042.180646]  [<ffffffff814b7b12>] ? napi_skb_finish+0x1c/0x31
[1819042.180706]  [<ffffffff813edd3c>] ? igb_poll+0x7d5/0xb2e
[1819042.180765]  [<ffffffff81040c8c>] ? lock_timer_base+0x26/0x4c
[1819042.180825]  [<ffffffff814b80f2>] ? net_rx_action+0xa7/0x212
[1819042.180884]  [<ffffffff8103a43b>] ? __do_softirq+0xbe/0x184
[1819042.180944]  [<ffffffff8156d18c>] ? call_softirq+0x1c/0x30
[1819042.181003]  [<ffffffff81003ec9>] ? do_softirq+0x31/0x63
[1819042.181061]  [<ffffffff8103a1bc>] ? irq_exit+0x3f/0x9e
[1819042.181118]  [<ffffffff810037df>] ? do_IRQ+0x98/0xae
[1819042.181176]  [<ffffffff8156ba13>] ? common_interrupt+0x13/0x13
[1819042.181235]  <EOI>
 [<ffffffff812c07b2>] ? blk_finish_plug+0xb/0x2a
[1819042.181330]  [<ffffffff812d1e0d>] ? copy_user_generic_string+0x2d/0x40
[1819042.181397]  [<ffffffff8108785a>] ? file_read_actor+0xb9/0x136
[1819042.181456]  [<ffffffff81089243>] ? generic_file_aio_read+0x3a3/0x606
[1819042.181517]  [<ffffffff814a7f05>] ? sock_alloc_inode+0xaa/0xaa
[1819042.181577]  [<ffffffff81239eaa>] ? xfs_file_aio_read+0x219/0x26d
[1819042.181637]  [<ffffffff810c6bda>] ? do_sync_read+0xb0/0xf2
[1819042.181696]  [<ffffffff810c7072>] ? do_readv_writev+0x15f/0x174
[1819042.181755]  [<ffffffff810c7598>] ? vfs_read+0xaa/0x12e
[1819042.181813]  [<ffffffff810c7673>] ? sys_pread64+0x57/0x77
[1819042.181873]  [<ffffffff8156c03b>] ? system_call_fastpath+0x16/0x1b
