From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: Assertions in latest kernels
Date: Wed, 23 Jan 2008 13:22:05 +0530
Message-ID: <OFC47DE839.9B2F85A5-ON652573D9.002BA994-652573D9.002B38BA@in.ibm.com>
References: <OFBE734C49.5B16C8E9-ON652573D9.002548B8-652573D9.0026407B@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([59.145.155.2]:55276 "EHLO
	e28esmtp02.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753949AbYAWHxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 02:53:54 -0500
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id m0N7rqED011555
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 13:23:52 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0N7rq431126554
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 13:23:52 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id m0N7rpkq028363
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 07:53:51 GMT
Received: from d23ml172.in.ibm.com (d23ml172.in.ibm.com [9.124.105.37])
	by d28av04.in.ibm.com (8.13.1/8.12.11) with ESMTP id m0N7rpVr028355
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 07:53:51 GMT
In-Reply-To: <OFBE734C49.5B16C8E9-ON652573D9.002548B8-652573D9.0026407B@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for the duplicate bug report, I just saw that Dave Young had already
reported three of the
4 assertions that I was getting. The only different assert I am getting is:

iperf with multiple threads almost always gets these 4, *especially* when I
do some batching :).

static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
{
      ...
      if (WARN_ON(!tp->sacked_out && tp->fackets_out))
            tp->fackets_out = 0;
      ...
}

Jan 13 20:57:08 elm3b39 kernel: ------------[ cut here ]------------
Jan 13 20:57:08 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2506
Jan 13 20:57:08 elm3b39 kernel: NIP: c0000000003a0358 LR: c0000000003a0808 CTR: c0000000003d7d90
Jan 13 20:57:08 elm3b39 kernel: REGS: c0000000e60f6e00 TRAP: 0700   Not tainted  (2.6.24-rc6)
Jan 13 20:57:08 elm3b39 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24024088  XER: 00000010
Jan 13 20:57:08 elm3b39 kernel: TASK = c0000001d20d1060[0] 'swapper' THREAD: c0000000e60f4000 CPU: 5
Jan 13 20:57:08 elm3b39 kernel: GPR00: 0000000000000001 c0000000e60f7080 c0000000005f1f00 c0000000dcccd280
Jan 13 20:57:08 elm3b39 kernel: GPR04: 000000009845ceac 0000000000000000 00000000000000fb 00000000000000f7
Jan 13 20:57:08 elm3b39 kernel: GPR08: 0000000000000000 0000000000000001 0000000000000000 c0000000003d8230
Jan 13 20:57:08 elm3b39 kernel: GPR12: 0000000044000022 c000000000554380 0000000000000000 0000000003ab69d3
Jan 13 20:57:08 elm3b39 kernel: GPR16: 00000000000000fa 0000000000000008 0000000000000008 c0000000dcccd348
Jan 13 20:57:08 elm3b39 kernel: GPR20: 000000009845ceac 0000000000000001 0000000000000000 0000000000000004
Jan 13 20:57:08 elm3b39 kernel: GPR24: 0000000044004082 0000000024004082 c0000000dcccd280 000000000000050e
Jan 13 20:57:08 elm3b39 kernel: GPR28: 0000000000000003 00000000000000f7 c0000000005ba670 000000000000050e
Jan 13 20:57:08 elm3b39 kernel: NIP [c0000000003a0358] .tcp_ack+0xa98/0x1fe0
Jan 13 20:57:08 elm3b39 kernel: LR [c0000000003a0808] .tcp_ack+0xf48/0x1fe0
Jan 13 20:57:08 elm3b39 kernel: Call Trace:
Jan 13 20:57:08 elm3b39 kernel: [c0000000e60f7080] [c0000000003a0808] .tcp_ack+0xf48/0x1fe0 (unreliable)
Jan 13 20:57:08 elm3b39 kernel: [c0000000e60f71e0] [c0000000003a5a24] .tcp_rcv_established+0x4d4/0x8f0
Jan 13 20:57:08 elm3b39 kernel: [c0000000e60f7290] [c0000000003add54] .tcp_v4_do_rcv+0x134/0x2a0
Jan 13 20:57:08 elm3b39 kernel: [c0000000e60f7350] [c0000000003b013c] .tcp_v4_rcv+0x75c/0x8d0
Jan 13 20:57:08 elm3b39 kernel: [c0000000e60f7410] [c000000000389fa0] .ip_local_deliver+0xf0/0x2d0
Jan 13 20:57:08 elm3b39 kernel: [c0000000e60f74a0] [c00000000038a4b4] .ip_rcv+0x334/0x6d0
Jan 13 20:57:08 elm3b39 kernel: [c0000000e60f7570] [c000000000358e6c] .netif_receive_skb+0x32c/0x630
Jan 13 20:57:08 elm3b39 kernel: [c0000000e60f7650] [d00000000040d27c] .ipoib_ib_handle_rx_wc+0x1dc/0x3a0 [ib_ipoib]
Jan 13 20:57:08 elm3b39 kernel: [c0000000e60f7700] [d00000000040ea6c] .ipoib_poll+0x24c/0x2b0 [ib_ipoib]
Jan 13 20:57:08 elm3b39 kernel: [c0000000e60f77e0] [c00000000035c830] .net_rx_action+0x1f0/0x2a0
Jan 13 20:57:08 elm3b39 kernel: [c0000000e60f78a0] [c00000000005af78] .__do_softirq+0xe8/0x1e0
Jan 13 20:57:08 elm3b39 kernel: [c0000000e60f7960] [c00000000000c4a4] .do_softirq+0x64/0xa0
Jan 13 20:57:08 elm3b39 kernel: [c0000000e60f79e0] [c00000000005b134] .irq_exit+0x74/0x90
Jan 13 20:57:08 elm3b39 kernel: [c0000000e60f7a60] [c00000000000cd90] .do_IRQ+0xe0/0x120
Jan 13 20:57:09 elm3b39 kernel: [c0000000e60f7ae0] [c000000000004780] hardware_interrupt_entry+0x18/0x98
Jan 13 20:57:09 elm3b39 kernel: --- Exception: 501 at .pseries_dedicated_idle_sleep+0xe8/0x1c0
Jan 13 20:57:09 elm3b39 kernel:     LR = .pseries_dedicated_idle_sleep+0xe0/0x1c0
Jan 13 20:57:09 elm3b39 kernel: [c0000000e60f7dd0] [0000000000000000] .__start+0x4000000000000000/0x8 (unreliable)
Jan 13 20:57:09 elm3b39 kernel: [c0000000e60f7e70] [c000000000011fec] .cpu_idle+0x13c/0x250
Jan 13 20:57:09 elm3b39 kernel: [c0000000e60f7f00] [c00000000002bd5c] .start_secondary+0x14c/0x190
Jan 13 20:57:09 elm3b39 kernel: [c0000000e60f7f90] [c000000000008364] .start_secondary_prolog+0xc/0x10
Jan 13 20:57:09 elm3b39 kernel: Instruction dump:
Jan 13 20:57:09 elm3b39 kernel: 815a055c 39200000 38000000 2f8a0000 409e0020 801a0560 2f800000 7d200026
Jan 13 20:57:09 elm3b39 kernel: 5529fffe 69290001 79290620 7d204b78 <0b090000> 2fa00000 409e1464 7f280120

