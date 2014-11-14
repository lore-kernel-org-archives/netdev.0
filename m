From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tcp_mark_head_lost warning in Linux kernel 3.10
Date: Fri, 14 Nov 2014 15:00:22 -0800
Message-ID: <1416006022.17262.77.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAHTgTXXqaVzVOyGuVWpdQokY8RmYRMriaLhBecLzfg=HF6V8dQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Vinson Lee <vlee@twopensource.com>,
	Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:62134 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422637AbaKNXAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 18:00:25 -0500
Received: by mail-ig0-f170.google.com with SMTP id a13so569961igq.5
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 15:00:24 -0800 (PST)
In-Reply-To: <CAHTgTXXqaVzVOyGuVWpdQokY8RmYRMriaLhBecLzfg=HF6V8dQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-11-14 at 14:39 -0800, Vinson Lee wrote:
> Hi.
> 
> We hit this networking tcp_mark_head_lost warning in Linux kernel 3.10.
> 

CC Neal, because he is working on this


> ------------[ cut here ]------------
> WARNING: at net/ipv4/tcp_input.c:2262 tcp_mark_head_lost+0x1aa/0x1dd()
> Modules linked in: netconsole configfs xt_DSCP iptable_mangle
> cpufreq_ondemand ipv6 ppdev parport_pc lp parport tcp_diag inet_diag
> ipmi_si ipmi_devintf ipmi_msghandler iTCO_wdt iTCO_vendor_support
> acpi_cpufreq freq_table mperf coretemp kvm_intel kvm crc32c_intel
> ghash_clmulni_intel microcode serio_raw i2c_i801 lpc_ich mfd_core igb
> i2c_algo_bit i2c_core ptp pps_core ioatdma dca wmi
> CPU: 1 PID: 16561 Not tainted 3.10.50 #1
>  0000000000000000 ffff88085fc23948 ffffffff814a4094 ffff88085fc23980
>  ffffffff8103cbf9 0000000000000000 ffff8807b644b200 0000000000000001
>  ffff880764e1ca40 000000004e9c4970 ffff88085fc23990 ffffffff8103ccbf
> Call Trace:
>  <IRQ>  [<ffffffff814a4094>] dump_stack+0x19/0x1b
>  [<ffffffff8103cbf9>] warn_slowpath_common+0x65/0x7d
>  [<ffffffff8103ccbf>] warn_slowpath_null+0x1a/0x1c
>  [<ffffffff81434c61>] tcp_mark_head_lost+0x1aa/0x1dd
>  [<ffffffff814367fc>] tcp_update_scoreboard+0x4f/0x13f
>  [<ffffffff81438beb>] tcp_fastretrans_alert+0x736/0x7be
>  [<ffffffff81439644>] tcp_ack+0x95e/0xb47
>  [<ffffffff81439be6>] tcp_rcv_established+0xde/0x442
>  [<ffffffff81442cab>] tcp_v4_do_rcv+0x1e6/0x3e8
>  [<ffffffff8144371e>] tcp_v4_rcv+0x293/0x52c
>  [<ffffffff81425e6a>] ? NF_HOOK_THRESH.constprop.11+0x53/0x53
>  [<ffffffff8142d562>] ? __inet_lookup_listener+0xfa/0x17f
>  [<ffffffff81425f4a>] ip_local_deliver_finish+0xe0/0x155
>  [<ffffffff81425e6a>] ? NF_HOOK_THRESH.constprop.11+0x53/0x53
>  [<ffffffff81425e48>] NF_HOOK_THRESH.constprop.11+0x31/0x53
>  [<ffffffff814260ef>] ip_local_deliver+0x40/0x52
>  [<ffffffff81425d50>] ip_rcv_finish+0x274/0x2b6
>  [<ffffffff81425adc>] ? inet_del_offload+0x3d/0x3d
>  [<ffffffff81425e48>] NF_HOOK_THRESH.constprop.11+0x31/0x53
>  [<ffffffff81426324>] ip_rcv+0x223/0x267
>  [<ffffffff813f76b4>] __netif_receive_skb_core+0x435/0x4a7
>  [<ffffffff8107bab8>] ? timekeeping_get_ns.constprop.10+0x11/0x36
>  [<ffffffff813f773e>] __netif_receive_skb+0x18/0x5a
>  [<ffffffff813f8813>] netif_receive_skb+0x40/0x75
>  [<ffffffff813f8f94>] napi_gro_receive+0x3e/0x80
>  [<ffffffffa004a097>] igb_clean_rx_irq+0x67e/0x69e [igb]
>  [<ffffffffa004a425>] igb_poll+0x36e/0x5b0 [igb]
>  [<ffffffff813ea49a>] ? __sk_mem_reclaim+0x2f/0x84
>  [<ffffffff8143ef76>] ? tcp_delack_timer_handler+0x2e/0x19c
>  [<ffffffff813f8a61>] net_rx_action+0xcf/0x196
>  [<ffffffff8106870c>] ? sched_clock_cpu+0x42/0xc7
>  [<ffffffff8104371d>] __do_softirq+0xd5/0x1f4
>  [<ffffffff814b01bc>] call_softirq+0x1c/0x30
>  [<ffffffff81003ecd>] do_softirq+0x33/0x6e
>  [<ffffffff81043931>] irq_exit+0x51/0x93
>  [<ffffffff814b086e>] do_IRQ+0x8e/0xa5
>  [<ffffffff814a85aa>] common_interrupt+0x6a/0x6a
>  <EOI>
> ---[ end trace 8b2ed2c5c443e39d ]---
> 
> 
> net/ipv4/tcp_input.c
>   2200  /* Detect loss in event "A" above by marking head of queue up as lost.
>   2201   * For FACK or non-SACK(Reno) senders, the first "packets"
> number of segments
>   2202   * are considered lost. For RFC3517 SACK, a segment is
> considered lost if it
>   2203   * has at least tp->reordering SACKed seqments above it;
> "packets" refers to
>   2204   * the maximum SACKed segments to pass before reaching this limit.
>   2205   */
>   2206  static void tcp_mark_head_lost(struct sock *sk, int packets,
> int mark_head)
>   2207  {
> [...]
>   2262          tcp_verify_left_out(tp);
>   2263  }
> 
> include/net/tcp.h
>    936  /* Use define here intentionally to get WARN_ON location shown
> at the caller */
>    937  #define tcp_verify_left_out(tp) WARN_ON(tcp_left_out(tp) >
> tp->packets_out)
> 
> Cheers,
> Vinson
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
