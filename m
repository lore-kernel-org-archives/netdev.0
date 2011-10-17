From: Bradley Peterson <despite@gmail.com>
Subject: BUG in skb_pull with e1000e, PPTP, and L2TP
Date: Mon, 17 Oct 2011 17:19:53 -0500
Message-ID: <CAJuWrdtOru6KSNTxXhhQNEZUTaX5KvyF7macx4RZYxMzcAo0KQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

I have servers running as PPTP and L2TP/IPSec endpoints.=A0 They run
other services, but the VPN endpoints seem to be the problem (the
problem goes away when VPN is disabled).=A0 The servers that are using
the e1000e driver crash with "kernel BUG at
include/linux/skbuff.h:1186!" using linux 2.6.38.=A0 I saw a similar BUG
in the same function on 2.6.22, with both e1000e and igb, using 3rd
party pptp and l2tp modules.=A0 I have other servers, running tg3 and
forcedeth drivers, which don't have this crash.

I can't reproduce the BUG in my development, and it happens randomly
in production.=A0 So, testing is difficult.=A0 I'm working on testing with
3.0 next.

Here are 3 separate instances of the crash.=A0 The traces are different,
but the BUG is always the same.

Thanks for any pointers or help,
Bradley Peterson

[32173.294224] ------------[ cut here ]------------
[32173.298873] kernel BUG at include/linux/skbuff.h:1186!
[32173.304029] invalid opcode: 0000 [#1] SMP
[32173.308184] last sysfs file:
/sys/devices/system/cpu/cpu7/cache/index2/shared_cpu_map
[32173.316039] CPU 1
[32173.317891] Modules linked in: authenc esp4 xfrm4_mode_transport
arc4 ppp_mppe tcp_diag inet_diag xt_NOTRACK iptable_raw pptp gre
l2tp_ppp pppox ppp_generic slhc l2tp_netlink l
2tp_core tun deflate zlib_deflate twofish_generic twofish_x86_64
twofish_common camellia serpent blowfish cast5 des_generic xcbc rmd160
sha512_generic sha256_generic crypto_null a
f_key iptable_nat nf_nat xt_mark iptable_mangle bonding 8021q garp stp
llc ipv6 sp5100_tco i2c_piix4 i2c_core e1000e amd64_edac_mod serio_raw
ghes microcode k10temp edac_core hed
edac_mce_amd raid456 async_raid6_recov async_pq raid6_pq async_xor xor
async_memcpy async_tx raid1 pata_acpi firewire_ohci ata_generic
firewire_core crc_itu_t pata_atiixp 3w_9xxx
[last unloaded: scsi_wait_scan]
[32173.385465]
[32173.386965] Pid: 0, comm: kworker/0:0 Not tainted
2.6.38.8-32.1.fix.fc14.x86_64 #1 SGI.COM System Product
Name/KGP(M)E-D16
[32173.398135] RIP: 0010:[<ffffffff813d2f0d>]=A0 [<ffffffff813d2f0d>]
__skb_pull258]=A0 [<ffffffff81410846>] NF_HOOK.clone.7+0x51/0x58
[32173.588842]=A0 [<ffffffff81410bb5>] ip_rcv+0x21b/0x246
[32173.593816]=A0 [<ffffffff813dd584>] __netif_receive_skb+0x426/0x45c
[32173.599925]=A0 [<ffffffff81053443>] ? select_task_rq_fair+0x57a/0x57f
[32173.606225]=A0 [<ffffffff813da220>] ? arch_local_irq_save+0x16/0x1c
[32173.612337]=A0 [<ffffffff813dd495>] __netif_receive_skb+0x337/0x45c
[32173.618450]=A0 [<ffffffff810482c7>] ? check_preempt_curr+0x45/0x70
[32173.624478]=A0 [<ffffffff8104baa0>] ? ttwu_post_activation+0x60/0xf9
[32173.630669]=A0 [<ffffffff813dd641>] process_backlog+0x87/0x15d
[32173.636351]=A0 [<ffffffff8148982f>] ? _raw_spin_unlock_irqrestore+0x17/0=
x19
[32173.643165]=A0 [<ffffffff813de528>] net_rx_action+0xac/0x1b1
[32173.648675]=A0 [<ffffffff8105efaa>] __do_softirq+0xd2/0x19e
[32173.654082]=A0 [<ffffffff81010fad>] ? paravirt_read_tsc+0x9/0xd
[32173.659850]=A0 [<ffffffff810114d6>] ? sched_clock+0x9/0xd
[32173.665082]=A0 [<ffffffff8100bb5c>] call_softirq+0x1c/0x30
[32173.670417]=A0 [<ffffffff8100d287>] do_softirq+0x46/0x83
[32173.675565]=A0 [<ffffffff8105f132>] irq_exit+0x49/0x8b
[32173.680547]=A0 [<ffffffff81022b66>]
smp_call_function_single_interrupt+0x25/0x27
[32173.687786]=A0 [<ffffffff8100b7b3>] call_function_single_interrupt+0x13/=
0x20
[32173.694662]=A0 <EOI>
[32173.696798]=A0 [<ffffffff8102c61d>] ? native_safe_halt+0xb/0xd
[32173.702508]=A0 [<ffffffff81011fac>] ? need_resched+0x23/0x2d
[32173.708005]=A0 [<ffffffff810120fa>] default_idle+0x4e/0x86
[32173.713345]=A0 [<ffffffff8100932a>] cpu_idle+0xaa/0xcc
[32173.718339]=A0 [<ffffffff81482062>] start_secondary+0x20d/0x20f
[32173.724092] Code: 68 2b b7 d8 00 00 00 03 b7 e0 00 00 00 89 b7 cc
00 00 00 c9 c3 55 48 89 e5 66 66 66 66 90 8b 57 68 29 f2 3b 57 6c 89
57 68 73 02 <0f> 0b 89 f0 48 03 87 e0 00
00 00 48 89 87 e0 00 00 00 c9 c3 55
[32173.744370] RIP=A0 [<ffffffff813d2f0d>] __skb_pull+0x16/0x2a
[32173.749920]=A0 RSP <ffff8800dfa23b80>
[32173.753820] ---[ end trace 83b8ebd5dde8ff41 ]---





