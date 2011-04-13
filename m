From: Dmitry Novikov <dimetrios@gmail.com>
Subject: Re: [Bug 32772] New: PROBLEM: kernel BUG at net/ipv4/inetpeer.c:386
Date: Wed, 13 Apr 2011 23:14:03 +0300
Message-ID: <BANLkTi=PTqcYd1wO_QzQTtg_PWEq2fAJMg@mail.gmail.com>
References: <1302105923.3209.103.camel@edumazet-laptop>
	<1302107123.3209.113.camel@edumazet-laptop>
	<BANLkTinhnPR6fHRQD-vvbxX1n+Zxr=HTZw@mail.gmail.com>
	<20110406.111649.193697123.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59615 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756889Ab1DMUOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 16:14:05 -0400
Received: by wya21 with SMTP id 21so820590wya.19
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2011 13:14:04 -0700 (PDT)
In-Reply-To: <20110406.111649.193697123.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Crash again after 7 days of uptime. slub_nomerge is set

[559353.216526] ------------[ cut here ]------------
[559353.217494] kernel BUG at net/ipv4/inetpeer.c:386!
[559353.217494] invalid opcode: 0000 [#1] SMP
[559353.217494] last sysfs file: /sys/module/nf_conntrack_pptp/initstate
[559353.217494] Modules linked in: nf_nat_pptp nf_nat_proto_gre
nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_ftp nf_conntrack_ftp
ipt_REJECT xt_state xt_tcpudp xt_multiport ip_set iptable_filter
iptable_mangle iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack
nf_defrag_ipv4 ip_tables x_tables act_police cls_u32 sch_ingress
sch_tbf 8021q garp bridge ipv6 stp llc loop intel_agp intel_gtt
agpgart rng_core pcspkr i2c_i801 i2c_core processor thermal_sys
parport_pc evdev parport serio_raw tpm_tis tpm button tpm_bios ext3
jbd mbcache sd_mod crc_t10dif ata_generic ata_piix libata scsi_mod
uhci_hcd ide_pci_generic e1000e ehci_hcd igb r8169 ide_core dca mii
usbcore nls_base [last unloaded: scsi_wait_scan]
[559353.217494]
[559353.217494] Pid: 0, comm: kworker/0:0 Not tainted
2.6.38-demyan-1.1demyan #1 Gigabyte Technology Co., Ltd.
G41MT-ES2L/G41MT-ES2L
[559353.217494] EIP: 0060:[<c11e0caa>] EFLAGS: 00010287 CPU: 1
[559353.217494] EIP is at unlink_from_pool+0x85/0x14a
[559353.217494] EAX: c125ff04 EBX: efcb09c0 ECX: abfd6970 EDX: ee6d77c4
[559353.217494] ESI: c1333338 EDI: f4c91bfc EBP: abfea42e ESP: f4c91ba8
[559353.217494]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[559353.217494] Process kworker/0:0 (pid: 0, ti=f4c90000 task=f4c6a400
task.ti=f4c8c000)
[559353.217494] Stack:
[559353.217494]  f351c790 00000001 abfd6970 c133333c c1333338 efc6b384
efe2af80 efcd1c04
[559353.217494]  f3cc2784 ef3f62c4 f251da80 ef054b40 efcdc300 f0373dc0
f429a144 ef254a80
[559353.217494]  ed4e6340 f0705f40 efcdb580 f05261c0 ee6d77c4 f4c91cb4
f351c790 f4c91c78
[559353.217494] Call Trace:
[559353.217494]  [<c120f068>] ? fib4_rule_action+0x40/0x4d
[559353.217494]  [<c11d1be3>] ? fib_rules_lookup+0x8d/0xe4
[559353.217494]  [<c11e0de9>] ? cleanup_once+0x7a/0x7f
[559353.217494]  [<c11e0fa9>] ? inet_getpeer+0x1bb/0x1dc
[559353.217494]  [<c11dc073>] ? nf_ct_attach+0x12/0x13
[559353.217494]  [<c1202404>] ? icmp_glue_bits+0x65/0x6a
[559353.217494]  [<c11e4109>] ? ip_append_data+0x595/0x850
[559353.217494]  [<c11e025d>] ? rt_bind_peer+0x1d/0x3d
[559353.217494]  [<c11e029f>] ? __ip_select_ident+0x22/0xa6
[559353.217494]  [<c11e4f60>] ? ip_push_pending_frames+0x206/0x2cb
[559353.217494]  [<c120301b>] ? icmp_send+0x4fe/0x523
[559353.217494]  [<f81a6b09>] ? ____nf_conntrack_find+0xfa/0x142 [nf_conntrack]
[559353.217494]  [<f81a8069>] ? nf_conntrack_in+0x4f3/0x5e3 [nf_conntrack]
[559353.217494]  [<f815c536>] ? ipt_do_table+0x4bc/0x4eb [ip_tables]
[559353.217494]  [<c11e2949>] ? ip_forward+0x2ef/0x316
[559353.217494]  [<c11e13da>] ? ip_rcv_finish+0x2fa/0x31f
[559353.217494]  [<c11c1b3c>] ? __netif_receive_skb+0x405/0x42c
[559353.217494]  [<c11c1a63>] ? __netif_receive_skb+0x32c/0x42c
[559353.217494]  [<c1047585>] ? ktime_get_real+0x10/0x2d
[559353.217494]  [<c11c2547>] ? netif_receive_skb+0x5a/0x5f
[559353.217494]  [<c11c25ff>] ? napi_skb_finish+0x1b/0x30
[559353.217494]  [<f8104723>] ? igb_poll+0x649/0x94a [igb]
[559353.217494]  [<c1007765>] ? sched_clock+0x9/0xd
[559353.217494]  [<c1030094>] ? wait_consider_task+0x977/0xa91
[559353.217494]  [<c104438f>] ? sched_clock_local+0x17/0x13d
[559353.217494]  [<c11c2b7b>] ? net_rx_action+0x90/0x150
[559353.217494]  [<c1031f12>] ? __do_softirq+0x75/0x10e
[559353.217494]  [<c1031e9d>] ? __do_softirq+0x0/0x10e
[559353.217494]  <IRQ>
[559353.217494]  [<c1031df3>] ? irq_exit+0x31/0x64
[559353.217494]  [<c1004397>] ? do_IRQ+0x73/0x84
[559353.217494]  [<c1003429>] ? common_interrupt+0x29/0x30
[559353.217494]  [<c10089b4>] ? mwait_idle+0x4f/0x59
[559353.217494]  [<c10021ef>] ? cpu_idle+0x46/0x63
[559353.217494] Code: 24 08 39 cd 75 09 42 3b 54 24 04 7c e9 eb 18 3b
6c 24 08 8d 50 04 0f 42 d0 89 17 83 c7 04 8b 02 3d 04 ff 25 c1 75 bb
39 d8 74 04 <0f> 0b eb fe 8d 6f fc 81 3b 04 ff 25 c1 89 6c 24 08 75 0d
8b 47
[559353.217494] EIP: [<c11e0caa>] unlink_from_pool+0x85/0x14a SS:ESP
0068:f4c91ba8
[559354.302112] ---[ end trace 55cdab910854890a ]---
[559354.316239] Kernel panic - not syncing: Fatal exception in interrupt
[559354.335557] Pid: 0, comm: kworker/0:0 Tainted: G      D
2.6.38-demyan-1.1demyan #1
[559354.359578] Call Trace:
[559354.367198]  [<c1231f71>] ? panic+0x4d/0x137
[559354.380274]  [<c1005722>] ? oops_end+0x8e/0x99
[559354.393871]  [<c1003a0e>] ? do_invalid_op+0x0/0x75
[559354.408509]  [<c1003a7a>] ? do_invalid_op+0x6c/0x75
[559354.423407]  [<c11e0caa>] ? unlink_from_pool+0x85/0x14a
[559354.439345]  [<c120f068>] ? fib4_rule_action+0x40/0x4d
[559354.455022]  [<c11d1be3>] ? fib_rules_lookup+0x8d/0xe4
[559354.470700]  [<c120f122>] ? fib_lookup+0x31/0x3f
[559354.484818]  [<c11ca4f1>] ? neigh_lookup+0x8e/0x96
[559354.499454]  [<c123464e>] ? error_code+0x5a/0x60
[559354.513571]  [<c1003a0e>] ? do_invalid_op+0x0/0x75
[559354.528208]  [<c11e0caa>] ? unlink_from_pool+0x85/0x14a
[559354.544146]  [<c120f068>] ? fib4_rule_action+0x40/0x4d
[559354.559823]  [<c11d1be3>] ? fib_rules_lookup+0x8d/0xe4
[559354.575500]  [<c11e0de9>] ? cleanup_once+0x7a/0x7f
[559354.590137]  [<c11e0fa9>] ? inet_getpeer+0x1bb/0x1dc
[559354.605297]  [<c11dc073>] ? nf_ct_attach+0x12/0x13
[559354.619934]  [<c1202404>] ? icmp_glue_bits+0x65/0x6a
[559354.635090]  [<c11e4109>] ? ip_append_data+0x595/0x850
[559354.650767]  [<c11e025d>] ? rt_bind_peer+0x1d/0x3d
[559354.665405]  [<c11e029f>] ? __ip_select_ident+0x22/0xa6
[559354.681344]  [<c11e4f60>] ? ip_push_pending_frames+0x206/0x2cb
[559354.699099]  [<c120301b>] ? icmp_send+0x4fe/0x523
[559354.713479]  [<f81a6b09>] ? ____nf_conntrack_find+0xfa/0x142 [nf_conntrack]
[559354.734615]  [<f81a8069>] ? nf_conntrack_in+0x4f3/0x5e3 [nf_conntrack]
[559354.754452]  [<f815c536>] ? ipt_do_table+0x4bc/0x4eb [ip_tables]
[559354.772731]  [<c11e2949>] ? ip_forward+0x2ef/0x316
[559354.787366]  [<c11e13da>] ? ip_rcv_finish+0x2fa/0x31f
[559354.802785]  [<c11c1b3c>] ? __netif_receive_skb+0x405/0x42c
[559354.819762]  [<c11c1a63>] ? __netif_receive_skb+0x32c/0x42c
[559354.836738]  [<c1047585>] ? ktime_get_real+0x10/0x2d
[559354.851901]  [<c11c2547>] ? netif_receive_skb+0x5a/0x5f
[559354.867835]  [<c11c25ff>] ? napi_skb_finish+0x1b/0x30
[559354.883254]  [<f8104723>] ? igb_poll+0x649/0x94a [igb]
[559354.898930]  [<c1007765>] ? sched_clock+0x9/0xd
[559354.912786]  [<c1030094>] ? wait_consider_task+0x977/0xa91
[559354.929502]  [<c104438f>] ? sched_clock_local+0x17/0x13d
[559354.945701]  [<c11c2b7b>] ? net_rx_action+0x90/0x150
[559354.960857]  [<c1031f12>] ? __do_softirq+0x75/0x10e
[559354.975756]  [<c1031e9d>] ? __do_softirq+0x0/0x10e
[559354.990393]  <IRQ>  [<c1031df3>] ? irq_exit+0x31/0x64
[559355.005862]  [<c1004397>] ? do_IRQ+0x73/0x84
[559355.018941]  [<c1003429>] ? common_interrupt+0x29/0x30
[559355.034618]  [<c10089b4>] ? mwait_idle+0x4f/0x59
[559355.048734]  [<c10021ef>] ? cpu_idle+0x46/0x63
[559355.062333] Rebooting in 5 seconds..
