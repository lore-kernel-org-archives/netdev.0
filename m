From: Dave Jones <davej@codemonkey.org.uk>
Subject: 4.4-rc2 xfrm_lookup kasan trace
Date: Mon, 30 Nov 2015 18:27:33 -0500
Message-ID: <20151130232733.GA27119@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:35722 "EHLO
	arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754087AbbK3X1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 18:27:45 -0500
Received: from [209.6.119.210] (helo=wopr.kernelslacker.org)
	by arcturus.aphlor.org with esmtpsa (TLSv1.2:DHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.84)
	(envelope-from <davej@codemonkey.org.uk>)
	id 1a3XrB-0001vB-MK
	for netdev@vger.kernel.org; Mon, 30 Nov 2015 23:27:44 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My router fell off the internet. When I got home, I found a few hundred
of these traces in the logs, and it refusing to route packets.

Oddly, it only prints a stack trace, and no clue as to why it printed that trace.

There was also nothing in the log prior to this that indicates how it got that B taint flag.

	Dave


[603360.306331] CPU: 1 PID: 0 Comm: swapper/1 Tainted: G    B           4.4.0-rc2-firewall+ #1 
[603360.337025]  ffff8801cd6ce000 ffff8801d7a06cf8 ffffffff9048b2f5 ffff8801d5e7e480
[603360.368282]  ffff8801d7a06d28 ffffffff90229b0e ffff8801d5e7e480 ffffea000735b380
[603360.399125]  ffff8801cd6ce000 ffff8801d5ff0fc0 ffff8801d7a06d50 ffffffff9022d3f6
[603360.429176] Call Trace:
[603360.458052]  <IRQ>  [<ffffffff9048b2f5>] dump_stack+0x4e/0x79
[603360.487675]  [<ffffffff90229b0e>] print_trailer+0xfe/0x160
[603360.517636]  [<ffffffff9022d3f6>] object_err+0x36/0x40
[603360.546088]  [<ffffffff90231300>] kasan_report_error+0x220/0x550
[603360.574215]  [<ffffffff900e7df6>] ? __lock_acquire+0x896/0x2640
[603360.601980]  [<ffffffff9023166b>] kasan_report+0x3b/0x40
[603360.629324]  [<ffffffff900e7500>] ? debug_show_all_locks+0x180/0x1e0
[603360.656451]  [<ffffffff90af9c10>] ? xfrm_lookup+0xf0/0x660
[603360.683140]  [<ffffffff90230b8f>] __asan_load8+0x5f/0x70
[603360.709419]  [<ffffffff90af9c10>] xfrm_lookup+0xf0/0x660
[603360.735602]  [<ffffffff90af9b20>] ? __xfrm_sk_clone_policy+0xc0/0xc0
[603360.761639]  [<ffffffff904bbc27>] ? debug_smp_processor_id+0x17/0x20
[603360.787360]  [<ffffffff900b628a>] ? preempt_count_sub+0x1a/0x130
[603360.812995]  [<ffffffff900e1dd6>] ? __lock_is_held+0x46/0xd0
[603360.838501]  [<ffffffff90231049>] ? memset+0x29/0x30
[603360.863983]  [<ffffffff909bf6a4>] nf_xfrm_me_harder+0x114/0x2d0
[603360.889656]  [<ffffffff909bf590>] ? __nf_nat_l4proto_find+0x80/0x80
[603360.915558]  [<ffffffff90ae40e0>] ? nf_nat_ipv4_fn+0x290/0x2e0
[603360.941462]  [<ffffffff90aea600>] ? iptable_nat_ipv4_fn+0x20/0x20
[603360.967401]  [<ffffffff90ae43c4>] nf_nat_ipv4_out+0x184/0x220
[603360.993433]  [<ffffffff90aea670>] ? iptable_nat_ipv4_local_fn+0x20/0x20
[603361.019595]  [<ffffffff90aea685>] iptable_nat_ipv4_out+0x15/0x20
[603361.045888]  [<ffffffff90992bb2>] nf_iterate+0xd2/0xf0
[603361.072191]  [<ffffffff90992d0a>] nf_hook_slow+0x13a/0x240
[603361.098581]  [<ffffffff90992bd5>] ? nf_hook_slow+0x5/0x240
[603361.124834]  [<ffffffff90992bd0>] ? nf_iterate+0xf0/0xf0
[603361.151104]  [<ffffffff90231049>] ? memset+0x29/0x30
[603361.177243]  [<ffffffff9091b442>] ? __alloc_skb+0x212/0x300
[603361.203134]  [<ffffffff90a55e4d>] ip_output+0x1ad/0x210
[603361.228679]  [<ffffffff90a55ca0>] ? ip_mc_output+0x460/0x460
[603361.254310]  [<ffffffff90a55370>] ? ip_fragment.constprop.55+0x100/0x100
[603361.280199]  [<ffffffff90a53713>] ip_local_out+0x63/0xb0
[603361.306122]  [<ffffffff90a539eb>] ip_build_and_send_pkt+0x28b/0x3a0
[603361.332270]  [<ffffffff90a8d9e2>] tcp_v4_send_synack+0x112/0x190
[603361.358528]  [<ffffffff90a8d8d0>] ? tcp_v4_send_check+0x50/0x50
[603361.384745]  [<ffffffff90a5d1ad>] ? inet_ehash_insert+0x1dd/0x280
[603361.410437]  [<ffffffff90a7ce6a>] tcp_conn_request+0x113a/0x12b0
[603361.435741]  [<ffffffff9098b7d0>] ? netlink_has_listeners+0x150/0x220
[603361.460943]  [<ffffffff9098b6b7>] ? netlink_has_listeners+0x37/0x220
[603361.485599]  [<ffffffff90a7bd30>] ? inet_reqsk_alloc+0x150/0x150
[603361.510179]  [<ffffffff900e4908>] ? mark_lock+0x78/0x8e0
[603361.534585]  [<ffffffff900e4908>] ? mark_lock+0x78/0x8e0
[603361.558608]  [<ffffffff900e0000>] ? percpu_down_read_trylock+0x60/0xb0
[603361.582983]  [<ffffffff900e7df6>] ? __lock_acquire+0x896/0x2640
[603361.607459]  [<ffffffff900e1dd6>] ? __lock_is_held+0x46/0xd0
[603361.631958]  [<ffffffff90a8b9b2>] tcp_v4_conn_request+0xa2/0x100
[603361.656480]  [<ffffffff90b63ea4>] tcp_v6_conn_request+0x114/0x120
[603361.680930]  [<ffffffff90a7a4f0>] tcp_rcv_state_process+0x390/0x1a80
[603361.705533]  [<ffffffff90a7a160>] ? tcp_finish_connect+0x200/0x200
[603361.730243]  [<ffffffff90964419>] ? sk_filter+0x189/0x370
[603361.754986]  [<ffffffff9096431d>] ? sk_filter+0x8d/0x370
[603361.779605]  [<ffffffff90964290>] ? bpf_skb_store_bytes+0x480/0x480
[603361.804405]  [<ffffffff90a5c7a5>] ? __inet_lookup_listener+0x5/0x420
[603361.829127]  [<ffffffff90a8cae2>] tcp_v4_do_rcv+0x162/0x3b0
[603361.853660]  [<ffffffff90a8f417>] tcp_v4_rcv+0x1117/0x1380
[603361.877999]  [<ffffffff90a4a387>] ip_local_deliver_finish+0x157/0x500
[603361.902445]  [<ffffffff90a4a2ad>] ? ip_local_deliver_finish+0x7d/0x500
[603361.926905]  [<ffffffff90a4b1c2>] ip_local_deliver+0xd2/0x170
[603361.951315]  [<ffffffff90a4b0f0>] ? ip_call_ra_chain+0x270/0x270
[603361.975613]  [<ffffffff90a4a230>] ? inet_del_offload+0x40/0x40
[603361.999726]  [<ffffffff90a4a859>] ip_rcv_finish+0x129/0x750
[603362.023793]  [<ffffffff90a4b746>] ip_rcv+0x4e6/0x720
[603362.047137]  [<ffffffff90a4b260>] ? ip_local_deliver+0x170/0x170
[603362.069940]  [<ffffffff90bb03bf>] ? packet_rcv_spkt+0x19f/0x1e0
[603362.092671]  [<ffffffff90a4a730>] ? ip_local_deliver_finish+0x500/0x500
[603362.115505]  [<ffffffff90bb03bf>] ? packet_rcv_spkt+0x19f/0x1e0
[603362.138080]  [<ffffffff90a4b260>] ? ip_local_deliver+0x170/0x170
[603362.160542]  [<ffffffff9093415f>] __netif_receive_skb_core+0x81f/0x1000
[603362.183021]  [<ffffffff90bb0220>] ? packet_setsockopt+0x1260/0x1260
[603362.205603]  [<ffffffff90933940>] ? __netdev_printk+0x2d0/0x2d0
[603362.228193]  [<ffffffff900e5194>] ? mark_held_locks+0x24/0xd0
[603362.250707]  [<ffffffff90124169>] ? ktime_get_with_offset+0x119/0x280
[603362.273297]  [<ffffffff90934967>] __netif_receive_skb+0x27/0xb0
[603362.295803]  [<ffffffff904bbc27>] ? debug_smp_processor_id+0x17/0x20
[603362.318343]  [<ffffffff90936051>] netif_receive_skb_internal+0xd1/0x2a0
[603362.341056]  [<ffffffff90936005>] ? netif_receive_skb_internal+0x85/0x2a0
[603362.363888]  [<ffffffff90935f80>] ? netif_rx_internal+0x3e0/0x3e0
[603362.386617]  [<ffffffff909364fb>] ? dev_gro_receive+0xbb/0x7f0
[603362.409379]  [<ffffffff909366f9>] ? dev_gro_receive+0x2b9/0x7f0
[603362.431953]  [<ffffffff9010620c>] ? rcu_read_lock_sched_held+0x8c/0xa0
[603362.454630]  [<ffffffff900e1db8>] ? __lock_is_held+0x28/0xd0
[603362.477325]  [<ffffffff9093e37c>] napi_gro_receive+0x15c/0x220
[603362.499994]  [<ffffffff908145ed>] rtl8169_poll+0x49d/0xb70
[603362.522636]  [<ffffffff900e7560>] ? debug_show_all_locks+0x1e0/0x1e0
[603362.545398]  [<ffffffff9093f09b>] net_rx_action+0x41b/0x6a0
[603362.568169]  [<ffffffff9093ec80>] ? napi_complete_done+0x100/0x100
[603362.591025]  [<ffffffff900e1db8>] ? __lock_is_held+0x28/0xd0
[603362.613788]  [<ffffffff90078082>] __do_softirq+0x1b2/0x5c0
[603362.636446]  [<ffffffff900786dc>] irq_exit+0xfc/0x110
[603362.658984]  [<ffffffff90c12b32>] do_IRQ+0x82/0x160
[603362.681520]  [<ffffffff90c11206>] common_interrupt+0x86/0x86
[603362.704211]  <EOI>  [<ffffffff908dfd97>] ? cpuidle_enter_state+0x1c7/0x460
[603362.727392]  [<ffffffff908dfd92>] ? cpuidle_enter_state+0x1c2/0x460
[603362.750765]  [<ffffffff90108199>] ? rcu_eqs_enter_common+0x139/0x280
[603362.774174]  [<ffffffff908e0097>] cpuidle_enter+0x17/0x20
[603362.797572]  [<ffffffff900dcc92>] cpu_startup_entry+0x4d2/0x5b0
[603362.821031]  [<ffffffff900dc7c0>] ? default_idle_call+0x60/0x60
[603362.844456]  [<ffffffff9012e624>] ? clockevents_config_and_register+0x64/0x70
[603362.868046]  [<ffffffff9004d635>] ? setup_APIC_timer+0x115/0x120
[603362.891633]  [<ffffffff9004bcca>] start_secondary+0x23a/0x2a0
[603362.915171]  [<ffffffff9004ba90>] ? set_cpu_sibling_map+0x9c0/0x9c0
[603364.686891] CPU: 1 PID: 0 Comm: swapper/1 Tainted: G    B           4.4.0-rc2-firewall+ #1 
[603364.714736]  0000000000000002 ffff8801d7a06cd0 ffffffff9048b2f5 ffff8801d5e7e480
[603364.742659]  ffff8801d7a06d00 ffffffff90229b0e ffff8801d5e7e480 ffffea000735b380
[603364.770822]  ffff8801cd6ce000 ffff8801d5ff0fc0 ffff8801d7a06d28 ffffffff9022d3f6
[603364.799253] Call Trace:
[603364.827237]  <IRQ>  [<ffffffff9048b2f5>] dump_stack+0x4e/0x79
[603364.855564]  [<ffffffff90229b0e>] print_trailer+0xfe/0x160
[603364.884217]  [<ffffffff9022d3f6>] object_err+0x36/0x40
[603364.912493]  [<ffffffff90231300>] kasan_report_error+0x220/0x550
[603364.941148]  [<ffffffff9023166b>] kasan_report+0x3b/0x40
[603364.969161]  [<ffffffff90c0fe00>] ? _raw_write_lock+0x70/0x80
[603364.996735]  [<ffffffff90af64e1>] ? xfrm_sk_policy_lookup+0x31/0xc0
[603365.024007]  [<ffffffff90230b8f>] __asan_load8+0x5f/0x70
[603365.050867]  [<ffffffff90af64e1>] xfrm_sk_policy_lookup+0x31/0xc0
[603365.077453]  [<ffffffff90af9c3c>] xfrm_lookup+0x11c/0x660
[603365.103600]  [<ffffffff90af9b20>] ? __xfrm_sk_clone_policy+0xc0/0xc0
[603365.129627]  [<ffffffff904bbc27>] ? debug_smp_processor_id+0x17/0x20
[603365.155339]  [<ffffffff900b628a>] ? preempt_count_sub+0x1a/0x130
[603365.180964]  [<ffffffff900e1dd6>] ? __lock_is_held+0x46/0xd0
[603365.206460]  [<ffffffff90231049>] ? memset+0x29/0x30
[603365.231921]  [<ffffffff909bf6a4>] nf_xfrm_me_harder+0x114/0x2d0
[603365.257572]  [<ffffffff909bf590>] ? __nf_nat_l4proto_find+0x80/0x80
[603365.283448]  [<ffffffff90ae40e0>] ? nf_nat_ipv4_fn+0x290/0x2e0
[603365.309325]  [<ffffffff90aea600>] ? iptable_nat_ipv4_fn+0x20/0x20
[603365.335229]  [<ffffffff90ae43c4>] nf_nat_ipv4_out+0x184/0x220
[603365.361221]  [<ffffffff90aea670>] ? iptable_nat_ipv4_local_fn+0x20/0x20
[603365.387332]  [<ffffffff90aea685>] iptable_nat_ipv4_out+0x15/0x20
[603365.413557]  [<ffffffff90992bb2>] nf_iterate+0xd2/0xf0
[603365.439814]  [<ffffffff90992d0a>] nf_hook_slow+0x13a/0x240
[603365.466143]  [<ffffffff90992bd5>] ? nf_hook_slow+0x5/0x240
[603365.492333]  [<ffffffff90992bd0>] ? nf_iterate+0xf0/0xf0
[603365.518524]  [<ffffffff90231049>] ? memset+0x29/0x30
[603365.544605]  [<ffffffff9091b442>] ? __alloc_skb+0x212/0x300
[603365.570444]  [<ffffffff90a55e4d>] ip_output+0x1ad/0x210
[603365.595938]  [<ffffffff90a55ca0>] ? ip_mc_output+0x460/0x460
[603365.621511]  [<ffffffff90a55370>] ? ip_fragment.constprop.55+0x100/0x100
[603365.647367]  [<ffffffff90a53713>] ip_local_out+0x63/0xb0
[603365.673256]  [<ffffffff90a539eb>] ip_build_and_send_pkt+0x28b/0x3a0
[603365.699370]  [<ffffffff90a8d9e2>] tcp_v4_send_synack+0x112/0x190
[603365.725584]  [<ffffffff90a8d8d0>] ? tcp_v4_send_check+0x50/0x50
[603365.751758]  [<ffffffff90a5d1ad>] ? inet_ehash_insert+0x1dd/0x280
[603365.777424]  [<ffffffff90a7ce6a>] tcp_conn_request+0x113a/0x12b0
[603365.802676]  [<ffffffff9098b7d0>] ? netlink_has_listeners+0x150/0x220
[603365.827835]  [<ffffffff9098b6b7>] ? netlink_has_listeners+0x37/0x220
[603365.852473]  [<ffffffff90a7bd30>] ? inet_reqsk_alloc+0x150/0x150
[603365.877037]  [<ffffffff900e4908>] ? mark_lock+0x78/0x8e0
[603365.901425]  [<ffffffff900e4908>] ? mark_lock+0x78/0x8e0
[603365.925447]  [<ffffffff900e0000>] ? percpu_down_read_trylock+0x60/0xb0
[603365.949812]  [<ffffffff900e7df6>] ? __lock_acquire+0x896/0x2640
[603365.974286]  [<ffffffff900e1dd6>] ? __lock_is_held+0x46/0xd0
[603365.998760]  [<ffffffff90a8b9b2>] tcp_v4_conn_request+0xa2/0x100
[603366.023272]  [<ffffffff90b63ea4>] tcp_v6_conn_request+0x114/0x120
[603366.047750]  [<ffffffff90a7a4f0>] tcp_rcv_state_process+0x390/0x1a80
[603366.072377]  [<ffffffff90a7a160>] ? tcp_finish_connect+0x200/0x200
[603366.097116]  [<ffffffff90964419>] ? sk_filter+0x189/0x370
[603366.121893]  [<ffffffff9096431d>] ? sk_filter+0x8d/0x370
[603366.146556]  [<ffffffff90964290>] ? bpf_skb_store_bytes+0x480/0x480
[603366.171323]  [<ffffffff90a5c7a5>] ? __inet_lookup_listener+0x5/0x420
[603366.196090]  [<ffffffff90a8cae2>] tcp_v4_do_rcv+0x162/0x3b0
[603366.220689]  [<ffffffff90a8f417>] tcp_v4_rcv+0x1117/0x1380
[603366.245112]  [<ffffffff90a4a387>] ip_local_deliver_finish+0x157/0x500
[603366.269633]  [<ffffffff90a4a2ad>] ? ip_local_deliver_finish+0x7d/0x500
[603366.294162]  [<ffffffff90a4b1c2>] ip_local_deliver+0xd2/0x170
[603366.318641]  [<ffffffff90a4b0f0>] ? ip_call_ra_chain+0x270/0x270
[603366.343022]  [<ffffffff90a4a230>] ? inet_del_offload+0x40/0x40
[603366.367222]  [<ffffffff90a4a859>] ip_rcv_finish+0x129/0x750
[603366.391359]  [<ffffffff90a4b746>] ip_rcv+0x4e6/0x720
[603366.414770]  [<ffffffff90a4b260>] ? ip_local_deliver+0x170/0x170
[603366.437649]  [<ffffffff90bb03bf>] ? packet_rcv_spkt+0x19f/0x1e0
[603366.460413]  [<ffffffff90a4a730>] ? ip_local_deliver_finish+0x500/0x500
[603366.483289]  [<ffffffff90bb03bf>] ? packet_rcv_spkt+0x19f/0x1e0
[603366.505886]  [<ffffffff90a4b260>] ? ip_local_deliver+0x170/0x170
[603366.528372]  [<ffffffff9093415f>] __netif_receive_skb_core+0x81f/0x1000
[603366.550876]  [<ffffffff90bb0220>] ? packet_setsockopt+0x1260/0x1260
[603366.573465]  [<ffffffff90933940>] ? __netdev_printk+0x2d0/0x2d0
[603366.596044]  [<ffffffff900e5194>] ? mark_held_locks+0x24/0xd0
[603366.618668]  [<ffffffff90124169>] ? ktime_get_with_offset+0x119/0x280
[603366.641439]  [<ffffffff90934967>] __netif_receive_skb+0x27/0xb0
[603366.664166]  [<ffffffff904bbc27>] ? debug_smp_processor_id+0x17/0x20
[603366.686892]  [<ffffffff90936051>] netif_receive_skb_internal+0xd1/0x2a0
[603366.709706]  [<ffffffff90936005>] ? netif_receive_skb_internal+0x85/0x2a0
[603366.732640]  [<ffffffff90935f80>] ? netif_rx_internal+0x3e0/0x3e0
[603366.755454]  [<ffffffff909364fb>] ? dev_gro_receive+0xbb/0x7f0
[603366.778300]  [<ffffffff909366f9>] ? dev_gro_receive+0x2b9/0x7f0
[603366.800949]  [<ffffffff9010620c>] ? rcu_read_lock_sched_held+0x8c/0xa0
[603366.823719]  [<ffffffff900e1db8>] ? __lock_is_held+0x28/0xd0
[603366.846497]  [<ffffffff9093e37c>] napi_gro_receive+0x15c/0x220
[603366.869250]  [<ffffffff908145ed>] rtl8169_poll+0x49d/0xb70
[603366.891974]  [<ffffffff900e7560>] ? debug_show_all_locks+0x1e0/0x1e0
[603366.914812]  [<ffffffff9093f09b>] net_rx_action+0x41b/0x6a0
[603366.937659]  [<ffffffff9093ec80>] ? napi_complete_done+0x100/0x100
[603366.960591]  [<ffffffff900e1db8>] ? __lock_is_held+0x28/0xd0
[603366.983438]  [<ffffffff90078082>] __do_softirq+0x1b2/0x5c0
[603367.006200]  [<ffffffff900786dc>] irq_exit+0xfc/0x110
[603367.028844]  [<ffffffff90c12b32>] do_IRQ+0x82/0x160
[603367.051483]  [<ffffffff90c11206>] common_interrupt+0x86/0x86
[603367.074267]  <EOI>  [<ffffffff908dfd97>] ? cpuidle_enter_state+0x1c7/0x460
[603367.097551]  [<ffffffff908dfd92>] ? cpuidle_enter_state+0x1c2/0x460
[603367.121008]  [<ffffffff90108199>] ? rcu_eqs_enter_common+0x139/0x280
[603367.144510]  [<ffffffff908e0097>] cpuidle_enter+0x17/0x20
[603367.168010]  [<ffffffff900dcc92>] cpu_startup_entry+0x4d2/0x5b0
[603367.191562]  [<ffffffff900dc7c0>] ? default_idle_call+0x60/0x60
[603367.215063]  [<ffffffff9012e624>] ? clockevents_config_and_register+0x64/0x70
[603367.238730]  [<ffffffff9004d635>] ? setup_APIC_timer+0x115/0x120
[603367.262403]  [<ffffffff9004bcca>] start_secondary+0x23a/0x2a0
[603367.286025]  [<ffffffff9004ba90>] ? set_cpu_sibling_map+0x9c0/0x9c0
[603368.887100] CPU: 1 PID: 0 Comm: swapper/1 Tainted: G    B           4.4.0-rc2-firewall+ #1 
[603368.916052]  ffff8801cd6cfc30 ffff8801d7a06cf8 ffffffff9048b2f5 ffff8801d5e7e480
[603368.945336]  ffff8801d7a06d28 ffffffff90229b0e ffff8801d5e7e480 ffffea000735b380
[603368.974712]  ffff8801cd6cfc30 ffff8801d5ff0fc0 ffff8801d7a06d50 ffffffff9022d3f6
[603369.004002] Call Trace:
[603369.032886]  <IRQ>  [<ffffffff9048b2f5>] dump_stack+0x4e/0x79
[603369.062251]  [<ffffffff90229b0e>] print_trailer+0xfe/0x160
[603369.091684]  [<ffffffff9022d3f6>] object_err+0x36/0x40
[603369.120844]  [<ffffffff90231300>] kasan_report_error+0x220/0x550
[603369.149884]  [<ffffffff900e7605>] ? __lock_acquire+0xa5/0x2640
[603369.179017]  [<ffffffff9023166b>] kasan_report+0x3b/0x40
[603369.208365]  [<ffffffff900e7500>] ? debug_show_all_locks+0x180/0x1e0
[603369.237725]  [<ffffffff90af9c10>] ? xfrm_lookup+0xf0/0x660
[603369.266874]  [<ffffffff90230b8f>] __asan_load8+0x5f/0x70
[603369.296221]  [<ffffffff90af9c10>] xfrm_lookup+0xf0/0x660
[603369.325235]  [<ffffffff90af9b20>] ? __xfrm_sk_clone_policy+0xc0/0xc0
[603369.354664]  [<ffffffff90960fa0>] ? inet_proto_csum_replace4+0x30/0x100
[603369.383749]  [<ffffffff901063d6>] ? debug_lockdep_rcu_enabled+0x26/0x40
[603369.412507]  [<ffffffff90231049>] ? memset+0x29/0x30
[603369.440792]  [<ffffffff90aefc13>] ? _decode_session4+0x2e3/0x920
[603369.468801]  [<ffffffff90afa2c2>] ? __xfrm_decode_session+0x52/0xb0
[603369.496479]  [<ffffffff909bf6a4>] nf_xfrm_me_harder+0x114/0x2d0
[603369.523813]  [<ffffffff909bf590>] ? __nf_nat_l4proto_find+0x80/0x80
[603369.550941]  [<ffffffff90ae40e0>] ? nf_nat_ipv4_fn+0x290/0x2e0
[603369.577783]  [<ffffffff90aea600>] ? iptable_nat_ipv4_fn+0x20/0x20
[603369.604565]  [<ffffffff90ae43c4>] nf_nat_ipv4_out+0x184/0x220
[603369.631236]  [<ffffffff90aea670>] ? iptable_nat_ipv4_local_fn+0x20/0x20
[603369.658166]  [<ffffffff90aea685>] iptable_nat_ipv4_out+0x15/0x20
[603369.685148]  [<ffffffff90992bb2>] nf_iterate+0xd2/0xf0
[603369.712260]  [<ffffffff90992d0a>] nf_hook_slow+0x13a/0x240
[603369.739371]  [<ffffffff90992bd5>] ? nf_hook_slow+0x5/0x240
[603369.766415]  [<ffffffff90992bd0>] ? nf_iterate+0xf0/0xf0
[603369.793467]  [<ffffffff90231049>] ? memset+0x29/0x30
[603369.820397]  [<ffffffff9091b442>] ? __alloc_skb+0x212/0x300
[603369.847460]  [<ffffffff90a55e4d>] ip_output+0x1ad/0x210
[603369.874496]  [<ffffffff90a55ca0>] ? ip_mc_output+0x460/0x460
[603369.901655]  [<ffffffff90a55370>] ? ip_fragment.constprop.55+0x100/0x100
[603369.928908]  [<ffffffff90a53713>] ip_local_out+0x63/0xb0
[603369.956246]  [<ffffffff90a539eb>] ip_build_and_send_pkt+0x28b/0x3a0
[603369.983645]  [<ffffffff90a8d9e2>] tcp_v4_send_synack+0x112/0x190
[603370.010548]  [<ffffffff90a8d8d0>] ? tcp_v4_send_check+0x50/0x50
[603370.037003]  [<ffffffff90a5d1ad>] ? inet_ehash_insert+0x1dd/0x280
[603370.063232]  [<ffffffff90a7ce6a>] tcp_conn_request+0x113a/0x12b0
[603370.089130]  [<ffffffff9098b7d0>] ? netlink_has_listeners+0x150/0x220
[603370.114673]  [<ffffffff9098b6b7>] ? netlink_has_listeners+0x37/0x220
[603370.139962]  [<ffffffff90a7bd30>] ? inet_reqsk_alloc+0x150/0x150
[603370.165127]  [<ffffffff900e7605>] ? __lock_acquire+0xa5/0x2640
[603370.190192]  [<ffffffff900e7605>] ? __lock_acquire+0xa5/0x2640
[603370.215160]  [<ffffffff900e7605>] ? __lock_acquire+0xa5/0x2640
[603370.239992]  [<ffffffff900e0000>] ? percpu_down_read_trylock+0x60/0xb0
[603370.265067]  [<ffffffff900e7605>] ? __lock_acquire+0xa5/0x2640
[603370.290098]  [<ffffffff900e7560>] ? debug_show_all_locks+0x1e0/0x1e0
[603370.315159]  [<ffffffff90a8b9b2>] tcp_v4_conn_request+0xa2/0x100
[603370.340156]  [<ffffffff90b63ea4>] tcp_v6_conn_request+0x114/0x120
[603370.365010]  [<ffffffff90a7a4f0>] tcp_rcv_state_process+0x390/0x1a80
[603370.389992]  [<ffffffff90a7a160>] ? tcp_finish_connect+0x200/0x200
[603370.415057]  [<ffffffff909643fc>] ? sk_filter+0x16c/0x370
[603370.440074]  [<ffffffff90964419>] ? sk_filter+0x189/0x370
[603370.464795]  [<ffffffff9096431d>] ? sk_filter+0x8d/0x370
[603370.489193]  [<ffffffff90964290>] ? bpf_skb_store_bytes+0x480/0x480
[603370.513606]  [<ffffffff90a5c7a5>] ? __inet_lookup_listener+0x5/0x420
[603370.538024]  [<ffffffff90a8cae2>] tcp_v4_do_rcv+0x162/0x3b0
[603370.562343]  [<ffffffff90a8f417>] tcp_v4_rcv+0x1117/0x1380
[603370.586494]  [<ffffffff90992b56>] ? nf_iterate+0x76/0xf0
[603370.610469]  [<ffffffff90a4a387>] ip_local_deliver_finish+0x157/0x500
[603370.634486]  [<ffffffff90a4a2ad>] ? ip_local_deliver_finish+0x7d/0x500
[603370.658552]  [<ffffffff90a4b1c2>] ip_local_deliver+0xd2/0x170
[603370.682006]  [<ffffffff90a4b0f0>] ? ip_call_ra_chain+0x270/0x270
[603370.704803]  [<ffffffff90a4a230>] ? inet_del_offload+0x40/0x40
[603370.727465]  [<ffffffff90a4a859>] ip_rcv_finish+0x129/0x750
[603370.750031]  [<ffffffff90a4b746>] ip_rcv+0x4e6/0x720
[603370.772174]  [<ffffffff90a4b260>] ? ip_local_deliver+0x170/0x170
[603370.794292]  [<ffffffff90bb03bf>] ? packet_rcv_spkt+0x19f/0x1e0
[603370.816308]  [<ffffffff90a4a730>] ? ip_local_deliver_finish+0x500/0x500
[603370.838520]  [<ffffffff90bb03bf>] ? packet_rcv_spkt+0x19f/0x1e0
[603370.860741]  [<ffffffff90a4b260>] ? ip_local_deliver+0x170/0x170
[603370.882985]  [<ffffffff9093415f>] __netif_receive_skb_core+0x81f/0x1000
[603370.905366]  [<ffffffff90bb0220>] ? packet_setsockopt+0x1260/0x1260
[603370.927731]  [<ffffffff90933940>] ? __netdev_printk+0x2d0/0x2d0
[603370.950068]  [<ffffffff90936165>] ? netif_receive_skb_internal+0x1e5/0x2a0
[603370.972640]  [<ffffffff90934967>] __netif_receive_skb+0x27/0xb0
[603370.995116]  [<ffffffff90936051>] netif_receive_skb_internal+0xd1/0x2a0
[603371.017696]  [<ffffffff90936005>] ? netif_receive_skb_internal+0x85/0x2a0
[603371.040319]  [<ffffffff90935f80>] ? netif_rx_internal+0x3e0/0x3e0
[603371.062820]  [<ffffffff909364fb>] ? dev_gro_receive+0xbb/0x7f0
[603371.085219]  [<ffffffff909366f9>] ? dev_gro_receive+0x2b9/0x7f0
[603371.107422]  [<ffffffff901063d6>] ? debug_lockdep_rcu_enabled+0x26/0x40
[603371.129712]  [<ffffffff9093e37c>] napi_gro_receive+0x15c/0x220
[603371.151966]  [<ffffffff908145ed>] rtl8169_poll+0x49d/0xb70
[603371.174184]  [<ffffffff900e7560>] ? debug_show_all_locks+0x1e0/0x1e0
[603371.196516]  [<ffffffff9093f09b>] net_rx_action+0x41b/0x6a0
[603371.218854]  [<ffffffff9093ec80>] ? napi_complete_done+0x100/0x100
[603371.241270]  [<ffffffff900e1db8>] ? __lock_is_held+0x28/0xd0
[603371.263585]  [<ffffffff90078082>] __do_softirq+0x1b2/0x5c0
[603371.285813]  [<ffffffff900786dc>] irq_exit+0xfc/0x110
[603371.307928]  [<ffffffff90c12b32>] do_IRQ+0x82/0x160
[603371.330042]  [<ffffffff90c11206>] common_interrupt+0x86/0x86
[603371.352301]  <EOI>  [<ffffffff908dfd97>] ? cpuidle_enter_state+0x1c7/0x460
[603371.375050]  [<ffffffff908dfd92>] ? cpuidle_enter_state+0x1c2/0x460
[603371.397991]  [<ffffffff90108199>] ? rcu_eqs_enter_common+0x139/0x280
[603371.420965]  [<ffffffff908e0097>] cpuidle_enter+0x17/0x20
[603371.443940]  [<ffffffff900dcc92>] cpu_startup_entry+0x4d2/0x5b0
[603371.466983]  [<ffffffff900dc7c0>] ? default_idle_call+0x60/0x60
[603371.489969]  [<ffffffff9012e624>] ? clockevents_config_and_register+0x64/0x70
[603371.513111]  [<ffffffff9004d635>] ? setup_APIC_timer+0x115/0x120
[603371.536268]  [<ffffffff9004bcca>] start_secondary+0x23a/0x2a0
[603371.559382]  [<ffffffff9004ba90>] ? set_cpu_sibling_map+0x9c0/0x9c0
[603373.326310] CPU: 1 PID: 0 Comm: swapper/1 Tainted: G    B           4.4.0-rc2-firewall+ #1 
[603373.354180]  ffff8801cd6ce000 ffff8801d7a06eb0 ffffffff9048b2f5 ffff8801d5e7e480
[603373.382110]  ffff8801d7a06ee0 ffffffff90229b0e ffff8801d5e7e480 ffffea000735b380
[603373.410099]  ffff8801cd6ce000 ffff8801d5ff0fc0 ffff8801d7a06f08 ffffffff9022d3f6
[603373.438390] Call Trace:
[603373.466226]  <IRQ>  [<ffffffff9048b2f5>] dump_stack+0x4e/0x79
[603373.494393]  [<ffffffff90229b0e>] print_trailer+0xfe/0x160
[603373.522898]  [<ffffffff9022d3f6>] object_err+0x36/0x40
[603373.551035]  [<ffffffff90231300>] kasan_report_error+0x220/0x550
[603373.579535]  [<ffffffff900e7605>] ? __lock_acquire+0xa5/0x2640
[603373.607597]  [<ffffffff9023166b>] kasan_report+0x3b/0x40
[603373.635229]  [<ffffffff90af9c10>] ? xfrm_lookup+0xf0/0x660
[603373.662465]  [<ffffffff90230b8f>] __asan_load8+0x5f/0x70
[603373.689244]  [<ffffffff90af9c10>] xfrm_lookup+0xf0/0x660
[603373.715595]  [<ffffffff90af9b20>] ? __xfrm_sk_clone_policy+0xc0/0xc0
[603373.741749]  [<ffffffff90960fa0>] ? inet_proto_csum_replace4+0x30/0x100
[603373.767715]  [<ffffffff901063d6>] ? debug_lockdep_rcu_enabled+0x26/0x40
[603373.793448]  [<ffffffff90231049>] ? memset+0x29/0x30
[603373.819008]  [<ffffffff90aefc13>] ? _decode_session4+0x2e3/0x920
[603373.844595]  [<ffffffff90afa2c2>] ? __xfrm_decode_session+0x52/0xb0
[603373.870302]  [<ffffffff909bf6a4>] nf_xfrm_me_harder+0x114/0x2d0
[603373.896079]  [<ffffffff909bf590>] ? __nf_nat_l4proto_find+0x80/0x80
[603373.922081]  [<ffffffff90ae40e0>] ? nf_nat_ipv4_fn+0x290/0x2e0
[603373.948084]  [<ffffffff90aea600>] ? iptable_nat_ipv4_fn+0x20/0x20
[603373.974097]  [<ffffffff90ae43c4>] nf_nat_ipv4_out+0x184/0x220
[603374.000188]  [<ffffffff90aea670>] ? iptable_nat_ipv4_local_fn+0x20/0x20
[603374.026425]  [<ffffffff90aea685>] iptable_nat_ipv4_out+0x15/0x20
[603374.052773]  [<ffffffff90992bb2>] nf_iterate+0xd2/0xf0
[603374.079138]  [<ffffffff90992d0a>] nf_hook_slow+0x13a/0x240
[603374.105575]  [<ffffffff90992bd5>] ? nf_hook_slow+0x5/0x240
[603374.131892]  [<ffffffff90992bd0>] ? nf_iterate+0xf0/0xf0
[603374.158226]  [<ffffffff90231049>] ? memset+0x29/0x30
[603374.184440]  [<ffffffff9091b442>] ? __alloc_skb+0x212/0x300
[603374.210405]  [<ffffffff90a55e4d>] ip_output+0x1ad/0x210
[603374.236016]  [<ffffffff90a55ca0>] ? ip_mc_output+0x460/0x460
[603374.261722]  [<ffffffff90a55370>] ? ip_fragment.constprop.55+0x100/0x100
[603374.287693]  [<ffffffff90a53713>] ip_local_out+0x63/0xb0
[603374.313691]  [<ffffffff90a539eb>] ip_build_and_send_pkt+0x28b/0x3a0
[603374.339914]  [<ffffffff90a8d9e2>] tcp_v4_send_synack+0x112/0x190
[603374.366257]  [<ffffffff90a8d8d0>] ? tcp_v4_send_check+0x50/0x50
[603374.392549]  [<ffffffff904a46aa>] ? prandom_u32_state+0x8a/0xc0
[603374.418263]  [<ffffffff900b628a>] ? preempt_count_sub+0x1a/0x130
[603374.443495]  [<ffffffff90a873fd>] tcp_rtx_synack+0xdd/0x180
[603374.468495]  [<ffffffff90a87320>] ? tcp_send_probe0+0x1a0/0x1a0
[603374.493148]  [<ffffffff90ac0967>] ? fib_validate_source+0x317/0x8e0
[603374.517762]  [<ffffffff90a7882d>] ? tcp_parse_options+0x50d/0x660
[603374.542261]  [<ffffffff90a60bc7>] inet_rtx_syn_ack+0x47/0x70
[603374.566635]  [<ffffffff90a9146d>] tcp_check_req+0x3ad/0x7d0
[603374.591171]  [<ffffffff90a910c0>] ? tcp_create_openreq_child+0x920/0x920
[603374.616049]  [<ffffffff900e7560>] ? debug_show_all_locks+0x1e0/0x1e0
[603374.641108]  [<ffffffff901063d6>] ? debug_lockdep_rcu_enabled+0x26/0x40
[603374.666204]  [<ffffffff90a8f093>] tcp_v4_rcv+0xd93/0x1380
[603374.691320]  [<ffffffff90ae1e80>] ? ipv4_net_init+0xe0/0xe0
[603374.716521]  [<ffffffff90992b56>] ? nf_iterate+0x76/0xf0
[603374.741755]  [<ffffffff90a9d060>] ? raw_rcv+0x1a0/0x1a0
[603374.766985]  [<ffffffff90a4a387>] ip_local_deliver_finish+0x157/0x500
[603374.792471]  [<ffffffff90a4a2ad>] ? ip_local_deliver_finish+0x7d/0x500
[603374.817997]  [<ffffffff90a4b1c2>] ip_local_deliver+0xd2/0x170
[603374.843477]  [<ffffffff90a4b0f0>] ? ip_call_ra_chain+0x270/0x270
[603374.868817]  [<ffffffff90a4a230>] ? inet_del_offload+0x40/0x40
[603374.893994]  [<ffffffff90a4a859>] ip_rcv_finish+0x129/0x750
[603374.919075]  [<ffffffff90a4b746>] ip_rcv+0x4e6/0x720
[603374.943995]  [<ffffffff90a4b260>] ? ip_local_deliver+0x170/0x170
[603374.968973]  [<ffffffff90bb03bf>] ? packet_rcv_spkt+0x19f/0x1e0
[603374.993843]  [<ffffffff90a4a730>] ? ip_local_deliver_finish+0x500/0x500
[603375.018720]  [<ffffffff90bb03bf>] ? packet_rcv_spkt+0x19f/0x1e0
[603375.043631]  [<ffffffff90a4b260>] ? ip_local_deliver+0x170/0x170
[603375.067962]  [<ffffffff9093415f>] __netif_receive_skb_core+0x81f/0x1000
[603375.091784]  [<ffffffff90bb0220>] ? packet_setsockopt+0x1260/0x1260
[603375.115605]  [<ffffffff90933940>] ? __netdev_printk+0x2d0/0x2d0
[603375.139383]  [<ffffffff90936165>] ? netif_receive_skb_internal+0x1e5/0x2a0
[603375.163065]  [<ffffffff90934967>] __netif_receive_skb+0x27/0xb0
[603375.186463]  [<ffffffff90936051>] netif_receive_skb_internal+0xd1/0x2a0
[603375.209870]  [<ffffffff90936005>] ? netif_receive_skb_internal+0x85/0x2a0
[603375.233416]  [<ffffffff90935f80>] ? netif_rx_internal+0x3e0/0x3e0
[603375.256890]  [<ffffffff909364fb>] ? dev_gro_receive+0xbb/0x7f0
[603375.280337]  [<ffffffff909366f9>] ? dev_gro_receive+0x2b9/0x7f0
[603375.303597]  [<ffffffff901063d6>] ? debug_lockdep_rcu_enabled+0x26/0x40
[603375.326979]  [<ffffffff9093e37c>] napi_gro_receive+0x15c/0x220
[603375.350421]  [<ffffffff908145ed>] rtl8169_poll+0x49d/0xb70
[603375.373879]  [<ffffffff900e7560>] ? debug_show_all_locks+0x1e0/0x1e0
[603375.397424]  [<ffffffff9093f09b>] net_rx_action+0x41b/0x6a0
[603375.420908]  [<ffffffff9093ec80>] ? napi_complete_done+0x100/0x100
[603375.444436]  [<ffffffff900e1db8>] ? __lock_is_held+0x28/0xd0
[603375.467869]  [<ffffffff90078082>] __do_softirq+0x1b2/0x5c0
[603375.491249]  [<ffffffff900786dc>] irq_exit+0xfc/0x110
[603375.514517]  [<ffffffff90c12b32>] do_IRQ+0x82/0x160
[603375.537682]  [<ffffffff90c11206>] common_interrupt+0x86/0x86
[603375.560896]  <EOI>  [<ffffffff908dfd97>] ? cpuidle_enter_state+0x1c7/0x460
[603375.584479]  [<ffffffff908dfd92>] ? cpuidle_enter_state+0x1c2/0x460
[603375.608227]  [<ffffffff90108199>] ? rcu_eqs_enter_common+0x139/0x280
[603375.631975]  [<ffffffff908e0097>] cpuidle_enter+0x17/0x20
[603375.655585]  [<ffffffff900dcc92>] cpu_startup_entry+0x4d2/0x5b0
[603375.679170]  [<ffffffff900dc7c0>] ? default_idle_call+0x60/0x60
[603375.702707]  [<ffffffff9012e624>] ? clockevents_config_and_register+0x64/0x70
[603375.726576]  [<ffffffff9004d635>] ? setup_APIC_timer+0x115/0x120
[603375.750541]  [<ffffffff9004bcca>] start_secondary+0x23a/0x2a0
[603375.774583]  [<ffffffff9004ba90>] ? set_cpu_sibling_map+0x9c0/0x9c0
