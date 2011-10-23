From: Luciano Ruete <lruete@sequre.com.ar>
Subject: Kernel Panic every 2 weeks on ISP server (NULL pointer dereference)
Date: Sat, 22 Oct 2011 22:18:12 -0300
Message-ID: <201110222218.12524.lruete@sequre.com.ar>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_Ut2oOEodSHp8oIX"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.vita.com.ar ([190.15.202.242]:52786 "HELO vita.com.ar"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752589Ab1JWBY7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Oct 2011 21:24:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_Ut2oOEodSHp8oIX
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I'm the sysadmin at a 3500 customers ISP, wich runs an iptables+tc solution 
for load balancing and QoS.

Every 2 or 3 weeks the server panics with a "NULL pointer dereference" and 
with IP at "dev_queue_xmit"

It is curious that if i disable MSI on the network card driver this panics 
seems to disapear, does this ring a bell?

The server is an IBM, previously with Broadcom NetXtreme II BCM5709 nics and 
now with Intel 82576. I change the nics thinking that maybe the bug was in 
Broadcom Driver but it seems to affect MSI in general.

The tc+iptables rules are auto-generated with sequreisp[1] an ISP solution 
that i wrote and is open sourced under AGPLv3.

Tell me if you need any further information, and plz CC because I'm not 
suscribed. 


root@server:~# uname -a
Linux server 2.6.35-30-server #60~lucid1-Ubuntu SMP Tue Sep 20 22:28:40 UTC 
2011 x86_64 GNU/Linux


[1]https://github.com/sequre/sequreisp

-- 
Luciano Ruete
Sequre - Sys Admin
Mitre 617, piso 7, of. 1 
+54 261 4254894
Mendoza - Argentina
http://www.sequre.com.ar/
http://www.sequreisp.com/

--Boundary-00=_Ut2oOEodSHp8oIX
Content-Type: text/plain;
  name="kern.log.txt"
Content-Transfer-Encoding: 7bit