[16165.077006] ------------[ cut here ]------------
[16165.077936] kernel BUG at include/linux/skbuff.h:1186!
[16165.082856] invalid opcode: 0000 [#1] SMP
[16165.082856] last sysfs file:
/sys/devices/virtual/net/ppp29/queues/rx-0/rps_flow_cnt
[16165.095731] CPU 1
[16165.095731] Modules linked in: arc4 ppp_mppe tcp_diag inet_diag
xt_NOTRACK iptable_raw pptp gre l2tp_ppp pppox ppp_generic slhc
l2tp_netlink l2tp_core tun deflate zlib_deflate
twofish_generic twofish_x86_64 twofish_common camellia serpent
blowfish cast5 des_generic xcbc rmd160 sha512_generic sha256_generic
crypto_null af_key iptable_nat nf_nat xt_mark i
ptable_mangle bonding 8021q garp stp llc ipv6 sp5100_tco e1000e
k10temp i2c_piix4 amd64_edac_mod i2c_core edac_core ghes hed
edac_mce_amd microcode serio_raw raid456 async_raid6_r
ecov async_pq raid6_pq async_xor xor async_memcpy async_tx raid1
pata_acpi firewire_ohci ata_generic firewire_core crc_itu_t
pata_atiixp 3w_9xxx [last unloaded: scsi_wait_scan]
[16165.163315]
[16165.163315] Pid: 0, comm: kworker/0:0 Not tainted
2.6.38.8-32.1.fix.fc14.x86_64 #1 SGI.COM System Product
Name/KGP(M)E-D16
[16165.163315] RIP: 0010:[<ffffffff813d2f0d>]=A0 [<ffffffff813d2f0d>]
__skb_pull+0x16/0x2a
[16165.163315] RSP: 0018:ffff8800dfa23b80=A0 EFLAGS: 00010287
[16165.163315] RAX: 0000000000000000 RBX: ffff880141cec000 RCX: 00000000000=
0005c
[16165.196875] RDX: 000000000000057f RSI: 0000000000000010 RDI: ffff880141c=
ec000
[16165.203325] RBP: ffff8800dfa23b80 R08: 00000000ff34033f R09: 00000000000=
00000
[1616165.384622]=A0 [<ffffffff8104a480>] ? update_shares+0xb7/0xf4
[16165.394969]=A0 [<ffffffff813dd641>] process_backlog+0x87/0x15d
[16165.394969]=A0 [<ffffffff81489816>] ? _raw_spin_lock_irq+0x1f/0x21
[16165.405933]=A0 [<ffffffff813de528>] net_rx_action+0xac/0x1b1
[16165.410153]=A0 [<ffffffff8105efaa>] __do_softirq+0xd2/0x19e
[16165.410153]=A0 [<ffffffff81010fad>] ? paravirt_read_tsc+0x9/0xd
[16165.410153]=A0 [<ffffffff810114d6>] ? sched_clock+0x9/0xd
[16165.410153]=A0 [<ffffffff8100bb5c>] call_softirq+0x1c/0x30
[16165.410153]=A0 [<ffffffff8100d287>] do_softirq+0x46/0x83
[16165.410153]=A0 [<ffffffff8105f132>] irq_exit+0x49/0x8b
[16165.410153]=A0 [<ffffffff81022b66>]
smp_call_function_single_interrupt+0x25/0x27
[16165.447293]=A0 [<ffffffff8100b7b3>] call_function_single_interrupt+0x13/=
0x20
[16165.447293]=A0 <EOI>
[16165.459948]=A0 [<ffffffff810b8394>] ? rcu_needs_cpu+0x10e/0x1bf
[16165.465027]=A0 [<ffffffff8102c61d>] ? native_safe_halt+0xb/0xd
[16165.470461]=A0 [<ffffffff81011fac>] ? need_resched+0x23/0x2d
[16165.477519]=A0 [<ffffffff810120fa>] default_idle+0x4e/0x86
[16165.477974]=A0 [<ffffffff8100932a>] cpu_idle+0xaa/0xcc
[16165.477974]=A0 [<ffffffff81482062>] start_secondary+0x20d/0x20f
[16165.477974] Code: 68 2b b7 d8 00 00 00 03 b7 e0 00 00 00 89 b7 cc
00 00 00 c9 c3 55 48 89 e5 66 66 66 66 90 8b 57 68 29 f2 3b 57 6c 89
57 68 73 02 <0f> 0b 89 f0 48 03 87 e0 00
00 00 48 89 87 e0 00 00 00 c9 c3 55
[16165.477974] RIP=A0 [<ffffffff813d2f0d>] __skb_pull+0x16/0x2a
[16165.477974]=A0 RSP <ffff8800dfa23b80>
[16165.523203] ---[ end trace f793f200ecc5d20f ]---





[17950.922006] ------------[ cut here ]------------
[17950.922941] kernel BUG at include/linux/skbuff.h:1186!
[17950.928042] invalid opcode: 0000 [#1] SMP
[17950.928042] last sysfs file:
/sys/devices/system/cpu/cpu7/cache/index2/shared_cpu_map
[17950.943036] CPU 7
[17950.943036] Modules linked in: authenc esp4 xfrm4_mode_transport
tcp_diag inet_diag xt_NOTRACK iptable_raw arc4 ppp_mppe pptp gre
l2tp_ppp pppox ppp_generic slhc l2tp_netlink l
2tp_core tun deflate zlib_deflate twofish_generic twofish_x86_64
twofish_common camellia serpent blowfish cast5 des_generic xcbc rmd160
sha512_generic sha256_generic crypto_null a
f_key iptable_nat nf_nat xt_mark iptable_mangle bonding 8021q garp stp
llc ipv6 e1000e sp5100_tco i2c_piix4 k10temp i2c_core amd64_edac_mod
ghes edac_core hed serio_raw edac_mce_a
md microcode raid456 async_raid6_recov async_pq raid6_pq async_xor xor
async_memcpy async_tx raid1 pata_acpi ata_generic firewire_ohci
firewire_core crc_itu_t pata_atiixp 3w_9xxx
[last unloaded: scsi_wait_scan]
[17950.969223]
[17950.969223] Pid: 0, comm: kworker/0:1 Not tainted
2.6.38.8-32.1.fix.fc14.x86_64 #1 SGI.COM System Product
Name/KGP(M)E-D16
[17950.969223] RIP: 0010:[<ffffffff813d2f0d>]=A0 [<ffffffff813d2f0d>]
__skb_pull+0x16/0x2a
[17950.969223] RSP: 0018:ffff8800dfae3b80=A0 EFLAGS: 00010287
[17950.969223] RAX: 0000000000000000 RBX: ffff88017089f600 RCX: 00000000000=
00221
[17951.040852] RDX: 000000000000057f RSI: 0000000000000010 RDI: ffff8801708=
9f600
[17951.050257] RBP: ffff8800dfae3b80 R08: 0000000000000000 R09: ffff8800dfa=
e39c0
[17951.050257] R10: ffff88020e362758 R11: ffff880200000001 R12: ffff8800b31=
eac00
[17951.050257] R13: ffff88013ba2cc72 R14: ffffffffa0280230 R15: ffff8802083=
62000
[17951.050257] FS:=A0 00007fb9a3fee7e0(0000) GS:ffff8800dfae0000(0000)
knlGS:0000000000000000
[17951.080066] CS:=A0 0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[17951.087033] CR2: 00007ffb65c2e000 CR3: 000000014ab0a000 CR4: 00000000000=
006e0
[17951.087033] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[17951.100032] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000000=
00400
[17951.108481] Process kworker/0:1 (pid: 0, threadinfo
ffff88020f60e000, task ffff88020f611730)
[17951.117822] Stack:
[17951.119564]=A0 ffff8800dfae3b90 ffffffff813d2f36 ffff8800dfae3bc0
ffffffffa0286824
[17951.121222]=A0 ffff8800dfae3bf0 ffff8800b31eac00 ffff88017089f600
0000000000000000
[17951.121222]=A0 ffff8800dfae3c00 ffffffff813d17c4 0000000000000000
0000000000000000
[17951.121222] Call Trace:
[17951.142737]=A0 <IRQ>
[17951.142737]=A0 [<ffffffff813d2f36>] skb_pull+0x15/0x17
[17951.142737]=A0 [<ffffffffa0286824>] pptp_rcv_core+0x126/0x19a [pptp]
[17951.152725]=A0 [<ffffffff813d17c4>] sk_receive_skb+0x69/0x105
[17951.163558]=A0 [<ffffffffa0286993>] pptp_rcv+0xc8/0xdc [pptp]
[17951.165092]=A0 [<ffffffffa02800a3>] gre_rcv+0x62/0x75 [gre]
[17951.165092]=A0 [<ffffffff81410784>] ip_local_deliver_finish+0x150/0x1c1
[17951.177599]=A0 [<ffffffff81410634>] ? ip_local_deliver_finish+0x0/0x1c1
[17951.177599]=A0 [<ffffffff81410846>] NF_HOOK.clone.7+0x51/0x58
[17951.177599]=A0 [<ffffffff81410996>] ip_local_deliver+0x51/0x55
[17951.177599]=A0 [<ffffffff814105b9>] ip_rcv_finish+0x31a/0x33e
[17951.177599]=A0 [<ffffffff8141029f>] ? ip_rcv_finish+0x0/0x33e
[17951.204898]=A0 [<ffffffff81410846>] NF_HOOK.clone.7+0x51/0x58
[17951.214651]=A0 [<ffffffff81410bb5>] ip_rcv+0x21b/0x246
[17951.219683]=A0 [<ffffffff813dd584>] __netif_receive_skb+0x426/0x45c
[17951.219683]=A0 [<ffffffff813da220>] ? arch_local_irq_save+0x16/0x1c
[17951.219683]=A0 [<ffffffff813dd495>] __netif_receive_skb+0x337/0x45c
[17951.234702]=A0 [<ffffffff81022954>] ?
native_send_call_func_single_ipi+0x23/0x25
[17951.245864]=A0 [<ffffffff813dd641>] process_backlog+0x87/0x15d
[17951.247180]=A0 [<ffffffff8123f315>] ? timerqueue_add+0x89/0xa8
[17951.257133]=A0 [<ffffffff813de528>] net_rx_action+0xac/0x1b1
[17951.262265]=A0 [<ffffffff8105efaa>] __do_softirq+0xd2/0x19e
[17951.265220]=A0 [<ffffffff81010fad>] ? paravirt_read_tsc+0x9/0xd
[17951.273703]=A0 [<ffffffff810114d6>] ? sched_clock+0x9/0xd
[17951.274966]=A0 [<ffffffff8100bb5c>] call_softirq+0x1c/0x30
[17951.274966]=A0 [<ffffffff8100d287>] do_softirq+0x46/0x83
[17951.274966]=A0 [<ffffffff8105f132>] irq_exit+0x49/0x8b
[17951.274966]=A0 [<ffffffff81022b66>]
smp_call_function_single_interrupt+0x25/0x27
[17951.274966]=A0 [<ffffffff8100b7b3>] call_function_single_interrupt+0x13/=
0x20
[17951.274966]=A0 <EOI>
[17951.274966]=A0 [<ffffffff8102c61d>] ? native_safe_halt+0xb/0xd
[17951.274966]=A0 [<ffffffff81011fac>] ? need_resched+0x23/0x2d
[17951.320741]=A0 [<ffffffff810120fa>] default_idle+0x4e/0x86
[17951.320741]=A0 [<ffffffff8100932a>] cpu_idle+0xaa/0xcc
[17951.320741]=A0 [<ffffffff81482062>] start_secondary+0x20d/0x20f
[17951.320741] Code: 68 2b b7 d8 00 00 00 03 b7 e0 00 00 00 89 b7 cc
00 00 00 c9 c3 55 48 89 e5 66 66 66 66 90 8b 57 68 29 f2 3b 57 6c 89
57 68 73 02 <0f> 0b 89 f0 48 03 87 e0 00
00 00 48 89 87 e0 00 00 00 c9 c3 55
[17951.352436] RIP=A0 [<ffffffff813d2f0d>] __skb_pull+0x16/0x2a
[17951.352436]=A0 RSP <ffff8800dfae3b80>
[17951.367951] ---[ end trace af7b2da986dde7ca ]---

---------------------------------------------------------------------------=
---
All the data continuously generated in your IT infrastructure contains a
definitive record of customers, application performance, security
threats, fraudulent activity and more. Splunk takes this data and makes
sense of it. Business sense. IT sense. Common sense.
http://p.sf.net/sfu/splunk-d2d-oct
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.co=
m/community/wired
