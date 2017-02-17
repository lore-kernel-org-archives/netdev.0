From: Willy Tarreau <w@1wt.eu>
Subject: Re: [4.9.10] ip_route_me_harder() reading off-slab
Date: Fri, 17 Feb 2017 07:23:49 +0100
Message-ID: <20170217062349.GB21674@1wt.eu>
References: <CAMVG2ssKxnEsu4=orZyB3UsHwT2CZhpWKFn2UmtoPOEu1KMHPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Jan Beulich <JBeulich@suse.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Daniel J Blueman <daniel@quora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:44538 "EHLO 1wt.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752681AbdBQGYD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Feb 2017 01:24:03 -0500
Content-Disposition: inline
In-Reply-To: <CAMVG2ssKxnEsu4=orZyB3UsHwT2CZhpWKFn2UmtoPOEu1KMHPw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 17, 2017 at 01:34:11PM +0800, Daniel J Blueman wrote:
> When booting a VM in libvirt/KVM attached to a local bridge and KASAN
> enabled on 4.9.10, we see a stream of KASAN warnings about off-slab
> access [1].

Did it start to appear with 4.9.10 or is 4.9.10 the first 4.9 kernel
you tried (ie is it a regression between earlier kernels and 4.9 or
a recent faulty stable backport into 4.9) ?

Willy


