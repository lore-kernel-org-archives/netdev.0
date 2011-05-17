From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Bug, kernel panic, NULL dereference , =?UTF-8?Q?cleanup=5Fonce=20?=  =?UTF-8?Q?/=20icmp=5Froute=5Flookup=2Eclone=2E=31=39=2Eclone=20/=20nat=20?=  =?UTF-8?Q?=2C=20=32=2E=36=2E=33=39-rc=37-git=31=31?=
Date: Wed, 18 May 2011 01:16:29 +0300
Message-ID: <54ec5cd14e5e5c76aa06c2e6899299ce@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rev-153-13.globalproof.net ([194.146.153.13]:60690 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751984Ab1EQWQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 18:16:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Just got recently. 32Bit, PPPoE NAS, shapers, firewall, NAT
 Kernel i mention in subject, 2.6.39-rc7-git11
 If required i can give more information

 sharanal (sorry for ugly name) is libpcap based traffic analyser, sure 
 userspace

  [44528.153869] BUG: unable to handle kernel NULL pointer dereference 
 at 0000001a
  [44528.153869] IP: [<c02e8614>] cleanup_once+0x49/0x1cf
  [44528.153869] *pdpt = 0000000034a73001 *pde = 0000000000000000
  [44528.153869] Oops: 0002 [#1] SMP
  [44528.153869] last sysfs file: 
 /sys/devices/system/cpu/cpu3/cache/index1/shared_cpu_map
  [44528.153869] Modules linked in: nf_conntrack_netlink nfnetlink 
 ipt_LOG rtc_cmos rtc_core rtc_lib act_skbedit sch_ingress sch_prio 
 bridge cls_flow cls_u32 em_meta cls_basic xt_dscp ipt_REJECT xt_hl ifb 
 cls_fw sch_tbf sch_htb a
  [44528.153869]
  [44528.153869] Pid: 1744, comm: sharanal Not tainted 
 2.6.39-rc7-git11-build-0058 #6 Intel                                  
 /SE7520BD2S
  [44528.153869] EIP: 0060:[<c02e8614>] EFLAGS: 00010286 CPU: 1
  [44528.153869] EIP is at cleanup_once+0x49/0x1cf
  [44528.153869] EAX: dd378920 EBX: dd378900 ECX: 00000016 EDX: 06000001
  [44528.153869] ESI: 00000000 EDI: e4b6a59c EBP: f5485b8c ESP: f5485b68
  [44528.153869]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
  [44528.153869] Process sharanal (pid: 1744, ti=f5484000 task=f4c9b6c0 
 task.ti=f4fa4000)
  [44528.153869] Stack:
  [44528.153869]  f5485c6c f5485ba4 f5485ba4 00000013 f5485ba4 f5485b84 
 e4b6a500 f5485c6c
  [44528.153869]  e4b6a59c f5485c50 c02e8b30 f5485bec f5485c58 00000000 
 c04602d4 c04602d4
  [44528.153869]  e4252504 f0aecc04 e3ee3200 e8d1b200 efd0ab00 e489dc00 
 e422e900 e9b18100
  [44528.153869] Call Trace:
  [44528.153869]  [<c02e8b30>] inet_getpeer+0x2ab/0x2cf
  [44528.153869]  [<c03080bc>] ? 
 icmp_route_lookup.clone.19.clone.20+0x197/0x1cb
  [44528.153869]  [<c01320a5>] ? _local_bh_enable_ip.clone.6+0x18/0x71
  [44528.153869]  [<c0132106>] ? local_bh_enable_ip+0x8/0xa
  [44528.153869]  [<f88c0929>] ? nf_nat_setup_info+0x3b0/0x3db [nf_nat]
  [44528.153869]  [<c0318591>] ? ipt_do_table+0x41c/0x437
  [44528.153869]  [<c02e56a8>] inet_getpeer_v4+0x17/0x19
  [44528.153869]  [<c02e7a72>] rt_bind_peer+0xe/0x39
  [44528.153869]  [<c030818d>] icmpv4_xrlim_allow.clone.22+0x4b/0x5f
  [44528.153869]  [<c03083d4>] icmp_send+0x203/0x282
  [44528.153869]  [<f88b23aa>] ? ipv4_confirm+0x131/0x13e 
 [nf_conntrack_ipv4]
  [44528.153869]  [<c030633b>] __udp4_lib_rcv+0x2d7/0x3f9
  [44528.153869]  [<c02e2d25>] ? nf_iterate+0x52/0x65
  [44528.153869]  [<c02e8efb>] ? xfrm4_policy_check.clone.10+0x47/0x47
  [44528.153869]  [<c030646f>] udp_rcv+0x12/0x14
  [44528.153869]  [<c02e8fc5>] ip_local_deliver_finish+0xca/0x171
  [44528.153869]  [<c02e8efb>] ? xfrm4_policy_check.clone.10+0x47/0x47
  [44528.153869]  [<c02e90b2>] NF_HOOK.clone.11+0x46/0x4d
  [44528.153869]  [<c02e8efb>] ? xfrm4_policy_check.clone.10+0x47/0x47
  [44528.153869]  [<c02e91b6>] ip_local_deliver+0x41/0x45
  [44528.153869]  [<c02e8efb>] ? xfrm4_policy_check.clone.10+0x47/0x47
  [44528.153869]  [<c02e8e92>] ip_rcv_finish+0x2b4/0x2d6
  [44528.153869]  [<c02e8bde>] ? pskb_may_pull+0x30/0x30
  [44528.153869]  [<c02e90b2>] NF_HOOK.clone.11+0x46/0x4d
  [44528.153869]  [<c02e8bde>] ? pskb_may_pull+0x30/0x30
  [44528.153869]  [<c02e93a0>] ip_rcv+0x1e6/0x21a
  [44528.153869]  [<c02e8bde>] ? pskb_may_pull+0x30/0x30
  [44528.153869]  [<c02c929d>] __netif_receive_skb+0x351/0x379
  [44528.153869]  [<c02c93f5>] netif_receive_skb+0x46/0x4c
  [44528.153869]  [<c02c9826>] ? __napi_gro_receive+0x9e/0xa6
  [44528.153869]  [<c02c94b6>] napi_skb_finish+0x1e/0x34
  [44528.153869]  [<c02c987d>] napi_gro_receive+0x20/0x24
  [44528.153869]  [<f84e6516>] e1000_receive_skb+0x5a/0x62 [e1000]
  [44528.153869]  [<f84e8ac9>] e1000_clean_rx_irq+0x28d/0x323 [e1000]
  [44528.153869]  [<f84e845d>] e1000_clean+0x2cc/0x43e [e1000]
  [44528.153869]  [<c02db37e>] ? qdisc_watchdog_schedule+0x39/0x3e
  [44528.153869]  [<f8cd8221>] ? tbf_dequeue+0x1d/0x1b6 [sch_tbf]
  [44528.153869]  [<c02b0d50>] ? dma_issue_pending_all+0x60/0x6e
  [44528.153869]  [<c02c9961>] net_rx_action+0x86/0x139
  [44528.153869]  [<c0132179>] __do_softirq+0x67/0xf3
  [44528.153869]  [<c0132112>] ? local_bh_enable+0xa/0xa
  [44528.153869]  <IRQ>
  [44528.153869]  [<c0132362>] ? irq_exit+0x35/0x70
  [44528.153869]  [<c0103d13>] ? do_IRQ+0x79/0x8d
  [44528.153869]  [<c0132379>] ? irq_exit+0x4c/0x70
  [44528.153869]  [<c011598a>] ? smp_apic_timer_interrupt+0x66/0x73
  [44528.153869]  [<c0337c29>] ? common_interrupt+0x29/0x30
  [44528.153869]  [<c033007b>] ? cpu_init+0x65/0x1c5
  [44528.153869] Code: c8 02 46 c0 74 3a 8d 58 e0 8b 15 40 9a 44 c0 2b 
 53 28 39 f2 73 0f b8 d0 02 46 c0 e8 6b e7 04 00 e9 81 01 00 00 8b 4b 20 
 8b 53 24
  9>[44528.153869]  51 04 89 0a 89 43 20 89 43 24 83 c0 0c e8 cd fd ff 
 ff eb 02
  [44528.153869] EIP: [<c02e8614>] cleanup_once+0x49/0x1cf SS:ESP 
 0068:f5485b68
  [44528.153869] CR2: 000000000000001a
  [44528.167278] ---[ end trace dd3639ec5ab2f01f ]---
  [44528.167468] Kernel panic - not syncing: Fatal exception in 
 interrupt
  [44528.167660] Pid: 1744, comm: sharanal Tainted: G      D     
 2.6.39-rc7-git11-build-0058 #6
  [44528.167992] Call Trace:
  [44528.168190]  [<c0335548>] ? printk+0x18/0x20
  [44528.168374]  [<c0335435>] panic+0x57/0x152
  [44528.168567]  [<c0104e7a>] oops_end+0x92/0x9f
  [44528.168759]  [<c011b95e>] no_context+0x151/0x159
  [44528.168948]  [<c011ba72>] __bad_area_nosemaphore+0x10c/0x114
  [44528.169154]  [<c02ca7df>] ? dev_hard_start_xmit+0x338/0x3f8
  [44528.169353]  [<c011ba8c>] bad_area_nosemaphore+0x12/0x14
  [44528.169544]  [<c011bd0c>] do_page_fault+0x12e/0x2ee
  [44528.169737]  [<c021ba8f>] ? memcmp+0xe/0x25
  [44528.169922]  [<c01320a5>] ? _local_bh_enable_ip.clone.6+0x18/0x71
  [44528.170125]  [<c0132110>] ? local_bh_enable+0x8/0xa
  [44528.170326]  [<c02d1a97>] ? neigh_lookup+0x8b/0x95
  [44528.170517]  [<c011bbde>] ? vmalloc_sync_all+0x5/0x5
  [44528.170713]  [<c03374da>] error_code+0x5a/0x60
  [44528.170907]  [<c01300d8>] ? wait_consider_task+0x3f2/0x76f
  [44528.171111]  [<c011bbde>] ? vmalloc_sync_all+0x5/0x5
  [44528.171304]  [<c02e8614>] ? cleanup_once+0x49/0x1cf
  [44528.171484]  [<c02e8b30>] inet_getpeer+0x2ab/0x2cf
  [44528.171672]  [<c03080bc>] ? 
 icmp_route_lookup.clone.19.clone.20+0x197/0x1cb
  [44528.171861]  [<c01320a5>] ? _local_bh_enable_ip.clone.6+0x18/0x71
  [44528.172063]  [<c0132106>] ? local_bh_enable_ip+0x8/0xa
  [44528.172262]  [<f88c0929>] ? nf_nat_setup_info+0x3b0/0x3db [nf_nat]
  [44528.172445]  [<c0318591>] ? ipt_do_table+0x41c/0x437
  [44528.172626]  [<c02e56a8>] inet_getpeer_v4+0x17/0x19
  [44528.172809]  [<c02e7a72>] rt_bind_peer+0xe/0x39
  [44528.172990]  [<c030818d>] icmpv4_xrlim_allow.clone.22+0x4b/0x5f
  [44528.173196]  [<c03083d4>] icmp_send+0x203/0x282+++
