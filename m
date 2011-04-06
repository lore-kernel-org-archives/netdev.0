From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Fw: [Bug 32772] New: PROBLEM: kernel BUG at net/ipv4/inetpeer.c:386
Date: Wed, 6 Apr 2011 08:18:18 -0700
Message-ID: <20110406081818.4f0489b5@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56288 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756124Ab1DFPSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 11:18:53 -0400
Received: from nehalam (static-50-53-80-93.bvtn.or.frontiernet.net [50.53.80.93])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p36FIJjk008365
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 6 Apr 2011 08:18:21 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 6 Apr 2011 07:39:54 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 32772] New: PROBLEM: kernel BUG at net/ipv4/inetpeer.c:386


https://bugzilla.kernel.org/show_bug.cgi?id=32772

           Summary: PROBLEM: kernel BUG at net/ipv4/inetpeer.c:386
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.38
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: dimetrios@gmail.com
        Regression: No


Kernel oopses periodically with 'kernel BUG at net/ipv4/inetpeer.c:386'
message. Machine is used as BGP router and runs Quagga. Nonordinary kernel
config option set: CONFIG_IP_FIB_TRIE=y.
Two traces:
--------------------trace begin--------------
[625279.329241] kernel BUG at net/ipv4/inetpeer.c:386!
[625279.329241] invalid opcode: 0000 [#1] SMP
[625279.329241] last sysfs file: /sys/module/ip_tables/initstate
[625279.329241] Modules linked in: nf_nat_pptp nf_nat_proto_gre
nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_ftp nf_conntrack_ftp ipt_REJECT
xt_state xt_tcpudp xt_multiport ip_set iptable_filter iptable_mangle
iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip_tables
x_tables act_police cls_u32 sch_ingress sch_tbf 8021q garp bridge ipv6 stp llc
loop i2c_i801 intel_agp parport_pc i2c_core intel_gtt rng_core agpgart
processor parport button evdev pcspkr thermal_sys serio_raw tpm_tis tpm
tpm_bios ext3 jbd mbcache sd_mod crc_t10dif ata_generic ata_piix libata
scsi_mod uhci_hcd ide_pci_generic e1000e ehci_hcd r8169 ide_core igb dca mii
usbcore nls_base [last unloaded: scsi_wait_scan]
[625279.329241]
[625279.329241] Pid: 0, comm: kworker/0:0 Not tainted 2.6.38-demyan-1.1demyan
#1 Gigabyte Technology Co., Ltd. G41MT-ES2L/G41MT-ES2L
[625279.329241] EIP: 0060:[<c11e0caa>] EFLAGS: 00010283 CPU: 1
[625279.329241] EIP is at unlink_from_pool+0x85/0x14a
[625279.329241] EAX: c125ff04 EBX: ed21cd40 ECX: c351ce70 EDX: e8db5b40
[625279.329241] ESI: c1333338 EDI: f4c91ca0 EBP: c351b55e ESP: f4c91c48
[625279.329241]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[625279.329241] Process kworker/0:0 (pid: 0, ti=f4c90000 task=f4c6a400
task.ti=f4c8c000)
[625279.329241] Stack:
[625279.329241]  f1be9b00 00000001 c351ce70 c133333c c1333338 ed21a684 f11a3f84
f0146f00
[625279.329241]  ed2dca80 ed21a900 f0146644 ec4c2f40 f0146280 ec701dc0 f0467fc0
eea79604
[625279.329241]  f16c12c0 ef727900 ec865784 e721a3c0 ee859cc4 e8db5b40 00000640
00000014
[625279.329241] Call Trace:
[625279.329241]  [<c11ea34a>] ? tcp_tso_segment+0x24d/0x25c
[625279.329241]  [<f820048a>] ? tcp_packet+0xb8e/0xbb8 [nf_conntrack]
[625279.329241]  [<c11e0de9>] ? cleanup_once+0x7a/0x7f
[625279.329241]  [<c11e0fa9>] ? inet_getpeer+0x1bb/0x1dc
[625279.329241]  [<c11d0001>] ? store_xps_map+0xa1/0x2b8
[625279.329241]  [<c11c3477>] ? dev_hard_start_xmit+0x36f/0x454
[625279.329241]  [<c1021ef1>] ? get_nohz_timer_target+0x47/0x64
[625279.329241]  [<c11e1cb0>] ? ip4_frag_init+0x66/0x71
[625279.329241]  [<c120bb54>] ? inet_frag_find+0x80/0x18d
[625279.329241]  [<c11e1dec>] ? ip_defrag+0x131/0x955
[625279.329241]  [<f81be0b1>] ? ipv4_conntrack_defrag+0xb0/0xd3
[nf_defrag_ipv4]
[625279.329241]  [<c11dc036>] ? nf_iterate+0x32/0x5d
[625279.329241]  [<c11e10e0>] ? ip_rcv_finish+0x0/0x31f
[625279.329241]  [<c11dc13d>] ? nf_hook_slow+0x40/0xb5
[625279.329241]  [<c11e10e0>] ? ip_rcv_finish+0x0/0x31f
[625279.329241]  [<c11e164c>] ? ip_rcv+0x24d/0x293
[625279.329241]  [<c11e10e0>] ? ip_rcv_finish+0x0/0x31f
[625279.329241]  [<c11c1b3c>] ? __netif_receive_skb+0x405/0x42c
[625279.329241]  [<c11c1a63>] ? __netif_receive_skb+0x32c/0x42c
[625279.329241]  [<c1047585>] ? ktime_get_real+0x10/0x2d
[625279.329241]  [<c11c2547>] ? netif_receive_skb+0x5a/0x5f
[625279.329241]  [<c11c25ff>] ? napi_skb_finish+0x1b/0x30
[625279.329241]  [<f80a9723>] ? igb_poll+0x649/0x94a [igb]
[625279.329241]  [<c1007765>] ? sched_clock+0x9/0xd
[625279.329241]  [<c1030582>] ? do_exit+0x2e/0x60c
[625279.329241]  [<c104438f>] ? sched_clock_local+0x17/0x13d
[625279.329241]  [<c11c2b7b>] ? net_rx_action+0x90/0x150
[625279.329241]  [<c1031f12>] ? __do_softirq+0x75/0x10e
[625279.329241]  [<c1031e9d>] ? __do_softirq+0x0/0x10e
[625279.329241]  <IRQ>
[625279.329241]  [<c1031df3>] ? irq_exit+0x31/0x64
[625279.329241]  [<c1004397>] ? do_IRQ+0x73/0x84
[625279.329241]  [<c1003429>] ? common_interrupt+0x29/0x30
[625279.329241]  [<c10089b4>] ? mwait_idle+0x4f/0x59
[625279.329241]  [<c10021ef>] ? cpu_idle+0x46/0x63
[625279.329241] Code: 24 08 39 cd 75 09 42 3b 54 24 04 7c e9 eb 18 3b 6c 24 08
8d 50 04 0f 42 d0 89 17 83 c7 04 8b 02 3d 04 ff 25 c1 75 bb 39 d8 74 04 <0f> 0b
eb fe 8d 6f fc 81 3b 04 ff 25 c1 89 6c 24 08 75 0d 8b 47
[625279.329241] EIP: [<c11e0caa>] unlink_from_pool+0x85/0x14a SS:ESP
0068:f4c91c48
[625280.416294] ---[ end trace b75ce593ad6cbee7 ]---
[625280.430422] Kernel panic - not syncing: Fatal exception in interrupt
[625280.449739] Pid: 0, comm: kworker/0:0 Tainted: G      D    
2.6.38-demyan-1.1demyan #1
[625280.473762] Call Trace:
[625280.481380]  [<c1231f71>] ? panic+0x4d/0x137
[625280.494457]  [<c1005722>] ? oops_end+0x8e/0x99
[625280.508054]  [<c1003a0e>] ? do_invalid_op+0x0/0x75
[625280.522693]  [<c1003a7a>] ? do_invalid_op+0x6c/0x75
[625280.537588]  [<c11e0caa>] ? unlink_from_pool+0x85/0x14a
[625280.553527]  [<c11e0bbd>] ? inet_putpeer+0x15/0x47
[625280.568165]  [<c11e0d64>] ? unlink_from_pool+0x13f/0x14a
[625280.584367]  [<f80a9ed6>] ? igb_xmit_frame_ring_adv+0x4b2/0x795 [igb]
[625280.603941]  [<c1007765>] ? sched_clock+0x9/0xd
[625280.617797]  [<c123464e>] ? error_code+0x5a/0x60
[625280.631913]  [<c1003a0e>] ? do_invalid_op+0x0/0x75
[625280.646552]  [<c11e0caa>] ? unlink_from_pool+0x85/0x14a
[625280.662490]  [<c11ea34a>] ? tcp_tso_segment+0x24d/0x25c
[625280.678427]  [<f820048a>] ? tcp_packet+0xb8e/0xbb8 [nf_conntrack]
[625280.696964]  [<c11e0de9>] ? cleanup_once+0x7a/0x7f
[625280.711600]  [<c11e0fa9>] ? inet_getpeer+0x1bb/0x1dc
[625280.726758]  [<c11d0001>] ? store_xps_map+0xa1/0x2b8
[625280.741916]  [<c11c3477>] ? dev_hard_start_xmit+0x36f/0x454
[625280.758894]  [<c1021ef1>] ? get_nohz_timer_target+0x47/0x64
[625280.775870]  [<c11e1cb0>] ? ip4_frag_init+0x66/0x71
[625280.790768]  [<c120bb54>] ? inet_frag_find+0x80/0x18d
[625280.806184]  [<c11e1dec>] ? ip_defrag+0x131/0x955
[625280.820562]  [<f81be0b1>] ? ipv4_conntrack_defrag+0xb0/0xd3
[nf_defrag_ipv4]
[625280.841961]  [<c11dc036>] ? nf_iterate+0x32/0x5d
[625280.856078]  [<c11e10e0>] ? ip_rcv_finish+0x0/0x31f
[625280.870975]  [<c11dc13d>] ? nf_hook_slow+0x40/0xb5
[625280.885612]  [<c11e10e0>] ? ip_rcv_finish+0x0/0x31f
[625280.900510]  [<c11e164c>] ? ip_rcv+0x24d/0x293
[625280.914107]  [<c11e10e0>] ? ip_rcv_finish+0x0/0x31f
[625280.929005]  [<c11c1b3c>] ? __netif_receive_skb+0x405/0x42c
[625280.945982]  [<c11c1a63>] ? __netif_receive_skb+0x32c/0x42c
[625280.962960]  [<c1047585>] ? ktime_get_real+0x10/0x2d
[625280.978121]  [<c11c2547>] ? netif_receive_skb+0x5a/0x5f
[625280.994055]  [<c11c25ff>] ? napi_skb_finish+0x1b/0x30
[625281.009473]  [<f80a9723>] ? igb_poll+0x649/0x94a [igb]
[625281.025150]  [<c1007765>] ? sched_clock+0x9/0xd
[625281.039005]  [<c1030582>] ? do_exit+0x2e/0x60c
[625281.052603]  [<c104438f>] ? sched_clock_local+0x17/0x13d
[625281.068800]  [<c11c2b7b>] ? net_rx_action+0x90/0x150
[625281.083958]  [<c1031f12>] ? __do_softirq+0x75/0x10e
[625281.098857]  [<c1031e9d>] ? __do_softirq+0x0/0x10e
[625281.113493]  <IRQ>  [<c1031df3>] ? irq_exit+0x31/0x64
[625281.128963]  [<c1004397>] ? do_IRQ+0x73/0x84
[625281.142040]  [<c1003429>] ? common_interrupt+0x29/0x30
[625281.157718]  [<c10089b4>] ? mwait_idle+0x4f/0x59
[625281.171836]  [<c10021ef>] ? cpu_idle+0x46/0x63
[625281.185435] Rebooting in 5 seconds..
--------------------trace end--------------

--------------------trace begin--------------
[237684.673906] kernel BUG at net/ipv4/inetpeer.c:386!
[237684.673906] invalid opcode: 0000 [#1] SMP
[237684.673906] last sysfs file: /sys/module/nf_conntrack_pptp/initstate
[237684.673906] Modules linked in: nf_nat_pptp nf_nat_proto_gre
nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_ftp nf_conntrack_ftp ipt_REJECT
xt_state xt_tcpudp xt_multiport ip_set iptable_filter iptable_mangle
iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip_tables
x_tables act_police cls_u32 sch_ingress sch_tbf 8021q garp bridge ipv6 stp llc
loop i2c_i801 rng_core intel_agp intel_gtt agpgart i2c_core tpm_tis evdev
pcspkr parport_pc processor parport button tpm thermal_sys tpm_bios serio_raw
ext3 jbd mbcache sd_mod crc_t10dif ata_generic ata_piix libata scsi_mod
uhci_hcd ide_pci_generic r8169 ehci_hcd e1000e mii igb dca ide_core usbcore
nls_base [last unloaded: scsi_wait_scan]
[237684.673906]
[237684.673906] Pid: 0, comm: swapper Not tainted 2.6.38-demyan-1.1demyan #1
Gigabyte Technology Co., Ltd. G41MT-ES2L/G41MT-ES2L
[237684.673906] EIP: 0060:[<c11e0caa>] EFLAGS: 00010287 CPU: 0
[237684.673906] EIP is at unlink_from_pool+0x85/0x14a
[237684.673906] EAX: c125ff04 EBX: ed76d180 ECX: 75c219bc EDX: e8de9444
[237684.673906] ESI: c1333338 EDI: f4c0bbfc EBP: 75c25152 ESP: f4c0bba8
[237684.673906]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[237684.673906] Process swapper (pid: 0, ti=f4c0a000 task=c1315f20
task.ti=c1300000)
[237684.673906] Stack:
[237684.673906]  ef42e49c 00000001 75c219bc c133333c c1333338 f4780d80 ed76d744
f19e3744
[237684.673906]  ed71f980 f452a404 f183fc04 f452afc4 f4780ac0 f18ca680 f474fe84
f1871180
[237684.673906]  ee2a9884 edef3844 f1cf3e04 edf15284 e8de9444 f4c0bcb4 ef42e49c
f4c0bc78
[237684.673906] Call Trace:
[237684.673906]  [<c120f068>] ? fib4_rule_action+0x40/0x4d
[237684.673906]  [<c11d1be3>] ? fib_rules_lookup+0x8d/0xe4
[237684.673906]  [<c109bf68>] ? cache_alloc_refill+0x75/0x3dc
[237684.673906]  [<c11e0de9>] ? cleanup_once+0x7a/0x7f
[237684.673906]  [<c11e0fa9>] ? inet_getpeer+0x1bb/0x1dc
[237684.673906]  [<c11dc073>] ? nf_ct_attach+0x12/0x13
[237684.673906]  [<c1202404>] ? icmp_glue_bits+0x65/0x6a
[237684.673906]  [<c11e4109>] ? ip_append_data+0x595/0x850
[237684.673906]  [<c11e025d>] ? rt_bind_peer+0x1d/0x3d
[237684.673906]  [<c11e029f>] ? __ip_select_ident+0x22/0xa6
[237684.673906]  [<c11e4f60>] ? ip_push_pending_frames+0x206/0x2cb
[237684.673906]  [<c120301b>] ? icmp_send+0x4fe/0x523
[237684.673906]  [<f8270b09>] ? ____nf_conntrack_find+0xfa/0x142 [nf_conntrack]
[237684.673906]  [<f8272069>] ? nf_conntrack_in+0x4f3/0x5e3 [nf_conntrack]
[237684.673906]  [<f81ef536>] ? ipt_do_table+0x4bc/0x4eb [ip_tables]
[237684.673906]  [<c11e2949>] ? ip_forward+0x2ef/0x316
[237684.673906]  [<c11e13da>] ? ip_rcv_finish+0x2fa/0x31f
[237684.673906]  [<c11c1b3c>] ? __netif_receive_skb+0x405/0x42c
[237684.673906]  [<c11c1a63>] ? __netif_receive_skb+0x32c/0x42c
[237684.673906]  [<c1047585>] ? ktime_get_real+0x10/0x2d
[237684.673906]  [<c11c2547>] ? netif_receive_skb+0x5a/0x5f
[237684.673906]  [<c11c25ff>] ? napi_skb_finish+0x1b/0x30
[237684.673906]  [<f80e1723>] ? igb_poll+0x649/0x94a [igb]
[237684.673906]  [<c1007765>] ? sched_clock+0x9/0xd
[237684.673906]  [<c1030091>] ? wait_consider_task+0x974/0xa91
[237684.673906]  [<c104438f>] ? sched_clock_local+0x17/0x13d
[237684.673906]  [<c11c2b7b>] ? net_rx_action+0x90/0x150
[237684.673906]  [<c1031f12>] ? __do_softirq+0x75/0x10e
[237684.673906]  [<c1031e9d>] ? __do_softirq+0x0/0x10e
[237684.673906]  <IRQ>
[237684.673906]  [<c1031df3>] ? irq_exit+0x31/0x64
[237684.673906]  [<c1004397>] ? do_IRQ+0x73/0x84
[237684.673906]  [<c1003429>] ? common_interrupt+0x29/0x30
[237684.673906]  [<c10089b4>] ? mwait_idle+0x4f/0x59
[237684.673906]  [<c10021ef>] ? cpu_idle+0x46/0x63
[237684.673906]  [<c133b85c>] ? start_kernel+0x2e2/0x2e5
[237684.673906] Code: 24 08 39 cd 75 09 42 3b 54 24 04 7c e9 eb 18 3b 6c 24 08
8d 50 04 0f 42 d0 89 17 83 c7 04 8b 02 3d 04 ff 25 c1 75 bb 39 d8 74 04 <0f> 0b
eb fe 8d 6f fc 81 3b 04 ff 25 c1 89 6c 24 08 75 0d 8b 47
[237684.673906] EIP: [<c11e0caa>] unlink_from_pool+0x85/0x14a SS:ESP
0068:f4c0bba8
[237685.787747] ---[ end trace e3c73323a4e3b283 ]---
[237685.801876] Kernel panic - not syncing: Fatal exception in interrupt
[237685.821194] Pid: 0, comm: swapper Tainted: G      D    
2.6.38-demyan-1.1demyan #1
[237685.844177] Call Trace:
[237685.851797]  [<c1231f71>] ? panic+0x4d/0x137
[237685.864874]  [<c1005722>] ? oops_end+0x8e/0x99
[237685.878471]  [<c1003a0e>] ? do_invalid_op+0x0/0x75
[237685.893109]  [<c1003a7a>] ? do_invalid_op+0x6c/0x75
[237685.908005]  [<c11e0caa>] ? unlink_from_pool+0x85/0x14a
[237685.923942]  [<c1007765>] ? sched_clock+0x9/0xd
[237685.937801]  [<c1007765>] ? sched_clock+0x9/0xd
[237685.951658]  [<c104438f>] ? sched_clock_local+0x17/0x13d
[237685.967856]  [<c123464e>] ? error_code+0x5a/0x60
[237685.981973]  [<c1003a0e>] ? do_invalid_op+0x0/0x75
[237685.996610]  [<c11e0caa>] ? unlink_from_pool+0x85/0x14a
[237686.012548]  [<c120f068>] ? fib4_rule_action+0x40/0x4d
[237686.028225]  [<c11d1be3>] ? fib_rules_lookup+0x8d/0xe4
[237686.043902]  [<c109bf68>] ? cache_alloc_refill+0x75/0x3dc
[237686.060359]  [<c11e0de9>] ? cleanup_once+0x7a/0x7f
[237686.074997]  [<c11e0fa9>] ? inet_getpeer+0x1bb/0x1dc
[237686.090156]  [<c11dc073>] ? nf_ct_attach+0x12/0x13
[237686.104792]  [<c1202404>] ? icmp_glue_bits+0x65/0x6a
[237686.119949]  [<c11e4109>] ? ip_append_data+0x595/0x850
[237686.135626]  [<c11e025d>] ? rt_bind_peer+0x1d/0x3d
[237686.150264]  [<c11e029f>] ? __ip_select_ident+0x22/0xa6
[237686.166202]  [<c11e4f60>] ? ip_push_pending_frames+0x206/0x2cb
[237686.183959]  [<c120301b>] ? icmp_send+0x4fe/0x523
[237686.198338]  [<f8270b09>] ? ____nf_conntrack_find+0xfa/0x142 [nf_conntrack]
[237686.219474]  [<f8272069>] ? nf_conntrack_in+0x4f3/0x5e3 [nf_conntrack]
[237686.239311]  [<f81ef536>] ? ipt_do_table+0x4bc/0x4eb [ip_tables]
[237686.257589]  [<c11e2949>] ? ip_forward+0x2ef/0x316
[237686.272227]  [<c11e13da>] ? ip_rcv_finish+0x2fa/0x31f
[237686.287643]  [<c11c1b3c>] ? __netif_receive_skb+0x405/0x42c
[237686.304620]  [<c11c1a63>] ? __netif_receive_skb+0x32c/0x42c
[237686.321599]  [<c1047585>] ? ktime_get_real+0x10/0x2d
[237686.336760]  [<c11c2547>] ? netif_receive_skb+0x5a/0x5f
[237686.352692]  [<c11c25ff>] ? napi_skb_finish+0x1b/0x30
[237686.368111]  [<f80e1723>] ? igb_poll+0x649/0x94a [igb]
[237686.383788]  [<c1007765>] ? sched_clock+0x9/0xd
[237686.397645]  [<c1030091>] ? wait_consider_task+0x974/0xa91
[237686.414362]  [<c104438f>] ? sched_clock_local+0x17/0x13d
[237686.430559]  [<c11c2b7b>] ? net_rx_action+0x90/0x150
[237686.445718]  [<c1031f12>] ? __do_softirq+0x75/0x10e
[237686.460614]  [<c1031e9d>] ? __do_softirq+0x0/0x10e
[237686.475251]  <IRQ>  [<c1031df3>] ? irq_exit+0x31/0x64
[237686.490722]  [<c1004397>] ? do_IRQ+0x73/0x84
[237686.503799]  [<c1003429>] ? common_interrupt+0x29/0x30
[237686.519476]  [<c10089b4>] ? mwait_idle+0x4f/0x59
[237686.533593]  [<c10021ef>] ? cpu_idle+0x46/0x63
[237686.547191]  [<c133b85c>] ? start_kernel+0x2e2/0x2e5
[237686.562350] Rebooting in 5 seconds..
--------------------trace end--------------

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.


-- 
