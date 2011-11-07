From: Luciano Ruete <lruete@sequre.com.ar>
Subject: Re: Kernel Panic every 2 weeks on ISP server (NULL pointer dereference)
Date: Mon, 7 Nov 2011 10:11:48 -0300
Message-ID: <201111071011.48984.lruete@sequre.com.ar>
References: <201110222218.12524.lruete@sequre.com.ar> <1319346989.6180.71.camel@edumazet-laptop> <201110241509.14027.lruete@sequre.com.ar>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_Uk9tO0W7DyRQpAY"
Cc: Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.vita.com.ar ([190.15.202.242]:58293 "HELO vita.com.ar"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754597Ab1KGNMo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Nov 2011 08:12:44 -0500
In-Reply-To: <201110241509.14027.lruete@sequre.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_Uk9tO0W7DyRQpAY
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Monday, October 24, 2011 03:09:13 pm Luciano Ruete wrote:
> On Sunday, October 23, 2011 02:16:29 am Eric Dumazet wrote:
> > Le samedi 22 octobre 2011 =C3=A0 22:18 -0300, Luciano Ruete a =C3=A9cri=
t :
> [...]
> Thanks again i will try the kernel upgrade and post results in this threa=
d.


Ok, now running Linux Kernel 3.0.0(Ubuntu 11.10)[0]

After 3 days of uptime, i've had a new kind of crash(panic), this time in=20
nf_conntrack_sip flush_expectations function.=20

Trace and decoded trace attached, i still do not know how to read this in=20
order to follow excecution and blame a particular kernel line of code. Gues=
s=20
compiling C into assembler on the fly is not in my skills bag.

I just want to check if this is kernel a bug, or may be there is something=
=20
wrong somewhere else in my setup...

[0] server:~# uname -a
Linux server 3.0.0-12-server #20-Ubuntu SMP Fri Oct 7 16:36:30 UTC 2011 x86=
_64=20
GNU/Linux


=2D-=20
Luciano Ruete
Sequre - Sys Admin
Mitre 617, piso 7, of. 1=20
+54 261 4254894
Mendoza - Argentina
http://www.sequre.com.ar/

--Boundary-00=_Uk9tO0W7DyRQpAY
Content-Type: text/plain;
  name="decoded_trace.txt"
Content-Transfer-Encoding: 7bit

[328686.010062] Code: 84 d2 75 7f 48 c7 c7 e8 19 12 a0 45 0f b6 ee e8 47 2d 48 e1 48 8b 5b 28 48 85 db 75 0e eb 4c 0f 1f 40 00 4d 85 e4 74 43 4c 89 e3 <8b> b3 d0 00 00 00 31 c0 4c 8b 23 85 f6 0f 95 c0 41 39 c5 75 e3
All code
========
   0:   84 d2                   test   %dl,%dl
   2:   75 7f                   jne    0x83
   4:   48 c7 c7 e8 19 12 a0    mov    $0xffffffffa01219e8,%rdi
   b:   45 0f b6 ee             movzbl %r14b,%r13d
   f:   e8 47 2d 48 e1          callq  0xffffffffe1482d5b
  14:   48 8b 5b 28             mov    0x28(%rbx),%rbx
  18:   48 85 db                test   %rbx,%rbx
  1b:   75 0e                   jne    0x2b
  1d:   eb 4c                   jmp    0x6b
  1f:   0f 1f 40 00             nopl   0x0(%rax)
  23:   4d 85 e4                test   %r12,%r12
  26:   74 43                   je     0x6b
  28:   4c 89 e3                mov    %r12,%rbx
  2b:*  8b b3 d0 00 00 00       mov    0xd0(%rbx),%esi     <-- trapping instruction
  31:   31 c0                   xor    %eax,%eax
  33:   4c 8b 23                mov    (%rbx),%r12
  36:   85 f6                   test   %esi,%esi
  38:   0f 95 c0                setne  %al
  3b:   41 39 c5                cmp    %eax,%r13d
  3e:   75 e3                   jne    0x23

Code starting with the faulting instruction
===========================================
   0:   8b b3 d0 00 00 00       mov    0xd0(%rbx),%esi
   6:   31 c0                   xor    %eax,%eax
   8:   4c 8b 23                mov    (%rbx),%r12
   b:   85 f6                   test   %esi,%esi
   d:   0f 95 c0                setne  %al
  10:   41 39 c5                cmp    %eax,%r13d
  13:   75 e3                   jne    0xfffffffffffffff8

--Boundary-00=_Uk9tO0W7DyRQpAY
Content-Type: text/plain;
  name="kern.log.txt"
Content-Transfer-Encoding: 7bit

[328680.672986] general protection fault: 0000 [#1] SMP 
[328680.733325] CPU 1 
[328680.756199] Modules linked in: ppp_deflate zlib_deflate bsd_comp ppp_async crc_ccitt nf_conntrack_netlink nfnetlink xt_owner ipt_REJECT ipt_REDIRECT ipt_MASQUERADE xt_iprange xt_helper xt_length xt_TCPMSS xt_connmark xt_mark xt_state xt_tcpudp xt_multiport iptable_mangle iptable_nat iptable_filter ip_tables x_tables sch_sfq act_mirred cls_u32 sch_prio cls_fw sch_htb ifb dummy 8021q garp stp nf_nat_irc nf_conntrack_irc nf_nat_sip nf_conntrack_sip nf_nat_pptp nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_proto_gre nf_nat_amanda ts_kmp nf_conntrack_amanda nf_nat_ftp nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack_ftp nf_conntrack cdc_ether usbnet i7core_edac ioatdma tpm_tis serio_raw lp shpchp parport edac_core raid10 raid456 async_pq async_xor xor async_memcpy async_raid6_recov ra
 id6_pq async_tx raid1 igb usbhid raid0 hid megaraid_sas dca multipath linear
[328681.672554] 
[328681.691295] Pid: 0, comm: kworker/0:0 Not tainted 3.0.0-12-server #20-Ubuntu IBM System x3650 M3 -[7945AC1]-/69Y5698     
[328681.823341] RIP: 0010:[<ffffffffa017bc70>]  [<ffffffffa017bc70>] flush_expectations+0x50/0xc0 [nf_conntrack_sip]
[328681.945982] RSP: 0018:ffff88027f223890  EFLAGS: 00010286
[328682.010416] RAX: 0000000000000000 RBX: dead000000100100 RCX: ffff88026fb00480
[328682.096674] RDX: ffff88027ec1c420 RSI: 0000000000000001 RDI: ffff88026aa8df68
[328682.182933] RBP: ffff88027f2238b0 R08: ffff88027ec1c000 R09: dead000000200200
[328682.269198] R10: dead000000200200 R11: dead000000200200 R12: dead000000100100
[328682.355459] R13: 0000000000000001 R14: 0000000000000001 R15: 000000000000012e
[328682.441720] FS:  0000000000000000(0000) GS:ffff88027f220000(0000) knlGS:0000000000000000
[328682.539407] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[328682.609036] CR2: 00007f07284b6500 CR3: 0000000001c03000 CR4: 00000000000006e0
[328682.695299] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[328682.781560] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[328682.867822] Process kworker/0:0 (pid: 0, threadinfo ffff880272a2e000, task ffff880272a30000)
[328682.969665] Stack:
[328682.994635]  0000000000000030 ffff88027f2239cc ffff88027f2239c0 ffff88013dfe2100
[328683.084115]  ffff88027f2238e0 ffffffffa017cec0 ffff88027f2239cc ffff880200000001
[328683.173599]  ffff88027f2238e0 0000000000000000 ffff88027f223970 ffffffffa017b9eb
[328683.263086] Call Trace:
[328683.293249]  <IRQ> 
[328683.319288]  [<ffffffffa017cec0>] process_invite_response+0x80/0x90 [nf_conntrack_sip]
[328683.414895]  [<ffffffffa017b9eb>] process_sip_response+0x15b/0x170 [nf_conntrack_sip]
[328683.509468]  [<ffffffffa017d10d>] process_sip_msg.isra.8+0x7d/0xb0 [nf_conntrack_sip]
[328683.604039]  [<ffffffffa017d1dd>] sip_help_udp+0x9d/0xd0 [nf_conntrack_sip]
[328683.688209]  [<ffffffffa012fdcf>] ipv4_confirm+0xbf/0x200 [nf_conntrack_ipv4]
[328683.774479]  [<ffffffff81516075>] nf_iterate+0x85/0xc0
[328683.836838]  [<ffffffff815223e0>] ? ip_fragment+0x950/0x950
[328683.904391]  [<ffffffff81516126>] nf_hook_slow+0x76/0x130
[328683.969865]  [<ffffffff815223e0>] ? ip_fragment+0x950/0x950
[328684.037414]  [<ffffffff8152310c>] ip_output+0x9c/0xc0
[328684.098737]  [<ffffffff8151f094>] ip_forward_finish+0x44/0x60
[328684.168372]  [<ffffffff8151f355>] ip_forward+0x2a5/0x440
[328684.232807]  [<ffffffff8151d641>] ip_rcv_finish+0x131/0x370
[328684.300363]  [<ffffffff8151deee>] ip_rcv+0x21e/0x2f0
[328684.360647]  [<ffffffff814e9972>] __netif_receive_skb+0x4a2/0x540
[328684.434433]  [<ffffffff814dc63f>] ? __alloc_skb+0x4f/0x230
[328684.500945]  [<ffffffff814e99d9>] __netif_receive_skb+0x509/0x540
[328684.574730]  [<ffffffff814ea530>] netif_receive_skb+0x80/0x90
[328684.644361]  [<ffffffff814ea928>] ? dev_gro_receive+0x1b8/0x2c0
[328684.716067]  [<ffffffff814ea670>] napi_skb_finish+0x50/0x70
[328684.783620]  [<ffffffff814eaba5>] napi_gro_receive+0xb5/0xc0
[328684.852215]  [<ffffffff815ba50b>] vlan_gro_receive+0x1b/0x20
[328684.920811]  [<ffffffffa00c4be8>] igb_clean_rx_irq_adv+0x2a8/0x630 [igb]
[328685.001873]  [<ffffffffa00c4fde>] igb_poll+0x6e/0x140 [igb]
[328685.069425]  [<ffffffff814eadb4>] net_rx_action+0x134/0x290
[328685.136984]  [<ffffffffa00bf796>] ? igb_msix_ring+0x36/0x50 [igb]
[328685.210772]  [<ffffffff81065e38>] __do_softirq+0xa8/0x210
[328685.276249]  [<ffffffff815fe82e>] ? _raw_spin_lock+0xe/0x20
[328685.343804]  [<ffffffff81607e1c>] call_softirq+0x1c/0x30
[328685.408240]  [<ffffffff8100c295>] do_softirq+0x65/0xa0
[328685.470602]  [<ffffffff8106621e>] irq_exit+0x8e/0xb0
[328685.530885]  [<ffffffff81608673>] do_IRQ+0x63/0xe0
[328685.589092]  [<ffffffff815fed53>] common_interrupt+0x13/0x13
[328685.657682]  <EOI> 
[328685.683719]  [<ffffffff814bc8ba>] ? poll_idle+0x3a/0x80
[328685.747119]  [<ffffffff814bc893>] ? poll_idle+0x13/0x80
[328685.810519]  [<ffffffff814bcba2>] cpuidle_idle_call+0xa2/0x1d0
[328685.881188]  [<ffffffff8100920b>] cpu_idle+0xab/0x100
[328685.942510]  [<ffffffff815de7ec>] start_secondary+0xd9/0xdb
[328686.010062] Code: 84 d2 75 7f 48 c7 c7 e8 19 12 a0 45 0f b6 ee e8 47 2d 48 e1 48 8b 5b 28 48 85 db 75 0e eb 4c 0f 1f 40 00 4d 85 e4 74 43 4c 89 e3 <8b> b3 d0 00 00 00 31 c0 4c 8b 23 85 f6 0f 95 c0 41 39 c5 75 e3 
[328686.238203] RIP  [<ffffffffa017bc70>] flush_expectations+0x50/0xc0 [nf_conntrack_sip]
[328686.332795]  RSP <ffff88027f223890>
[328686.375794] ---[ end trace 806ab2e6e0730fa6 ]---
[328686.431970] Kernel panic - not syncing: Fatal exception in interrupt
[328686.508915] Pid: 0, comm: kworker/0:0 Tainted: G      D     3.0.0-12-server #20-Ubuntu
[328686.604571] Call Trace:
[328686.634779]  <IRQ>  [<ffffffff815e8184>] panic+0x91/0x194
[328686.700387]  [<ffffffff815ffd0a>] oops_end+0xea/0xf0
[328686.760720]  [<ffffffff8100d8c8>] die+0x58/0x90
[328686.815859]  [<ffffffff815ff7c2>] do_general_protection+0x162/0x170
[328686.891771]  [<ffffffff8150a4eb>] ? qdisc_watchdog_schedule+0x3b/0x40
[328686.969755]  [<ffffffff815fefe5>] general_protection+0x25/0x30
[328687.040477]  [<ffffffffa017bc70>] ? flush_expectations+0x50/0xc0 [nf_conntrack_sip]
[328687.133024]  [<ffffffffa017cec0>] process_invite_response+0x80/0x90 [nf_conntrack_sip]
[328687.228685]  [<ffffffffa017b9eb>] process_sip_response+0x15b/0x170 [nf_conntrack_sip]
[328687.323308]  [<ffffffffa017d10d>] process_sip_msg.isra.8+0x7d/0xb0 [nf_conntrack_sip]
[328687.417932]  [<ffffffffa017d1dd>] sip_help_udp+0x9d/0xd0 [nf_conntrack_sip]
[328687.502154]  [<ffffffffa012fdcf>] ipv4_confirm+0xbf/0x200 [nf_conntrack_ipv4]
[328687.588464]  [<ffffffff81516075>] nf_iterate+0x85/0xc0
[328687.650873]  [<ffffffff815223e0>] ? ip_fragment+0x950/0x950
[328687.718473]  [<ffffffff81516126>] nf_hook_slow+0x76/0x130
[328687.783991]  [<ffffffff815223e0>] ? ip_fragment+0x950/0x950
[328687.851594]  [<ffffffff8152310c>] ip_output+0x9c/0xc0
[328687.912962]  [<ffffffff8151f094>] ip_forward_finish+0x44/0x60
[328687.982636]  [<ffffffff8151f355>] ip_forward+0x2a5/0x440
[328688.047122]  [<ffffffff8151d641>] ip_rcv_finish+0x131/0x370
[328688.114722]  [<ffffffff8151deee>] ip_rcv+0x21e/0x2f0
[328688.175049]  [<ffffffff814e9972>] __netif_receive_skb+0x4a2/0x540
[328688.248881]  [<ffffffff814dc63f>] ? __alloc_skb+0x4f/0x230
[328688.315440]  [<ffffffff814e99d9>] __netif_receive_skb+0x509/0x540
[328688.389273]  [<ffffffff814ea530>] netif_receive_skb+0x80/0x90
[328688.458955]  [<ffffffff814ea928>] ? dev_gro_receive+0x1b8/0x2c0
[328688.530709]  [<ffffffff814ea670>] napi_skb_finish+0x50/0x70
[328688.598311]  [<ffffffff814eaba5>] napi_gro_receive+0xb5/0xc0
[328688.666951]  [<ffffffff815ba50b>] vlan_gro_receive+0x1b/0x20
[328688.735594]  [<ffffffffa00c4be8>] igb_clean_rx_irq_adv+0x2a8/0x630 [igb]
[328688.816700]  [<ffffffffa00c4fde>] igb_poll+0x6e/0x140 [igb]
[328688.884300]  [<ffffffff814eadb4>] net_rx_action+0x134/0x290
[328688.951901]  [<ffffffffa00bf796>] ? igb_msix_ring+0x36/0x50 [igb]
[328689.025732]  [<ffffffff81065e38>] __do_softirq+0xa8/0x210
[328689.091255]  [<ffffffff815fe82e>] ? _raw_spin_lock+0xe/0x20
[328689.158854]  [<ffffffff81607e1c>] call_softirq+0x1c/0x30
[328689.223337]  [<ffffffff8100c295>] do_softirq+0x65/0xa0
[328689.285746]  [<ffffffff8106621e>] irq_exit+0x8e/0xb0
[328689.346074]  [<ffffffff81608673>] do_IRQ+0x63/0xe0
[328689.404330]  [<ffffffff815fed53>] common_interrupt+0x13/0x13
[328689.472964]  <EOI>  [<ffffffff814bc8ba>] ? poll_idle+0x3a/0x80
[328689.543765]  [<ffffffff814bc893>] ? poll_idle+0x13/0x80
[328689.607210]  [<ffffffff814bcba2>] cpuidle_idle_call+0xa2/0x1d0
[328689.677935]  [<ffffffff8100920b>] cpu_idle+0xab/0x100
[328689.739309]  [<ffffffff815de7ec>] start_secondary+0xd9/0xdb
[328689.806913] Rebooting in 1 seconds..
--Boundary-00=_Uk9tO0W7DyRQpAY--
