From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 000002c0
  / IP: [<c04c70f2>] in6_dev_finish_destroy+0x35/0x8c
Date: Fri, 15 Apr 2011 17:28:42 +0100
Message-ID: <4DA8723A.8090606@simon.arlott.org.uk>
References: <4DA77AE5.9060501@simon.arlott.org.uk>	 <0b5f315dd0f6e8eefabbd8b38b1d43e181fdd728@8b5064a13e22126c1b9329f0dc35b8915774b7c3.invalid>	 <1302872983.3613.10.camel@edumazet-laptop> <1302873876.3613.11.camel@edumazet-laptop> <4DA86FE5.8080507@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([81.2.80.65]:33046 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753636Ab1DOQxY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Apr 2011 12:53:24 -0400
In-Reply-To: <4DA86FE5.8080507@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

and again with the patch reverted...

[  470.965098] BUG: unable to handle kernel paging request at a1fd3e8b
[  470.966008] IP: [<c04d89a7>] icmpv6_send+0x5c3/0x6e2
[  470.966008] *pdpt = 00000000318f2001 *pde = 0000000000000000 
[  470.966008] Oops: 0002 [#1] PREEMPT SMP 
[  470.966008] last sysfs file: /sys/devices/platform/it87.552/cpu0_vid
[  470.966008] Modules linked in: nf_conntrack_ipv6 xt_tcpmss xt_length xt_TCPMSS ppp_synctty sch_sfq xt_u32 xt_CLASSIFY sch_htb ppp_async rfcomm bnep l2cap crc16 nfsd lockd sunrpc exportfs xt_state ip6t_LOG ip]
[  470.966008] 
[  470.966008] Pid: 3, comm: ksoftirqd/0 Not tainted 2.6.35.4-git+ #git+ GA-MA69VM-S2/GA-MA69VM-S2
[  470.966008] EIP: 0060:[<c04d89a7>] EFLAGS: 00010286 CPU: 0
[  470.966008] EIP is at icmpv6_send+0x5c3/0x6e2
[  470.966008] EAX: 00000000 EBX: a1fd3daf ECX: 00000000 EDX: 00000001
[  470.966008] ESI: f6f1adb4 EDI: 00000000 EBP: f7483c4c ESP: f7483b48
[  470.966008]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[  470.966008] Process ksoftirqd/0 (pid: 3, ti=f7482000 task=f74800a0 task.ti=f7482000)
[  470.966008] Stack:
[  470.966008]  f493fec0 f7483b5c c0513fe0 00033acf 00033ab5 f7483b7c c022e74d 00000046
[  470.966008] <0> fffffd8a 00033acf 00000001 0101001a f1a2984c 00000500 f6f1aac0 f6f1adb4
[  470.966008] <0> f1a2985c 00000000 00000040 f6f1aaf0 00000000 00000000 00000000 b0060120
[  470.966008] Call Trace:
[  470.966008]  [<c0513fe0>] ? _raw_spin_unlock_irqrestore+0x42/0x58
[  470.966008]  [<c022e74d>] ? release_console_sem+0x197/0x1c4
[  470.966008]  [<fa73c0b5>] ? reject_tg6+0x70/0x43f [ip6t_REJECT]
[  470.966008]  [<fa7619b1>] ? ip6t_log_packet+0x15d/0x167 [ip6t_LOG]
[  470.966008]  [<c024e201>] ? trace_hardirqs_on+0xb/0xd
[  470.966008]  [<c0232a72>] ? local_bh_enable_ip+0x97/0xad
[  470.966008]  [<c0513f59>] ? _raw_spin_unlock_bh+0x2f/0x32
[  470.966008]  [<fa7619b1>] ? ip6t_log_packet+0x15d/0x167 [ip6t_LOG]
[  470.966008]  [<fa6290f0>] ? ipv6_find_hdr+0x48/0x164 [ip6_tables]
[  470.966008]  [<fa6297c1>] ? ip6t_do_table+0x4c8/0x53e [ip6_tables]
[  470.966008]  [<fa6cf0f0>] ? ip6table_mangle_hook+0xf0/0x100 [ip6table_mangle]
[  470.966008]  [<fa634018>] ? ip6table_filter_hook+0x18/0x20 [ip6table_filter]
[  470.966008]  [<c046ee87>] ? nf_iterate+0x2f/0x62
[  470.966008]  [<c04c40c8>] ? ip6_input_finish+0x0/0x3db
[  470.966008]  [<c046f088>] ? nf_hook_slow+0x63/0xeb
[  470.966008]  [<c04c40c8>] ? ip6_input_finish+0x0/0x3db
[  470.966008]  [<c04c44d6>] ? ip6_input+0x33/0x47
[  470.966008]  [<c04c40c8>] ? ip6_input_finish+0x0/0x3db
[  470.966008]  [<c04c4775>] ? ip6_rcv_finish+0x8b/0x8e
[  470.966008]  [<fc81ea3a>] ? nf_ct_frag6_output+0x7c/0x95 [nf_conntrack_ipv6]
[  470.966008]  [<fc81e45c>] ? ipv6_defrag+0x87/0x9f [nf_conntrack_ipv6]
[  470.966008]  [<c04c46ea>] ? ip6_rcv_finish+0x0/0x8e
[  470.966008]  [<c046ee87>] ? nf_iterate+0x2f/0x62
[  470.966008]  [<c04c46ea>] ? ip6_rcv_finish+0x0/0x8e
[  470.966008]  [<c046f088>] ? nf_hook_slow+0x63/0xeb
[  470.966008]  [<c04c46ea>] ? ip6_rcv_finish+0x0/0x8e
[  470.966008]  [<c04c4aff>] ? ipv6_rcv+0x387/0x47c
[  470.966008]  [<c04c46ea>] ? ip6_rcv_finish+0x0/0x8e
[  470.966008]  [<c0455065>] ? __netif_receive_skb+0x367/0x3b6
[  470.966008]  [<c0455142>] ? process_backlog+0x8e/0x146
[  470.966008]  [<c0455c3b>] ? net_rx_action+0x62/0x119
[  470.966008]  [<c0232750>] ? __do_softirq+0x8b/0x10a
[  470.966008]  [<c02327fa>] ? do_softirq+0x2b/0x43
[  470.966008]  [<c0232885>] ? run_ksoftirqd+0x73/0x155
[  470.966008]  [<c0232812>] ? run_ksoftirqd+0x0/0x155
[  470.966008]  [<c023fdbd>] ? kthread+0x61/0x66
[  470.966008]  [<c023fd5c>] ? kthread+0x0/0x66
[  470.966008]  [<c0202c7a>] ? kernel_thread_helper+0x6/0x1a
[  470.966008] Code: e8 1b da d4 ff 68 48 89 4d c0 31 c9 31 d2 b8 58 11 68 c0 6a 00 6a 01 6a 02 e8 37 76 d7 ff 8b 9b 60 01 00 00 83 c4 10 85 db 74 07 <f0> ff 83 dc 00 00 00 b9 ae 89 4d c0 ba 01 00 00 00 b8 58 1 
[  470.966008] EIP: [<c04d89a7>] icmpv6_send+0x5c3/0x6e2 SS:ESP 0068:f7483b48
[  470.966008] CR2: 00000000a1fd3e8b
[  471.387732] ---[ end trace a325ca681eff783c ]---
[  471.388770] __iptables__: l2tp_2 IN=aaisp3 OUT= MAC= SRC=2001:0678:0001:0000:0000:0000:0000:0001 DST=2001:08b0:ffea:0000:0053:4150:5841:0001 LEN=430 TC=0 HOPLIMIT=60 FLOWLBL=0 PROTO=UDP SPT=53 DPT=22008 LEN= 
[  471.388833] __iptables__: l2tp_2 IN=aaisp3 OUT= MAC= SRC=80.68.89.159 DST=81.2.80.67 LEN=143 TOS=0x00 PREC=0x00 TTL=59 ID=12462 PROTO=UDP SPT=53 DPT=36911 LEN=123 
[  471.388874] __iptables__: l2tp_2 IN=aaisp3 OUT= MAC= SRC=208.94.149.2 DST=81.2.80.67 LEN=116 TOS=0x00 PREC=0x00 TTL=58 ID=22935 PROTO=UDP SPT=53 DPT=10068 LEN=96 
[  471.443611] Kernel panic - not syncing: Fatal exception in interrupt
[  471.444704] __iptables__: l2tp_2 IN=aaisp3 OUT= MAC= SRC=208.94.148.2 DST=81.2.80.67 LEN=120 TOS=0x00 PREC=0x00 TTL=58 ID=41552 PROTO=UDP SPT=53 DPT=27444 LEN=100 
[  471.444739] __iptables__: l2tp_2 IN=aaisp3 OUT= MAC= SRC=2a01:06d0:0001:0000:0000:0000:0000:0002 DST=2001:08b0:ffea:0000:0053:4150:5841:0001 LEN=109 TC=0 HOPLIMIT=56 FLOWLBL=0 PROTO=UDP SPT=53 DPT=31279 LEN= 
[  471.484694] Pid: 3, comm: ksoftirqd/0 Tainted: G      D     2.6.35.4-git+ #git+
[  471.492318] Call Trace:
[  471.494885]  [<c0511194>] ? printk+0xf/0x13
[  471.499161]  [<c0511116>] panic+0x55/0xc4
[  471.503331]  [<c02050ed>] oops_end+0x6e/0x7c
[  471.507768]  [<c021a514>] no_context+0x13f/0x149
[  471.512534]  [<c021a657>] __bad_area_nosemaphore+0x139/0x141
[  471.518341]  [<c04cef8d>] ? fib6_lookup+0x48/0x5c
[  471.523203]  [<c04cdd75>] ? ip6_pol_route+0x208/0x223
[  471.528422]  [<c024e201>] ? trace_hardirqs_on+0xb/0xd
[  471.533608]  [<c0232a72>] ? local_bh_enable_ip+0x97/0xad
[  471.539055]  [<c0513d08>] ? _raw_read_unlock_bh+0x2f/0x32
[  471.544620]  [<c04cdd75>] ? ip6_pol_route+0x208/0x223
[  471.549821]  [<c021a66c>] bad_area_nosemaphore+0xd/0x10
[  471.555192]  [<c021a910>] do_page_fault+0x14e/0x302
[  471.560145]  [<c04b3486>] ? __xfrm_lookup+0x32d/0x38b
[  471.565396]  [<c04e8bbe>] ? fib6_rule_lookup+0x35/0x77
[  471.570720]  [<c021a7c2>] ? do_page_fault+0x0/0x302
[  471.575807]  [<c051499b>] error_code+0x6b/0x70
[  471.580443]  [<c021a7c2>] ? do_page_fault+0x0/0x302
[  471.585476]  [<c04d89a7>] ? icmpv6_send+0x5c3/0x6e2
[  471.590527]  [<c0513fe0>] ? _raw_spin_unlock_irqrestore+0x42/0x58
[  471.596755]  [<c022e74d>] ? release_console_sem+0x197/0x1c4
[  471.602547]  [<fa73c0b5>] reject_tg6+0x70/0x43f [ip6t_REJECT]
[  471.608472]  [<fa7619b1>] ? ip6t_log_packet+0x15d/0x167 [ip6t_LOG]
[  471.614834]  [<c024e201>] ? trace_hardirqs_on+0xb/0xd
[  471.620120]  [<c0232a72>] ? local_bh_enable_ip+0x97/0xad
[  471.625575]  [<c0513f59>] ? _raw_spin_unlock_bh+0x2f/0x32
[  471.631145]  [<fa7619b1>] ? ip6t_log_packet+0x15d/0x167 [ip6t_LOG]
[  471.637519]  [<fa6290f0>] ? ipv6_find_hdr+0x48/0x164 [ip6_tables]
[  471.643794]  [<fa6297c1>] ip6t_do_table+0x4c8/0x53e [ip6_tables]
[  471.650014]  [<fa6cf0f0>] ? ip6table_mangle_hook+0xf0/0x100 [ip6table_mangle]
[  471.657364]  [<fa634018>] ip6table_filter_hook+0x18/0x20 [ip6table_filter]
[  471.664419]  [<c046ee87>] nf_iterate+0x2f/0x62
[  471.668935]  [<c04c40c8>] ? ip6_input_finish+0x0/0x3db
[  471.674231]  [<c046f088>] nf_hook_slow+0x63/0xeb
[  471.678999]  [<c04c40c8>] ? ip6_input_finish+0x0/0x3db
[  471.684321]  [<c04c44d6>] ip6_input+0x33/0x47
[  471.688851]  [<c04c40c8>] ? ip6_input_finish+0x0/0x3db
[  471.694097]  [<c04c4775>] ip6_rcv_finish+0x8b/0x8e
[  471.699002]  [<fc81ea3a>] nf_ct_frag6_output+0x7c/0x95 [nf_conntrack_ipv6]
[  471.706039]  [<fc81e45c>] ipv6_defrag+0x87/0x9f [nf_conntrack_ipv6]
[  471.712470]  [<c04c46ea>] ? ip6_rcv_finish+0x0/0x8e
[  471.717471]  [<c046ee87>] nf_iterate+0x2f/0x62
[  471.722013]  [<c04c46ea>] ? ip6_rcv_finish+0x0/0x8e
[  471.727013]  [<c046f088>] nf_hook_slow+0x63/0xeb
[  471.731703]  [<c04c46ea>] ? ip6_rcv_finish+0x0/0x8e
[  471.736764]  [<c04c4aff>] ipv6_rcv+0x387/0x47c
[  471.741384]  [<c04c46ea>] ? ip6_rcv_finish+0x0/0x8e
[  471.746438]  [<c0455065>] __netif_receive_skb+0x367/0x3b6
[  471.752011]  [<c0455142>] process_backlog+0x8e/0x146
[  471.757063]  [<c0455c3b>] net_rx_action+0x62/0x119
[  471.761994]  [<c0232750>] __do_softirq+0x8b/0x10a
[  471.766822]  [<c02327fa>] do_softirq+0x2b/0x43
[  471.771354]  [<c0232885>] run_ksoftirqd+0x73/0x155
[  471.776252]  [<c0232812>] ? run_ksoftirqd+0x0/0x155
[  471.781253]  [<c023fdbd>] kthread+0x61/0x66
[  471.785544]  [<c023fd5c>] ? kthread+0x0/0x66
[  471.789957]  [<c0202c7a>] kernel_thread_helper+0x6/0x1a
[  471.795306] Rebooting in 10 seconds..

-- 
Simon Arlott
