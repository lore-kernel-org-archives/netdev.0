From: Vinson Lee <vlee@twopensource.com>
Subject: tcp_fastretrans_alert warning in Linux kernel 3.10.
Date: Thu, 13 Nov 2014 11:26:20 -0800
Message-ID: <CAHTgTXXBFaLVuGmsjaOVtdZdGLvj3fiBK6YEQdwJiR_eO1QBNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:58976 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754035AbaKMT0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 14:26:21 -0500
Received: by mail-qg0-f43.google.com with SMTP id f51so10903260qge.2
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2014 11:26:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

We saw this networking tcp_fastretrans_alert warning in Linux kernel 3.10.

------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:2788 tcp_fastretrans_alert+0x7a1/0x7be()
Modules linked in: netconsole configfs xt_DSCP iptable_mangle
cpufreq_ondemand ipv6 ppdev parport_pc lp parport tcp_diag inet_diag
ipmi_si ipmi_devintf ipmi
_wdt iTCO_vendor_support acpi_cpufreq freq_table mperf coretemp
kvm_intel kvm crc32c_intel ghash_clmulni_intel microcode serio_raw
i2c_i801 lpc_ich mfd_core
t i2c_core ptp pps_core ioatdma dca wmi
CPU: 13 PID: 0 Comm: swapper/13 Not tainted 3.10.50 #1
 0000000000000000 ffff88085fce39b8 ffffffff814a4094 ffff88085fce39f0
 ffffffff8103cbf9 0000000000000000 000000000000470e 0000000000000000
 0000000000000000 ffff880824fe5e80 ffff88085fce3a00 ffffffff8103ccbf
Call Trace:
 <IRQ>  [<ffffffff814a4094>] dump_stack+0x19/0x1b
 [<ffffffff8103cbf9>] warn_slowpath_common+0x65/0x7d
 [<ffffffff8103ccbf>] warn_slowpath_null+0x1a/0x1c
 [<ffffffff81438c56>] tcp_fastretrans_alert+0x7a1/0x7be
 [<ffffffff81439644>] tcp_ack+0x95e/0xb47
 [<ffffffff81439d46>] tcp_rcv_established+0x23e/0x442
 [<ffffffff81442cab>] tcp_v4_do_rcv+0x1e6/0x3e8
 [<ffffffff8144371e>] tcp_v4_rcv+0x293/0x52c
 [<ffffffff81425e6a>] ? NF_HOOK_THRESH.constprop.11+0x53/0x53
 [<ffffffff8142c668>] ? do_ip_setsockopt.isra.7+0xa95/0xb3f
 [<ffffffff81425f4a>] ip_local_deliver_finish+0xe0/0x155
 [<ffffffff81425e6a>] ? NF_HOOK_THRESH.constprop.11+0x53/0x53
 [<ffffffff81425e48>] NF_HOOK_THRESH.constprop.11+0x31/0x53
 [<ffffffff814260ef>] ip_local_deliver+0x40/0x52
 [<ffffffff81425d50>] ip_rcv_finish+0x274/0x2b6
 [<ffffffff81425adc>] ? inet_del_offload+0x3d/0x3d
 [<ffffffff81425e48>] NF_HOOK_THRESH.constprop.11+0x31/0x53
 [<ffffffff81426324>] ip_rcv+0x223/0x267
 [<ffffffff813f76b4>] __netif_receive_skb_core+0x435/0x4a7
 [<ffffffff8107bab8>] ? timekeeping_get_ns.constprop.10+0x11/0x36
 [<ffffffff813f773e>] __netif_receive_skb+0x18/0x5a
 [<ffffffff813f8813>] netif_receive_skb+0x40/0x75
 [<ffffffff813f8f94>] napi_gro_receive+0x3e/0x80
 [<ffffffffa004a097>] igb_clean_rx_irq+0x67e/0x69e [igb]
 [<ffffffffa004a425>] igb_poll+0x36e/0x5b0 [igb]
 [<ffffffff8107bab8>] ? timekeeping_get_ns.constprop.10+0x11/0x36
 [<ffffffff8107bf32>] ? ktime_get+0x68/0x76
 [<ffffffff813f8a61>] net_rx_action+0xcf/0x196
 [<ffffffff8106870c>] ? sched_clock_cpu+0x42/0xc7
 [<ffffffff8104371d>] __do_softirq+0xd5/0x1f4
 [<ffffffff814b01bc>] call_softirq+0x1c/0x30
 [<ffffffff81003ecd>] do_softirq+0x33/0x6e
 [<ffffffff81043931>] irq_exit+0x51/0x93
 [<ffffffff814b086e>] do_IRQ+0x8e/0xa5
 [<ffffffff814a85aa>] common_interrupt+0x6a/0x6a
 <EOI>  [<ffffffff813c6807>] ? cpuidle_enter_state+0x52/0xa3
 [<ffffffff813c6800>] ? cpuidle_enter_state+0x4b/0xa3
 [<ffffffff813c693d>] cpuidle_idle_call+0xe5/0x13f
 [<ffffffff81009408>] arch_cpu_idle+0xe/0x1d
 [<ffffffff8107a872>] cpu_startup_entry+0x128/0x17a
 [<ffffffff814956be>] start_secondary+0x246/0x248
---[ end trace 804e605f7757900d ]---


net/ipv4/tcp_input.c
  2775  static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked,
  2776                                    int prior_sacked, int prior_packets,
  2777                                    bool is_dupack, int flag)
  2778  {
  2779          struct inet_connection_sock *icsk = inet_csk(sk);
  2780          struct tcp_sock *tp = tcp_sk(sk);
  2781          int do_lost = is_dupack || ((flag & FLAG_DATA_SACKED) &&
  2782                                      (tcp_fackets_out(tp) >
tp->reordering));
  2783          int newly_acked_sacked = 0;
  2784          int fast_rexmit = 0;
  2785
  2786          if (WARN_ON(!tp->packets_out && tp->sacked_out))
  2787                  tp->sacked_out = 0;
  2788          if (WARN_ON(!tp->sacked_out && tp->fackets_out))
  2789                  tp->fackets_out = 0;


Cheers,
Vinson