> Let me know if you'd like more debug.
> 
> Thanks,
>   Daniel
> 
> -- [1]
> 
> [  473.579567] BUG: KASAN: slab-out-of-bounds in
> ip_route_me_harder+0xbd5/0xf20 at addr ffff8801e1eb28a8
> [  473.579577] Read of size 1 by task vcselab/10339
> [  473.579590] CPU: 1 PID: 10339 Comm: vcselab Tainted: G    B  4.9.10-debug+ #2
> [  473.579596] Hardware name: Dell Inc. XPS 13 9360/0T3FTF, BIOS 1.3.2
> 01/18/2017
> [  473.579602]  ffff880236086ed0 ffffffff8aed83a1 ffff8802324fe6c0
> ffff8801e1eb26f8
> [  473.579626]  ffff880236086ef8 ffffffff8a849521 ffff880236086f90
> ffff8801e1eb26f0
> [  473.579645]  ffff8802324fe6c0 ffff880236086f80 ffffffff8a8497ba
> ffffffff8a848b2d
> [  473.579662] Call Trace:
> [  473.579667]  <IRQ>
> [  473.579685]  [<ffffffff8aed83a1>] dump_stack+0x85/0xc4
> [  473.579698]  [<ffffffff8a849521>] kasan_object_err+0x21/0x70
> [  473.579709]  [<ffffffff8a8497ba>] kasan_report_error+0x1fa/0x500
> [  473.579720]  [<ffffffff8a848b2d>] ? kasan_kmalloc+0xad/0xe0
> [  473.579737]  [<ffffffff8a849b21>] __asan_report_load1_noabort+0x61/0x70
> [  473.579749]  [<ffffffff8bbe42f5>] ? ip_route_me_harder+0xbd5/0xf20
> [  473.579759]  [<ffffffff8bbe42f5>] ip_route_me_harder+0xbd5/0xf20
> [  473.579772]  [<ffffffff8bbe3720>] ? nf_ip_saveroute+0x320/0x320
> [  473.579785]  [<ffffffff8bdd0c05>] ? entry_SYSCALL_64_fastpath+0x23/0xc6
> [  473.579801]  [<ffffffffc047846a>] iptable_mangle_hook+0x3da/0x5f0
> [iptable_mangle]
> [  473.579814]  [<ffffffff8ba4f080>] nf_iterate+0x110/0x2d0
> [  473.579826]  [<ffffffff8ba4f336>] nf_hook_slow+0xf6/0x1b0
> [  473.579839]  [<ffffffff8ba4f240>] ? nf_iterate+0x2d0/0x2d0
> [  473.579850]  [<ffffffff8ba885fb>] ? __ip_local_out+0x28b/0x720
> [  473.579860]  [<ffffffff8ba886d6>] __ip_local_out+0x366/0x720
> [  473.579869]  [<ffffffff8ba885fb>] ? __ip_local_out+0x28b/0x720
> [  473.579879]  [<ffffffff8ba88370>] ? ip_finish_output+0x9b0/0x9b0
> [  473.579894]  [<ffffffff8ba83b90>] ?
> __ip_flush_pending_frames.isra.43+0x2e0/0x2e0
> [  473.579905]  [<ffffffff8ba88aae>] ip_local_out+0x1e/0x130
> [  473.579915]  [<ffffffff8ba8910d>] ip_build_and_send_pkt+0x54d/0xad0
> [  473.579927]  [<ffffffff8bb1fdb4>] tcp_v4_send_synack+0x184/0x290
> [  473.579937]  [<ffffffff8bb1fc30>] ? tcp_v4_send_check+0x90/0x90
> [  473.579950]  [<ffffffff8ba9c047>] ? inet_ehash_insert+0x407/0x910
> [  473.579965]  [<ffffffff8bad365b>] tcp_conn_request+0x1f5b/0x2a20
> [  473.579977]  [<ffffffff8bad1700>] ? tcp_check_space+0x580/0x580
> [  473.579991]  [<ffffffff8a40e235>] ? default_wake_function+0x35/0x50
> [  473.580007]  [<ffffffff8a48aac0>] ? debug_check_no_locks_freed+0x290/0x290
> [  473.580018]  [<ffffffff8a48aac0>] ? debug_check_no_locks_freed+0x290/0x290
> [  473.580031]  [<ffffffffc032afc4>] ? ipt_do_table+0xb14/0x1ac0 [ip_tables]
> [  473.580041]  [<ffffffff8a48a4cd>] ? trace_hardirqs_on+0xd/0x10
> [  473.580055]  [<ffffffff8a38cc50>] ? __local_bh_enable_ip+0x70/0xc0
> [  473.580067]  [<ffffffff8bb19b94>] tcp_v4_conn_request+0x134/0x1e0
> [  473.580079]  [<ffffffff8bcf39e8>] tcp_v6_conn_request+0x1b8/0x230
> [  473.580089]  [<ffffffff8baead5d>] tcp_rcv_state_process+0x61d/0x41a0
> [  473.580101]  [<ffffffff8b9d9987>] ? sk_filter_trim_cap+0x2a7/0x6a0
> [  473.580114]  [<ffffffff8baea740>] ? tcp_finish_connect+0x600/0x600
> [  473.580125]  [<ffffffff8b9d99a6>] ? sk_filter_trim_cap+0x2c6/0x6a0
> [  473.580135]  [<ffffffff8b9d97d8>] ? sk_filter_trim_cap+0xf8/0x6a0
> [  473.580145]  [<ffffffff8bb16a4a>] ? tcp_md5_do_lookup+0x4a/0x190
> [  473.580157]  [<ffffffff8b9d96e0>] ? sk_filter_is_valid_access+0x60/0x60
> [  473.580170]  [<ffffffff8bdb3cfa>] ? tcp_v4_inbound_md5_hash+0x139/0x3bb
> [  473.580180]  [<ffffffff8bdb3bc1>] ? ncsi_start_dev+0x111/0x111
> [  473.580190]  [<ffffffff8bb1dba8>] tcp_v4_do_rcv+0x2c8/0x8c0
> [  473.580201]  [<ffffffff8bb22988>] tcp_v4_rcv+0x23a8/0x2fc0
> [  473.580214]  [<ffffffffc04005c7>] ? ipv4_confirm+0x117/0x3d0
> [nf_conntrack_ipv4]
> [  473.580228]  [<ffffffff8ba6f829>] ip_local_deliver_finish+0x2b9/0x970
> [  473.580241]  [<ffffffff8ba6f69a>] ? ip_local_deliver_finish+0x12a/0x970
> [  473.580251]  [<ffffffff8ba705a4>] ip_local_deliver+0x1b4/0x460
> [  473.580259]  [<ffffffff8ba705f2>] ? ip_local_deliver+0x202/0x460
> [  473.580267]  [<ffffffff8ba703f0>] ? ip_call_ra_chain+0x510/0x510
> [  473.580280]  [<ffffffffc16d8195>] ? iptable_nat_ipv4_in+0x15/0x20
> [iptable_nat]
> [  473.580290]  [<ffffffff8ba4f002>] ? nf_iterate+0x92/0x2d0
> [  473.580302]  [<ffffffff8ba6f570>] ? ip_rcv_finish+0x18e0/0x18e0
> [  473.580313]  [<ffffffff8ba4f336>] ? nf_hook_slow+0xf6/0x1b0
> [  473.580323]  [<ffffffff8ba6e2e5>] ip_rcv_finish+0x655/0x18e0
> [  473.580331]  [<ffffffff8ba7122b>] ? ip_rcv+0x9db/0x1280
> [  473.580341]  [<ffffffff8ba71093>] ip_rcv+0x843/0x1280
> [  473.580352]  [<ffffffff8ba71123>] ? ip_rcv+0x8d3/0x1280
> [  473.580363]  [<ffffffff8a423619>] ? __enqueue_entity+0x139/0x230
> [  473.580373]  [<ffffffff8ba70850>] ? ip_local_deliver+0x460/0x460
> [  473.580382]  [<ffffffff8ba6dc90>] ? inet_del_offload+0x40/0x40
> [  473.580393]  [<ffffffff8ba70850>] ? ip_local_deliver+0x460/0x460
> [  473.580407]  [<ffffffff8b981319>] __netif_receive_skb_core+0x15d9/0x2c90
> [  473.580419]  [<ffffffff8a446e31>] ? enqueue_task_fair+0x261/0x2980
> [  473.580428]  [<ffffffff8a48aac0>] ? debug_check_no_locks_freed+0x290/0x290
> [  473.580439]  [<ffffffff8b97fd40>] ? netif_wake_subqueue+0x1c0/0x1c0
> [  473.580453]  [<ffffffff8b9829f4>] __netif_receive_skb+0x24/0x150
> [  473.580468]  [<ffffffff8b982bf7>] process_backlog+0xd7/0x610
> [  473.580477]  [<ffffffff8b982d24>] ? process_backlog+0x204/0x610
> [  473.580487]  [<ffffffff8a46ad5b>] ? swake_up+0x3b/0x60
> [  473.580498]  [<ffffffff8b987c81>] net_rx_action+0x731/0xe60
> [  473.580510]  [<ffffffff8b987550>] ? sk_busy_loop+0xae0/0xae0
> [  473.580527]  [<ffffffff8a52623f>] ? clockevents_program_event+0x1cf/0x300
> [  473.580537]  [<ffffffff8a38c42c>] ? __local_bh_enable+0x3c/0x70
> [  473.580548]  [<ffffffff8bdd3fbe>] __do_softirq+0x21e/0x889
> [  473.580560]  [<ffffffff8bdd1c0c>] do_softirq_own_stack+0x1c/0x30
> [  473.580564]  <EOI>
> [  473.580578]  [<ffffffff8a38cba5>] do_softirq.part.17+0x65/0xa0
> [  473.580588]  [<ffffffff8ba84ad7>] ? ip_finish_output2+0x657/0x1040
> [  473.580597]  [<ffffffff8a38cc99>] __local_bh_enable_ip+0xb9/0xc0
> [  473.580606]  [<ffffffff8ba84b00>] ip_finish_output2+0x680/0x1040
> [  473.580615]  [<ffffffff8ba87f68>] ? ip_finish_output+0x5a8/0x9b0
> [  473.580626]  [<ffffffff8ba84480>] ? ip_copy_metadata+0x7a0/0x7a0
> [  473.580640]  [<ffffffff8ba4f336>] ? nf_hook_slow+0xf6/0x1b0
> [  473.580651]  [<ffffffff8ba4f240>] ? nf_iterate+0x2d0/0x2d0
> [  473.580660]  [<ffffffff8ba87f68>] ip_finish_output+0x5a8/0x9b0
> [  473.580670]  [<ffffffff8ba8c036>] ip_output+0x1d6/0x520
> [  473.580679]  [<ffffffff8ba8c07d>] ? ip_output+0x21d/0x520
> [  473.580692]  [<ffffffff8ba8be60>] ? ip_mc_output+0xc10/0xc10
> [  473.580704]  [<ffffffff8ba879c0>] ? ip_fragment.constprop.54+0x220/0x220
> [  473.580714]  [<ffffffff8ba88b0d>] ip_local_out+0x7d/0x130
> [  473.580724]  [<ffffffff8ba89e87>] ip_queue_xmit+0x7f7/0x1bc0
> [  473.580733]  [<ffffffff8ba896ce>] ? ip_queue_xmit+0x3e/0x1bc0
> [  473.580749]  [<ffffffff8b935147>] ? __skb_clone+0x97/0x7d0
> [  473.580760]  [<ffffffff8baf907c>] tcp_transmit_skb+0x172c/0x3430
> [  473.580771]  [<ffffffff8a8489b6>] ? kasan_unpoison_shadow+0x36/0x50
> [  473.580782]  [<ffffffff8baf7950>] ? __tcp_select_window+0x6b0/0x6b0
> [  473.580795]  [<ffffffff8bbae2c2>] ? fib_table_lookup+0xde2/0x1580
> [  473.580808]  [<ffffffff8bab769a>] ? sk_stream_alloc_skb+0x2da/0x770
> [  473.580816]  [<ffffffff8baf369f>] ? tcp_mtup_init+0x1af/0x330
> [  473.580827]  [<ffffffff8bb025fd>] tcp_connect+0x1ffd/0x2e30
> [  473.580836]  [<ffffffff8a48a4cd>] ? trace_hardirqs_on+0xd/0x10
> [  473.580850]  [<ffffffff8bb00600>] ? tcp_push_one+0xf0/0xf0
> [  473.580862]  [<ffffffff8b960d81>] ? secure_tcp_sequence_number+0x101/0x190
> [  473.580873]  [<ffffffff8b960c80>] ? secure_dccpv6_sequence_number+0x440/0x440
> [  473.580885]  [<ffffffff8ba5eec0>] ? ip_rt_update_pmtu+0xd10/0xd10
> [  473.580896]  [<ffffffff8bc08ab1>] ? xfrm_lookup_route+0x21/0x160
> [  473.580910]  [<ffffffff8bb18938>] tcp_v4_connect+0xe08/0x1cd0
> [  473.580923]  [<ffffffff8bb7a56b>] __inet_stream_connect+0x64b/0xd70
> [  473.580934]  [<ffffffff8bb79f20>] ? inet_bind+0x880/0x880
> [  473.580946]  [<ffffffff8b922900>] ? lock_sock_nested+0x90/0x110
> [  473.580955]  [<ffffffff8a48a4cd>] ? trace_hardirqs_on+0xd/0x10
> [  473.580965]  [<ffffffff8a38cc50>] ? __local_bh_enable_ip+0x70/0xc0
> [  473.580980]  [<ffffffff8bb7ace5>] inet_stream_connect+0x55/0xa0
> [  473.580991]  [<ffffffff8b91739c>] SYSC_connect+0x22c/0x2d0
> [  473.581000]  [<ffffffff8b917170>] ? SYSC_bind+0x240/0x240
> [  473.581011]  [<ffffffff8a90ec62>] ? set_close_on_exec+0xc2/0x170
> [  473.581021]  [<ffffffff8bdd03e7>] ? _raw_spin_unlock+0x27/0x40
> [  473.581035]  [<ffffffff8a90ec62>] ? set_close_on_exec+0xc2/0x170
> [  473.581046]  [<ffffffff8a8e8386>] ? SyS_fcntl+0x666/0xde0
> [  473.581056]  [<ffffffff8a8e7d20>] ? f_getown+0xb0/0xb0
> [  473.581067]  [<ffffffff8a20401a>] ? trace_hardirqs_on_thunk+0x1a/0x1c
> [  473.581078]  [<ffffffff8b91999e>] SyS_connect+0xe/0x10
> [  473.581091]  [<ffffffff8bdd0c05>] entry_SYSCALL_64_fastpath+0x23/0xc6
> [  473.581102] Object at ffff8801e1eb26f8, in cache request_sock_TCP size: 352
> [  473.581105] Allocated:
> [  473.581109] PID = 0
> [  473.581112] (stack is not available)
> [  473.581115] Freed:
> [  473.581119] PID = 0
> [  473.581122] (stack is not available)
> [  473.581125] Memory state around the buggy address:
> [  473.581134]  ffff8801e1eb2780: fc fc fc fc fc fc fc fc fc fc fc fc
> fc fc fc fc
> [  473.581140]  ffff8801e1eb2800: fc fc fc fc fc fc fc fc fc fc fc fc
> fc fc fc fc
> [  473.581147] >ffff8801e1eb2880: fc fc fc fc fc fc fc fc fc fc fc fc
> fc fc fc fc
> [  473.581151]                                   ^
> [  473.581157]  ffff8801e1eb2900: fc fc fc fc fc fc fc fc fc fc fc fc
> fc fc fc fc
> [  473.581164]  ffff8801e1eb2980: fc fc fc fc fc fc fc fc fc fc fc fc
> fc fc fc fc
> -- 
> Daniel J Blueman
