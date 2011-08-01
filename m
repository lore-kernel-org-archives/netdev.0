From: Rustam Afanasyev <cpulinker@yandex.ru>
Subject: Re: [Bugme-new] [Bug 39742] New: 2.6.39.3 crash and hangs in 1-2
 minutes. Still have traps.
Date: Mon, 01 Aug 2011 15:20:11 +0400
Message-ID: <4E368BEB.70301@yandex.ru>
References: <bug-39742-10286@https.bugzilla.kernel.org/> <20110722144214.577718f0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward17.mail.yandex.net ([95.108.253.142]:58566 "EHLO
	forward17.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751993Ab1HALbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 07:31:25 -0400
In-Reply-To: <20110722144214.577718f0.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With applied patch from xeb 
(http://www.spinics.net/lists/netdev/msg170766.html)
there isn't hangs any more. Panics is still occurs. They only occur much 
less frequently. And seems it's different place.
Here it is.
1 was like:
[ 1582.319303] ------------[ cut here ]------------
[ 1582.323205] kernel BUG at include/linux/skbuff.h:1189!
[ 1582.323205] invalid opcode: 0000 [#1] SMP
[ 1582.323205] last sysfs file: /sys/devices/virtual/net/ppp168/uevent
[ 1582.323205] CPU 0
[ 1582.323205] Modules linked in: cls_fw sch_sfq arc4 ecb ppp_mppe 
act_mirred act_skbedit cls_u32 sch_ingress l2tp_ppp l2d
[ 1582.323205]
[ 1582.598100] Pid: 0, comm: swapper Not tainted 2.6.39-std-def-alt3 #1 
ASUS RS100-E4/PI2/P5M2-M/RS100-E4
[ 1582.616208] RIP: 0010:[<ffffffff8134a94b>]  [<ffffffff8134a94b>] 
skb_pull+0x2b/0x30
[ 1582.616208] RSP: 0018:ffff88011fc03b20  EFLAGS: 00010293
[ 1582.616208] RAX: 0000000000000247 RBX: ffff880117ac2880 RCX: 
0000000000000027
[ 1582.616208] RDX: 0000000000000027 RSI: 0000000000000002 RDI: 
ffff880117ac2880
[ 1582.698595] RBP: ffff88011fc03b20 R08: 0000000000000228 R09: 
000000000000000c
[ 1582.698595] R10: 0000000000000240 R11: 0000000000000001 R12: 
ffff880118f00800
[ 1582.698595] R13: ffff8801176a086e R14: 000000000000002f R15: 
ffff880115346000
[ 1582.698595] FS:  0000000000000000(0000) GS:ffff88011fc00000(0000) 
knlGS:0000000000000000
[ 1582.698595] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1582.808009] CR2: 0000000000645f4c CR3: 000000011760b000 CR4: 
00000000000006f0
[ 1582.808009] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[ 1582.808009] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[ 1582.808009] Process swapper (pid: 0, threadinfo ffffffff81800000, 
task ffffffff8180b020)
[ 1582.808009] Stack:
[ 1582.808009]  ffff88011fc03b50 ffffffffa034663a ffff88011fc03b80 
ffff880118f00800
[ 1582.808009]  ffff880117ac2880 0000000000000000 ffff88011fc03b90 
ffffffff81346ecc
[ 1582.808009]  ffff88011fc03bb0 ffffffff8134b4e9 0000000000000001 
ffff880117ac2880
[ 1582.808009] Call Trace:
[ 1582.808009]  <IRQ>
[ 1582.808009]  [<ffffffffa034663a>] pptp_rcv_core+0x21a/0x220 [pptp]
[ 1582.808009]  [<ffffffff81346ecc>] sk_receive_skb+0x10c/0x140
[ 1582.808009]  [<ffffffff8134b4e9>] ? __pskb_pull_tail+0x59/0x3e0
[ 1582.808009]  [<ffffffffa0346783>] pptp_rcv+0x143/0x190 [pptp]
[ 1582.808009]  [<ffffffffa03250ad>] gre_rcv+0x5d/0x80 [gre]
[ 1582.808009]  [<ffffffff8138946d>] ip_local_deliver_finish+0xdd/0x2a0
[ 1582.808009]  [<ffffffff813897f0>] ip_local_deliver+0x80/0x90
[ 1582.808009]  [<ffffffff81389135>] ip_rcv_finish+0x135/0x390
[ 1582.808009]  [<ffffffff81389a1c>] ip_rcv+0x21c/0x2e0
[ 1582.808009]  [<ffffffff81356f5a>] __netif_receive_skb+0x52a/0x690
[ 1582.808009]  [<ffffffff8100cf01>] ? do_IRQ+0x61/0xe0
[ 1582.808009]  [<ffffffff8140a593>] ? common_interrupt+0x13/0x13
[ 1582.808009]  [<ffffffff813572d0>] netif_receive_skb+0x60/0x90
[ 1582.808009]  [<ffffffff8124de9c>] ? is_swiotlb_buffer+0x3c/0x50
[ 1582.808009]  [<ffffffff81357440>] napi_skb_finish+0x50/0x70
[ 1582.808009]  [<ffffffff813579bd>] napi_gro_receive+0xbd/0xd0
[ 1582.808009]  [<ffffffffa01b229b>] igb_poll+0x6fb/0xae0 [igb]
[ 1582.808009]  [<ffffffff81356f5a>] ? __netif_receive_skb+0x52a/0x690
[ 1582.808009]  [<ffffffff81357be5>] net_rx_action+0x135/0x270
[ 1582.808009]  [<ffffffff81062705>] __do_softirq+0xa5/0x1d0
[ 1582.808009]  [<ffffffff8141301c>] call_softirq+0x1c/0x30
[ 1582.808009]  [<ffffffff8100d355>] do_softirq+0x65/0xa0
[ 1582.808009]  [<ffffffff81062a96>] irq_exit+0x86/0xa0
[ 1582.808009]  [<ffffffff8100cf01>] do_IRQ+0x61/0xe0
[ 1582.808009]  [<ffffffff8140a593>] common_interrupt+0x13/0x13
[ 1582.808009]  <EOI>
[ 1582.808009]  [<ffffffff81012deb>] ? mwait_idle+0x9b/0x1d0
[ 1582.808009]  [<ffffffff8140de35>] ? atomic_notifier_call_chain+0x15/0x20
[ 1582.808009]  [<ffffffff8100a1e6>] cpu_idle+0x56/0xa0
[ 1582.808009]  [<ffffffff813f396d>] rest_init+0x6d/0x80
[ 1582.808009]  [<ffffffff8187fbe6>] start_kernel+0x392/0x39d
[ 1582.808009]  [<ffffffff8187f347>] x86_64_start_reservations+0x132/0x136
[ 1582.808009]  [<ffffffff8187f44c>] x86_64_start_kernel+0x101/0x110
[ 1582.808009] Code: 8b 47 68 55 48 89 e5 39 c6 77 1c 29 f0 3b 47 6c 89 
47 68 72 16 89 f0 48 03 87 e0 00 00 00 48 89 87 e
[ 1582.808009] RIP  [<ffffffff8134a94b>] skb_pull+0x2b/0x30
[ 1582.808009]  RSP <ffff88011fc03b20>
[ 1583.628015] ---[ end trace 6c39f3d0e04ed229 ]---
[ 1583.641960] Kernel panic - not syncing: Fatal exception in interrupt
[ 1583.661088] Pid: 0, comm: swapper Tainted: G      D 
2.6.39-std-def-alt3 #1
[ 1583.682846] Call Trace:
[ 1583.690254]  <IRQ>  [<ffffffff81407284>] panic+0x8c/0x197
[ 1583.706576]  [<ffffffff8140b4d2>] oops_end+0xe2/0xf0
[ 1583.721540]  [<ffffffff8100e876>] die+0x56/0x90
[ 1583.735215]  [<ffffffff8140abf4>] do_trap+0xc4/0x170
[ 1583.750191]  [<ffffffff8100bf00>] do_invalid_op+0x90/0xb0
[ 1583.766466]  [<ffffffff8134a94b>] ? skb_pull+0x2b/0x30
[ 1583.781965]  [<ffffffffa01f31d6>] ? ipt_do_table+0x256/0x670 [ip_tables]

other was:
[  245.268856] ------------[ cut here ]------------
[  245.272797] kernel BUG at include/linux/skbuff.h:1189!
[  245.272797] invalid opcode: 0000 [#1] SMP
[  245.272797] last sysfs file: /sys/devices/virtual/net/ppp100/uevent
[  245.272797] CPU 3
[  245.272797] Modules linked in: cls_fw sch_sfq arc4 ecb ppp_mppe 
act_mirred act_skbedit cls_u32 sch_ingress l2tp_ppp l2d
[  245.272797]
[  245.272797] Pid: 0, comm: kworker/0:1 Not tainted 2.6.39-std-def-alt3 
#1 ASUS RS100-E4/PI2/P5M2-M/RS100-E4
[  245.272797] RIP: 0010:[<ffffffff8134a94b>]  [<ffffffff8134a94b>] 
skb_pull+0x2b/0x30
[  245.272797] RSP: 0018:ffff88011fd83b20  EFLAGS: 00010297
[  245.272797] RAX: 0000000000000518 RBX: ffff880116a0e0c0 RCX: 
0000000000000444
[  245.272797] RDX: 0000000000000444 RSI: 0000000000000010 RDI: 
ffff880116a0e0c0
[  245.272797] RBP: ffff88011fd83b20 R08: 0000000000000500 R09: 
000000000000000c
[  245.272797] R10: 0000000000000240 R11: 0000000000000001 R12: 
ffff8801171fb400
[  245.272797] R13: ffff880116a0cc72 R14: 000000000000002f R15: 
ffff8801168de000
[  245.272797] FS:  0000000000000000(0000) GS:ffff88011fd80000(0000) 
knlGS:0000000000000000
[  245.272797] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  245.272797] CR2: 00000000008faa2c CR3: 00000001151c2000 CR4: 
00000000000006e0
[  245.272797] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[  245.272797] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[  245.272797] Process kworker/0:1 (pid: 0, threadinfo ffff880118f46000, 
task ffff880118f444c0)
[  245.272797] Stack:
[  245.272797]  ffff88011fd83b50 ffffffffa03374e2 ffff88011fd83b80 
ffff8801171fb400
[  245.272797]  ffff880116a0e0c0 0000000000000000 ffff88011fd83b90 
ffffffff81346ecc
[  245.892667]  ffff88011fd83bb0 ffffffff8134b4e9 0000000000000001 
ffff880116a0e0c0
[  245.892667] Call Trace:
[  245.892667]  <IRQ>
[  245.892667]  [<ffffffffa03374e2>] pptp_rcv_core+0xc2/0x220 [pptp]
[  245.892667]  [<ffffffff81346ecc>] sk_receive_skb+0x10c/0x140
[  245.892667]  [<ffffffff8134b4e9>] ? __pskb_pull_tail+0x59/0x3e0
[  245.892667]  [<ffffffffa0337783>] pptp_rcv+0x143/0x190 [pptp]
[  245.892667]  [<ffffffffa03160ad>] gre_rcv+0x5d/0x80 [gre]
[  245.892667]  [<ffffffff8138946d>] ip_local_deliver_finish+0xdd/0x2a0
[  245.892667]  [<ffffffff813897f0>] ip_local_deliver+0x80/0x90
[  245.892667]  [<ffffffff81389135>] ip_rcv_finish+0x135/0x390
[  245.892667]  [<ffffffff81389a1c>] ip_rcv+0x21c/0x2e0
[  245.892667]  [<ffffffff81356f5a>] __netif_receive_skb+0x52a/0x690
[  245.892667]  [<ffffffff81137985>] ? __kmalloc_node_track_caller+0x55/0x60
[  245.892667]  [<ffffffff813572d0>] netif_receive_skb+0x60/0x90
[  245.892667]  [<ffffffff8124de9c>] ? is_swiotlb_buffer+0x3c/0x50
[  245.892667]  [<ffffffff81357440>] napi_skb_finish+0x50/0x70
[  245.892667]  [<ffffffff813579bd>] napi_gro_receive+0xbd/0xd0
[  245.892667]  [<ffffffffa01ea29b>] igb_poll+0x6fb/0xae0 [igb]
[  245.892667]  [<ffffffff81356f5a>] ? __netif_receive_skb+0x52a/0x690
[  245.892667]  [<ffffffff81357be5>] net_rx_action+0x135/0x270
[  245.892667]  [<ffffffff81062705>] __do_softirq+0xa5/0x1d0
[  245.892667]  [<ffffffff8141301c>] call_softirq+0x1c/0x30
[  245.892667]  [<ffffffff8100d355>] do_softirq+0x65/0xa0
[  245.892667]  [<ffffffff81062a96>] irq_exit+0x86/0xa0
[  245.892667]  [<ffffffff8100cf01>] do_IRQ+0x61/0xe0
[  245.892667]  [<ffffffff8140a593>] common_interrupt+0x13/0x13
[  245.892667]  <EOI>
[  245.892667]  [<ffffffff81012deb>] ? mwait_idle+0x9b/0x1d0
[  245.892667]  [<ffffffff8140de35>] ? atomic_notifier_call_chain+0x15/0x20
[  245.892667]  [<ffffffff8100a1e6>] cpu_idle+0x56/0xa0
[  245.892667]  [<ffffffff81403729>] start_secondary+0x197/0x19c
[  245.892667] Code: 8b 47 68 55 48 89 e5 39 c6 77 1c 29 f0 3b 47 6c 89 
47 68 72 16 89 f0 48 03 87 e0 00 00 00 48 89 87 e
[  245.892667] RIP  [<ffffffff8134a94b>] skb_pull+0x2b/0x30
[  245.892667]  RSP <ffff88011fd83b20>
[  246.520989] ---[ end trace ad4c118e9d8ac857 ]---
[  246.534912] Kernel panic - not syncing: Fatal exception in interrupt
[  246.534916] Pid: 0, comm: kworker/0:1 Tainted: G      D 
2.6.39-std-def-alt3 #1