BUG: unable to handle kernel NULL pointer dereference at (null)
[694244.692704] IP: [<ffffffff814b48ea>] dev_queue_xmit+0xaa/0x5b0
[694244.763424] PGD 16f369067 PUD 16f368067 PMD 0 
[694244.817577] Oops: 0000 [#1] SMP 
[694244.857160] last sysfs file: /sys/devices/system/cpu/cpu7/cache/index2/shared_cpu_map
[694244.951740] CPU 3 
[694244.974623] Modules linked in: xt_mac ppp_deflate zlib_deflate bsd_comp ppp_async crc_ccitt nf_conntrack_netlink nfnetlink xt_owner ipt_REJECT ipt_REDIRECT ipt_MASQUERADE xt_helper xt_length xt_TCPMSS xt_mark xt_connmark xt_state xt_tcpudp xt_multiport iptable_mangle iptable_nat iptable_filter ip_tables x_tables sch_sfq act_mirred cls_u32 sch_prio cls_fw sch_htb ifb dummy 8021q garp stp nf_nat_irc nf_conntrack_irc nf_nat_sip nf_conntrack_sip nf_nat_pptp nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_proto_gre nf_nat_amanda ts_kmp nf_conntrack_amanda nf_nat_ftp nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack_ftp nf_conntrack cdc_ether i7core_edac usbnet serio_raw edac_core tpm_tis tpm ioatdma tpm_bios lp shpchp parport mii raid10 raid456 async_pq async_xor xor async_memcpy async_r
 aid6_recov megaraid_sas raid6_pq async_tx raid1 raid0 multipath igb dca usbhid hid linear
[694245.905128] 
[694245.923881] Pid: 30, comm: events/3 Not tainted 2.6.35-30-server #60~lucid1-Ubuntu 69Y5698     /System x3650 M3 -[7945AC1]-
[694246.057920] RIP: 0010:[<ffffffff814b48ea>]  [<ffffffff814b48ea>] dev_queue_xmit+0xaa/0x5b0
[694246.157723] RSP: 0018:ffff880001e63960  EFLAGS: 00010202
[694246.222176] RAX: 0000000000002000 RBX: ffff880145b6f400 RCX: 000000009fe9dec3
[694246.308451] RDX: 0000000000000004 RSI: 0000000000000000 RDI: ffff88017bd47130
[694246.394725] RBP: ffff880001e639a0 R08: ffff880145b6f400 R09: ffff88017bd47130
[694246.480998] R10: 0000000000000000 R11: 0000000000000003 R12: 0000000000000000
[694246.567265] R13: ffff880118128000 R14: ffff88015c39d300 R15: ffff880001e63b00
[694246.653534] FS:  0000000000000000(0000) GS:ffff880001e60000(0000) knlGS:0000000000000000
[694246.751226] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[694246.820861] CR2: 0000000000000000 CR3: 0000000250400000 CR4: 00000000000006e0
[694246.907128] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[694246.993394] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[694247.079668] Process events/3 (pid: 30, threadinfo ffff880276efe000, task ffff880276ed44d0)
[694247.179433] Stack:
[694247.204410]  0000000000000000 ffff880118128000 ffff880001e639e0 ffff880145b6f400
[694247.291793] <0> 0000000000000000 ffff88015ce2f780 ffff880145b6f400 ffff880001e63b00
[694247.384466] <0> ffff880001e639e0 ffffffff814e9347 ffff880001e63a20 ffff880145b6f400
[694247.479257] Call Trace:
[694247.509424]  <IRQ> 
[694247.535481]  [<ffffffff814e9347>] ip_finish_output+0x237/0x310
[694247.606165]  [<ffffffff814e9738>] ip_output+0xb8/0xc0
[694247.667503]  [<ffffffff814e75d3>] ? __ip_local_out+0xa3/0xb0
[694247.736114]  [<ffffffff814e84c9>] ip_local_out+0x29/0x30
[694247.800566]  [<ffffffff814e8ce1>] ip_queue_xmit+0x191/0x3f0
[694247.868129]  [<ffffffff814fe484>] tcp_transmit_skb+0x3f4/0x700
[694247.938811]  [<ffffffff815002fd>] tcp_send_ack+0xdd/0x130
[694248.004302]  [<ffffffff814fc823>] tcp_rcv_synsent_state_process+0x5a3/0x5b0
[694248.088493]  [<ffffffff815046bf>] ? tcp_v4_inbound_md5_hash+0x7f/0x210
[694248.167486]  [<ffffffff814fcf8d>] tcp_rcv_state_process+0x7d/0x4e0
[694248.242332]  [<ffffffff815048f3>] tcp_v4_do_rcv+0xa3/0x1c0
[694248.308864]  [<ffffffff81505ab9>] tcp_v4_rcv+0x5a9/0x830
[694248.373314]  [<ffffffff814e36a0>] ? ip_local_deliver_finish+0x0/0x290
[694248.451265]  [<ffffffff814db384>] ? nf_hook_slow+0x74/0x100
[694248.518830]  [<ffffffff814e36a0>] ? ip_local_deliver_finish+0x0/0x290
[694248.596781]  [<ffffffff814e377d>] ip_local_deliver_finish+0xdd/0x290
[694248.673696]  [<ffffffff814e39b0>] ip_local_deliver+0x80/0x90
[694248.742300]  [<ffffffff814e2f29>] ip_rcv_finish+0x119/0x410
[694248.809870]  [<ffffffff814e35cd>] ip_rcv+0x23d/0x310
[694248.870167]  [<ffffffff814af233>] __netif_receive_skb+0x383/0x5c0
[694248.943960]  [<ffffffff814af57b>] process_backlog+0x10b/0x210
[694249.013603]  [<ffffffff814b04af>] net_rx_action+0x10f/0x2a0
[694249.081175]  [<ffffffff8106862d>] __do_softirq+0xbd/0x200
[694249.146672]  [<ffffffff810ca950>] ? handle_IRQ_event+0x50/0x160
[694249.218394]  [<ffffffff81068695>] ? __do_softirq+0x125/0x200
[694249.287006]  [<ffffffff8100afdc>] call_softirq+0x1c/0x30
[694249.351458]  [<ffffffff8100cab5>] do_softirq+0x65/0xa0
[694249.413833]  [<ffffffff810684e5>] irq_exit+0x85/0x90
[694249.474131]  [<ffffffff815aac85>] do_IRQ+0x75/0xf0
[694249.532352]  [<ffffffff815a3853>] ret_from_intr+0x0/0x11
[694249.596797]  <EOI> 
[694249.622854]  [<ffffffff815a3319>] ? _raw_spin_unlock_irqrestore+0x19/0x30
[694249.704961]  [<ffffffffa0107826>] ppp_asynctty_receive+0x86/0x100 [ppp_async]
[694249.791233]  [<ffffffff81360816>] flush_to_ldisc+0x1a6/0x1e0
[694249.859834]  [<ffffffff81360670>] ? flush_to_ldisc+0x0/0x1e0
[694249.928442]  [<ffffffff8107b2a5>] run_workqueue+0xc5/0x1a0
[694249.994969]  [<ffffffff8107b423>] worker_thread+0xa3/0x110
[694250.061499]  [<ffffffff810800d0>] ? autoremove_wake_function+0x0/0x40
[694250.139451]  [<ffffffff8107b380>] ? worker_thread+0x0/0x110
[694250.207014]  [<ffffffff8107fb56>] kthread+0x96/0xa0
[694250.266274]  [<ffffffff8100aee4>] kernel_thread_helper+0x4/0x10
[694250.338002]  [<ffffffff8107fac0>] ? kthread+0x0/0xa0
[694250.398296]  [<ffffffff8100aee0>] ? kernel_thread_helper+0x0/0x10
[694250.472081] Code: f6 49 c1 e6 07 66 89 93 ac 00 00 00 4d 03 b5 40 03 00 00 0f b7 83 a6 00 00 00 4d 8b 66 08 80 e4 cf 80 cc 20 66 89 83 a6 00 00 00 <49> 83 3c 24 00 0f 84 3b 02 00 00 49 8d 84 24 9c 00 00 00 48 89 
[694250.700622] RIP  [<ffffffff814b48ea>] dev_queue_xmit+0xaa/0x5b0
[694250.772367]  RSP <ffff880001e63960>
[694250.814999] CR2: 0000000000000000
[694250.855923] ---[ end trace 0c85e47af955446e ]---
[694250.912113] Kernel panic - not syncing: Fatal exception in interrupt
[694250.989074] Pid: 30, comm: events/3 Tainted: G      D     2.6.35-30-server #60~lucid1-Ubuntu
[694251.090974] Call Trace:
[694251.121208]  <IRQ>  [<ffffffff815a0597>] panic+0x90/0x113
[694251.154109] ------------[ cut here ]------------
[694251.154118] WARNING: at /build/buildd/linux-lts-backport-maverick-2.6.35/net/sched/sch_generic.c:258 dev_watchdog+0x25f/0x270()
[694251.154121] Hardware name: System x3650 M3 -[7945AC1]-
[694251.154123] NETDEV WATCHDOG: eth0 (igb): transmit queue 0 timed out
[694251.154124] Modules linked in: xt_mac ppp_deflate zlib_deflate bsd_comp ppp_async crc_ccitt nf_conntrack_netlink nfnetlink xt_owner ipt_REJECT ipt_REDIRECT ipt_MASQUERADE xt_helper xt_length xt_TCPMSS xt_mark xt_connmark xt_state xt_tcpudp xt_multiport iptable_mangle iptable_nat iptable_filter ip_tables x_tables sch_sfq act_mirred cls_u32 sch_prio cls_fw sch_htb ifb dummy 8021q garp stp nf_nat_irc nf_conntrack_irc nf_nat_sip nf_conntrack_sip nf_nat_pptp nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_proto_gre nf_nat_amanda ts_kmp nf_conntrack_amanda nf_nat_ftp nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack_ftp nf_conntrack cdc_ether i7core_edac usbnet serio_raw edac_core tpm_tis tpm ioatdma tpm_bios lp shpchp parport mii raid10 raid456 async_pq async_xor xor async_memcpy async_r
 aid6_recov megaraid_sas raid6_pq async_tx raid1 raid0 multipath igb dca usbhid hid linear
[694251.154174] Pid: 0, comm: swapper Tainted: G      D     2.6.35-30-server #60~lucid1-Ubuntu
[694251.154176] Call Trace:
[694251.154178]  <IRQ>  [<ffffffff8106159f>] warn_slowpath_common+0x7f/0xc0
[694251.154187]  [<ffffffff81061696>] warn_slowpath_fmt+0x46/0x50
[694251.154190]  [<ffffffff814cd81f>] dev_watchdog+0x25f/0x270
[694251.154200]  [<ffffffffa01adc49>] ? destroy_conntrack+0xa9/0xe0 [nf_conntrack]
[694251.154204]  [<ffffffff814db1a7>] ? nf_conntrack_destroy+0x17/0x30
[694251.154211]  [<ffffffffa01ad264>] ? death_by_timeout+0xd4/0x140 [nf_conntrack]
[694251.154214]  [<ffffffff814cd5c0>] ? dev_watchdog+0x0/0x270
[694251.154217]  [<ffffffff814cd5c0>] ? dev_watchdog+0x0/0x270
[694251.154221]  [<ffffffff81070172>] call_timer_fn+0x42/0x120
[694251.154226]  [<ffffffff8105553b>] ? scheduler_tick+0x1db/0x300
[694251.154229]  [<ffffffff814cd5c0>] ? dev_watchdog+0x0/0x270
[694251.154232]  [<ffffffff81071734>] run_timer_softirq+0x154/0x270
[694251.154236]  [<ffffffff8108a683>] ? ktime_get+0x63/0xe0
[694251.154239]  [<ffffffff8106862d>] __do_softirq+0xbd/0x200
[694251.154243]  [<ffffffff8108fa1a>] ? tick_program_event+0x2a/0x30
[694251.154247]  [<ffffffff8100afdc>] call_softirq+0x1c/0x30
[694251.154250]  [<ffffffff8100cab5>] do_softirq+0x65/0xa0
[694251.154253]  [<ffffffff810684e5>] irq_exit+0x85/0x90
[694251.154258]  [<ffffffff815aad70>] smp_apic_timer_interrupt+0x70/0x9b
[694251.154261]  [<ffffffff8100aa93>] apic_timer_interrupt+0x13/0x20
[694251.154263]  <EOI>  [<ffffffff8130ad54>] ? intel_idle+0xe4/0x180
[694251.154271]  [<ffffffff8130ad37>] ? intel_idle+0xc7/0x180
[694251.154277]  [<ffffffff81488062>] cpuidle_idle_call+0x92/0x140
[694251.154281]  [<ffffffff81008d93>] cpu_idle+0xb3/0x110
[694251.154285]  [<ffffffff8159b226>] start_secondary+0x100/0x102
[694251.154288] ---[ end trace 0c85e47af955446f ]---
[694251.154389] igb 0000:17:00.0: eth0: Reset adapter
[694251.273081] igb 0000:18:00.0: eth2: Reset adapter
[694254.499174]  [<ffffffff815a485a>] oops_end+0xea/0xf0
[694254.559522]  [<ffffffff8103e45c>] no_context+0xfc/0x190
[694254.622984]  [<ffffffffa0070155>] ? nfnetlink_has_listeners+0x15/0x20 [nfnetlink]
[694254.713470]  [<ffffffff8103e615>] __bad_area_nosemaphore+0x125/0x1e0
[694254.790433]  [<ffffffff8103e6e3>] bad_area_nosemaphore+0x13/0x20
[694254.863244]  [<ffffffff815a711f>] do_page_fault+0x28f/0x350
[694254.930864]  [<ffffffff815a3b35>] page_fault+0x25/0x30
[694254.993287]  [<ffffffff814b48ea>] ? dev_queue_xmit+0xaa/0x5b0
[694255.062987]  [<ffffffff814e9347>] ip_finish_output+0x237/0x310
[694255.133728]  [<ffffffff814e9738>] ip_output+0xb8/0xc0
[694255.195123]  [<ffffffff814e75d3>] ? __ip_local_out+0xa3/0xb0
[694255.263784]  [<ffffffff814e84c9>] ip_local_out+0x29/0x30
[694255.328283]  [<ffffffff814e8ce1>] ip_queue_xmit+0x191/0x3f0
[694255.395910]  [<ffffffff814fe484>] tcp_transmit_skb+0x3f4/0x700
[694255.466647]  [<ffffffff815002fd>] tcp_send_ack+0xdd/0x130
[694255.532185]  [<ffffffff814fc823>] tcp_rcv_synsent_state_process+0x5a3/0x5b0
[694255.616423]  [<ffffffff815046bf>] ? tcp_v4_inbound_md5_hash+0x7f/0x210
[694255.695489]  [<ffffffff814fcf8d>] tcp_rcv_state_process+0x7d/0x4e0
[694255.770377]  [<ffffffff815048f3>] tcp_v4_do_rcv+0xa3/0x1c0
[694255.838650]  [<ffffffff81505ab9>] tcp_v4_rcv+0x5a9/0x830
[694255.903158]  [<ffffffff814e36a0>] ? ip_local_deliver_finish+0x0/0x290
[694255.981164]  [<ffffffff814db384>] ? nf_hook_slow+0x74/0x100
[694256.048778]  [<ffffffff814e36a0>] ? ip_local_deliver_finish+0x0/0x290
[694256.126783]  [<ffffffff814e377d>] ip_local_deliver_finish+0xdd/0x290
[694256.203750]  [<ffffffff814e39b0>] ip_local_deliver+0x80/0x90
[694256.272413]  [<ffffffff814e2f29>] ip_rcv_finish+0x119/0x410
[694256.340028]  [<ffffffff814e35cd>] ip_rcv+0x23d/0x310
[694256.400385]  [<ffffffff814af233>] __netif_receive_skb+0x383/0x5c0
[694256.474233]  [<ffffffff814af57b>] process_backlog+0x10b/0x210
[694256.543933]  [<ffffffff814b04af>] net_rx_action+0x10f/0x2a0
[694256.611549]  [<ffffffff8106862d>] __do_softirq+0xbd/0x200
[694256.677096]  [<ffffffff810ca950>] ? handle_IRQ_event+0x50/0x160
[694256.748871]  [<ffffffff81068695>] ? __do_softirq+0x125/0x200
[694256.817527]  [<ffffffff8100afdc>] call_softirq+0x1c/0x30
[694256.882030]  [<ffffffff8100cab5>] do_softirq+0x65/0xa0
[694256.944458]  [<ffffffff810684e5>] irq_exit+0x85/0x90
[694257.004807]  [<ffffffff815aac85>] do_IRQ+0x75/0xf0
[694257.063079]  [<ffffffff815a3853>] ret_from_intr+0x0/0x11
[694257.127578]  <EOI>  [<ffffffff815a3319>] ? _raw_spin_unlock_irqrestore+0x19/0x30
[694257.217120]  [<ffffffffa0107826>] ppp_asynctty_receive+0x86/0x100 [ppp_async]
[694257.303447]  [<ffffffff81360816>] flush_to_ldisc+0x1a6/0x1e0
[694257.372104]  [<ffffffff81360670>] ? flush_to_ldisc+0x0/0x1e0
[694257.440768]  [<ffffffff8107b2a5>] run_workqueue+0xc5/0x1a0
[694257.507355]  [<ffffffff8107b423>] worker_thread+0xa3/0x110
[694257.573940]  [<ffffffff810800d0>] ? autoremove_wake_function+0x0/0x40
[694257.651961]  [<ffffffff8107b380>] ? worker_thread+0x0/0x110
[694257.719582]  [<ffffffff8107fb56>] kthread+0x96/0xa0
[694257.778897]  [<ffffffff8100aee4>] kernel_thread_helper+0x4/0x10
[694257.850666]  [<ffffffff8107fac0>] ? kthread+0x0/0xa0
[694257.911018]  [<ffffffff8100aee0>] ? kernel_thread_helper+0x0/0x10
[694257.984951] Rebooting in 1 seconds..[    0.000000] Initializing cgroup subsys cpuset
--Boundary-00=_Ut2oOEodSHp8oIX--
