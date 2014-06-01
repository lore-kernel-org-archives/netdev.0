From: Emil Goode <emilgoode@gmail.com>
Subject: Re: Bug 75571
Date: Sun, 1 Jun 2014 16:43:41 +0200
Message-ID: <20140601144341.GA4382@lianli>
References: <1401085231.1775.9.camel@anpws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Alex <d77190@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:52339 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752141AbaFAOnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 10:43:16 -0400
Received: by mail-lb0-f182.google.com with SMTP id z11so2006873lbi.27
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2014 07:43:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1401085231.1775.9.camel@anpws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Alex,

Perhaps you would like to try version 3.15-rc7 of the kernel and
see if you can reproduce the bug?

Best regards,

Emil Goode

On Mon, May 26, 2014 at 01:20:31PM +0700, Alex wrote:
> Hello!
> I caught a bug and adviced to post it to this list from
> https://bugzilla.kernel.org/show_bug.cgi?id=75571
> 
> I tried ifconfig interfaces down (both tun and ifb) before setting rules
> with no luck. This is new trace from kernel 3.2.59.
> 
> [ 2945.851717] skb_under_panic: text:f9ca8566 len:209 put:148
> head:ece89000 data:ece88fce tail:0xece8909f end:0xece89140 dev:tun4177
> [ 2945.865020] ------------[ cut here ]------------
> [ 2945.866000] kernel BUG at net/core/skbuff.c:119!
> [ 2945.866000] invalid opcode: 0000 [#1] SMP 
> [ 2945.866000] Modules linked in: act_mirred sch_ingress sch_sfq cls_u32
> sch_htb pl2303 usbserial pppoe pppox ppp_generic slhc ext4 jbd2
> ipt_REJECT ipt_MASQUERADE xt_multiport xt_rateest xt_RATEEST xt_layer7
> xt_HL xt_TPROXY nf_tproxy_core xt_set xt_connmark ipt_DF ipt_ULOG
> xt_socket ip6_tables nf_defrag_ipv6 xt_mark xt_conntrack xt_TCPMSS
> xt_tcpudp xt_DSCP xt_dscp iptable_raw iptable_mangle iptable_nat nf_nat
> nf_conntrack_ipv4 nf_defrag_ipv4 iptable_filter ip_tables x_tables
> ip_set_hash_net ip_set nfnetlink cpufreq_ondemand acpi_cpufreq
> freq_table processor mperf ipip coretemp hwmon nf_conntrack macvlan ifb
> tun ipmi_watchdog ipmi_si ipmi_msghandler pcspkr
> [ 2945.881815] 
> [ 2945.881815] Pid: 0, comm: swapper/0 Not tainted 3.2.59 #1 Intel
> Corporation S3210SH/S3210SH
> [ 2945.881815] EIP: 0060:[<c05cbc64>] EFLAGS: 00010296 CPU: 0
> [ 2945.881815] EIP is at skb_push+0x84/0x90
> [ 2945.881815] EAX: 0000008b EBX: ece8909f ECX: 00000000 EDX: fffdd91d
> [ 2945.881815] ESI: f1960800 EDI: eb27c780 EBP: f540be24 ESP: f540bdf8
> [ 2945.881815]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> [ 2945.881815] Process swapper/0 (pid: 0, ti=f540a000 task=c09cffa0
> task.ti=c09c2000)
> [ 2945.881815] Stack:
> [ 2945.881815]  c0988ec4 f9ca8566 000000d1 00000094 ece89000 ece88fce
> ece8909f ece89140
> [ 2945.881815]  f1960800 d7d77900 eb27ca80 f540be48 f9ca8566 00000000
> c0a00e80 f2778800
> [ 2945.881815]  00000001 f9ca8450 c9efcd60 eb27ca80 f540be60 c05f0f7f
> f540bf1c 00000000
> [ 2945.881815] Call Trace:
> [ 2945.881815]  [<f9ca8566>] ? tcf_mirred+0x116/0x15c [act_mirred]
> [ 2945.881815]  [<f9ca8566>] tcf_mirred+0x116/0x15c [act_mirred]
> [ 2945.881815]  [<f9ca8450>] ? tcf_mirred_dump+0x110/0x110 [act_mirred]
> [ 2945.881815]  [<c05f0f7f>] tcf_action_exec+0x3f/0x80
> [ 2945.881815]  [<f9c860d2>] u32_classify+0x212/0x374 [cls_u32]
> [ 2945.881815]  [<c043860d>] ? e1000_clean_rx_irq+0x27d/0x380
> [ 2945.881815]  [<c05edc01>] tc_classify_compat+0x31/0x70
> [ 2945.881815]  [<c05eeb44>] tc_classify+0x44/0xb0
> [ 2945.881815]  [<f9ca10f1>] ingress_enqueue+0x21/0x80 [sch_ingress]
> [ 2945.881815]  [<c05d29c0>] __netif_receive_skb+0x2e0/0x4e0
> [ 2945.881815]  [<c05d2c8a>] process_backlog+0xca/0x1a0
> [ 2945.881815]  [<c05d4ba9>] net_rx_action+0xc9/0x1c0
> [ 2945.881815]  [<c013e95b>] __do_softirq+0x7b/0x110
> [ 2945.881815]  [<c013e8e0>] ? irq_enter+0x70/0x70
> [ 2945.881815]  [<c013e8e0>] ? irq_enter+0x70/0x70
> [ 2945.881815]  <IRQ> 
> [ 2945.881815]  [<c013e736>] ? irq_exit+0x66/0x90
> [ 2945.881815]  [<c0104786>] ? do_IRQ+0x46/0xb0
> [ 2945.881815]  [<c015801e>] ? sched_clock_idle_sleep_event+0xe/0x10
> [ 2945.881815]  [<c06d30a9>] ? common_interrupt+0x29/0x30
> [ 2945.881815]  [<c010a5a5>] ? mwait_idle+0x45/0x60
> [ 2945.881815]  [<c0102a5e>] ? cpu_idle+0x5e/0x90
> [ 2945.881815]  [<c068e138>] ? rest_init+0x58/0x60
> [ 2945.881815]  [<c0a037f1>] ? start_kernel+0x2f2/0x2f8
> [ 2945.881815]  [<c0a03329>] ? kernel_init+0x12f/0x12f
> [ 2945.881815]  [<c0a030b3>] ? i386_start_kernel+0xb3/0xbb
> [ 2945.881815] Code: 5c 24 18 8b 88 a8 00 00 00 89 54 24 0c 89 4c 24 10
> 8b 40 50 c7 04 24 c4 8e 98 c0 89 44 24 08 8b 45 04 89 44 24 04 e8 e9 3b
> 10 00 <0f> 0b eb fe 90 8d b4 26 00 00 00 00 55 89 e5 56 53 83 ec 24 8b 
> [ 2945.881815] EIP: [<c05cbc64>] skb_push+0x84/0x90 SS:ESP 0068:f540bdf8
> [ 2946.207961] ---[ end trace e1338b3c42fd7015 ]---
> [ 2946.213278] Kernel panic - not syncing: Fatal exception in interrupt
> [ 2946.220542] Pid: 0, comm: swapper/0 Tainted: G      D      3.2.59 #1
> [ 2946.228969] Call Trace:
> [ 2946.231856]  [<c06cf73b>] panic+0x57/0x169
> [ 2946.236592]  [<c0105f25>] oops_end+0xc5/0xd0
> [ 2946.241521]  [<c0106025>] die+0x45/0x70
> [ 2946.247879]  [<c01039d3>] do_trap+0x83/0xa0
> [ 2946.252715]  [<c0103dd0>] ? do_coprocessor_segment_overrun+0x80/0x80
> [ 2946.259978]  [<c0103e56>] do_invalid_op+0x86/0xa0
> [ 2946.265391]  [<c05cbc64>] ? skb_push+0x84/0x90
> [ 2946.270514]  [<c0139f6f>] ? vprintk+0x18f/0x3e0
> [ 2946.275736]  [<c06d2922>] error_code+0x5a/0x60
> [ 2946.280859]  [<c0103dd0>] ? do_coprocessor_segment_overrun+0x80/0x80
> [ 2946.288121]  [<c05cbc64>] ? skb_push+0x84/0x90
> [ 2946.293244]  [<f9ca8566>] ? tcf_mirred+0x116/0x15c [act_mirred]
> [ 2946.300019]  [<f9ca8566>] tcf_mirred+0x116/0x15c [act_mirred]
> [ 2946.306601]  [<f9ca8450>] ? tcf_mirred_dump+0x110/0x110 [act_mirred]
> [ 2946.313865]  [<c05f0f7f>] tcf_action_exec+0x3f/0x80
> [ 2946.319466]  [<f9c860d2>] u32_classify+0x212/0x374 [cls_u32]
> [ 2946.325958]  [<c043860d>] ? e1000_clean_rx_irq+0x27d/0x380
> [ 2946.332252]  [<c05edc01>] tc_classify_compat+0x31/0x70
> [ 2946.338154]  [<c05eeb44>] tc_classify+0x44/0xb0
> [ 2946.343374]  [<f9ca10f1>] ingress_enqueue+0x21/0x80 [sch_ingress]
> [ 2946.350344]  [<c05d29c0>] __netif_receive_skb+0x2e0/0x4e0
> [ 2946.356540]  [<c05d2c8a>] process_backlog+0xca/0x1a0
> [ 2946.362248]  [<c05d4ba9>] net_rx_action+0xc9/0x1c0
> [ 2946.367762]  [<c013e95b>] __do_softirq+0x7b/0x110
> [ 2946.373177]  [<c013e8e0>] ? irq_enter+0x70/0x70
> [ 2946.378397]  [<c013e8e0>] ? irq_enter+0x70/0x70
> [ 2946.383617]  <IRQ>  [<c013e736>] ? irq_exit+0x66/0x90
> [ 2946.389486]  [<c0104786>] ? do_IRQ+0x46/0xb0
> [ 2946.394414]  [<c015801e>] ? sched_clock_idle_sleep_event+0xe/0x10
> [ 2946.401386]  [<c06d30a9>] ? common_interrupt+0x29/0x30
> [ 2946.407287]  [<c010a5a5>] ? mwait_idle+0x45/0x60
> [ 2946.412604]  [<c0102a5e>] ? cpu_idle+0x5e/0x90
> [ 2946.417729]  [<c068e138>] ? rest_init+0x58/0x60
> [ 2946.422941]  [<c0a037f1>] ? start_kernel+0x2f2/0x2f8
> [ 2946.428647]  [<c0a03329>] ? kernel_init+0x12f/0x12f
> [ 2946.434256]  [<c0a030b3>] ? i386_start_kernel+0xb3/0xbb
> [ 2946.441242] Rebooting in 5 seconds..
> [ 2946.441242] ACPI MEMORY or I/O RESET_REG.
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
