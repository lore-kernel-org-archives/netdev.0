From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: e1000 TX unit hang and a possibly kernel oops
Date: Tue, 06 Apr 2010 14:23:31 -0300
Message-ID: <4BBB6E13.7020203@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: kamaleshb@in.ibm.com
To: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:54366 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753123Ab0DFRXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 13:23:38 -0400
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp01.br.ibm.com (8.14.3/8.13.1) with ESMTP id o36HdejC000573
	for <netdev@vger.kernel.org>; Tue, 6 Apr 2010 14:39:40 -0300
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.8.31.93])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o36HQxfd1183774
	for <netdev@vger.kernel.org>; Tue, 6 Apr 2010 14:27:00 -0300
Received: from d24av02.br.ibm.com (loopback [127.0.0.1])
	by d24av02.br.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o36ENXgx025935
	for <netdev@vger.kernel.org>; Tue, 6 Apr 2010 11:23:33 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, 

During a test workload on kernel 2.6.27.19-5-ppc64 (SLES11), we are facing
a "TX Unit Hang" issue, and then a kernel oops.

We also tried the same workload with the sourceforge device driver and the
problem is also reproducible. When  TSO is off, the problem don't appear on
both driver. 

I am not sure if the TX hang issue could be related to oops that happen in the
virtual memory subsystem, that is why I decided to ask you guys.

Thanks, 

Mar 17 02:34:34 c862f3sq03 kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Mar 17 02:34:34 c862f3sq03 kernel:   Tx Queue             <0>
Mar 17 02:34:34 c862f3sq03 kernel:   TDH                  <d6>
Mar 17 02:34:34 c862f3sq03 kernel:   TDT                  <d1>
Mar 17 02:34:34 c862f3sq03 kernel:   next_to_use          <d1>
Mar 17 02:34:34 c862f3sq03 kernel:   next_to_clean        <d5>
Mar 17 02:34:34 c862f3sq03 kernel: buffer_info[next_to_clean]
Mar 17 02:34:34 c862f3sq03 kernel:   time_stamp           <10053bc21>
Mar 17 02:34:34 c862f3sq03 kernel:   next_to_watch        <da>
Mar 17 02:34:34 c862f3sq03 kernel:   jiffies              <10053bcbc>
Mar 17 02:34:34 c862f3sq03 kernel:   next_to_watch.status <0>
Mar 17 02:34:36 c862f3sq03 kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Mar 17 02:34:36 c862f3sq03 kernel:   Tx Queue             <0>
Mar 17 02:34:36 c862f3sq03 kernel:   TDH                  <d6>
Mar 17 02:34:36 c862f3sq03 kernel:   TDT                  <d1>
Mar 17 02:34:36 c862f3sq03 kernel:   next_to_use          <d1>
Mar 17 02:34:36 c862f3sq03 kernel:   next_to_clean        <d5>
Mar 17 02:34:36 c862f3sq03 kernel: buffer_info[next_to_clean]
Mar 17 02:34:36 c862f3sq03 kernel:   time_stamp           <10053bc21>
Mar 17 02:34:36 c862f3sq03 kernel:   next_to_watch        <da>
Mar 17 02:34:36 c862f3sq03 kernel:   jiffies              <10053bd84>
Mar 17 02:34:36 c862f3sq03 kernel:   next_to_watch.status <0>
Mar 17 02:34:38 c862f3sq03 kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Mar 17 02:34:38 c862f3sq03 kernel:   Tx Queue             <0>
Mar 17 02:34:38 c862f3sq03 kernel:   TDH                  <d6>
Mar 17 02:34:38 c862f3sq03 kernel:   TDT                  <d1>
Mar 17 02:34:38 c862f3sq03 kernel:   next_to_use          <d1>
Mar 17 02:34:38 c862f3sq03 kernel:   next_to_clean        <d5>
Mar 17 02:34:38 c862f3sq03 kernel: buffer_info[next_to_clean]
Mar 17 02:34:38 c862f3sq03 kernel:   time_stamp           <10053bc21>
Mar 17 02:34:38 c862f3sq03 kernel:   next_to_watch        <da>
Mar 17 02:34:38 c862f3sq03 kernel:   jiffies              <10053be4c>
Mar 17 02:34:38 c862f3sq03 kernel:   next_to_watch.status <0>
Mar 17 02:34:40 c862f3sq03 kernel: ------------[ cut here ]------------
Mar 17 02:34:40 c862f3sq03 kernel: Badness at net/sched/sch_generic.c:219
Mar 17 02:34:40 c862f3sq03 kernel: NIP: c000000000498eac LR: c000000000498d8c CTR: 0000000000000001
Mar 17 02:34:40 c862f3sq03 kernel: REGS: c00000000f68fa80 TRAP: 0700   Tainted: G           (2.6.27.19-5-ppc64)
Mar 17 02:34:40 c862f3sq03 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 88000022  XER: 00000010
Mar 17 02:34:40 c862f3sq03 kernel: TASK = c000000000918340[0] 'swapper' THREAD: c0000000009d0000 CPU: 0
Mar 17 02:34:40 c862f3sq03 kernel: GPR00: 0000000000000000 c00000000f68fd00 c0000000009cbc80 0000000000000080 
Mar 17 02:34:40 c862f3sq03 kernel: GPR04: 0000000000000000 c000000000498ce4 c0000000009bb550 c0000003be260980 
Mar 17 02:34:40 c862f3sq03 kernel: GPR08: 0000000000000002 c000000000c91e68 0000000000000080 ffffffffffffff01 
Mar 17 02:34:40 c862f3sq03 kernel: GPR12: 0000000000000000 c000000000a92c80 0000000000051bc3 0000000000051aa1 
Mar 17 02:34:40 c862f3sq03 kernel: GPR16: 0000000000051bbb c000000000a51280 0000000000000000 0000000000000000 
Mar 17 02:34:40 c862f3sq03 kernel: GPR20: c000000000bda198 c000000000bda598 c000000000bda998 0000000000000002 
Mar 17 02:34:40 c862f3sq03 kernel: GPR24: ffffffffffffffff 0000000000000000 0000000000000000 0000000000000000 
Mar 17 02:34:40 c862f3sq03 kernel: GPR28: c0000003be2c9400 0000000000000001 c000000000961118 c0000003be260980 
Mar 17 02:34:40 c862f3sq03 kernel: NIP [c000000000498eac] .dev_watchdog+0x190/0x2cc
Mar 17 02:34:40 c862f3sq03 kernel: LR [c000000000498d8c] .dev_watchdog+0x70/0x2cc
Mar 17 02:34:40 c862f3sq03 kernel: Call Trace:
Mar 17 02:34:40 c862f3sq03 kernel: [c00000000f68fd00] [c000000000498d8c] .dev_watchdog+0x70/0x2cc (unreliable)
Mar 17 02:34:40 c862f3sq03 kernel: [c00000000f68fdc0] [c00000000009cec4] .run_timer_softirq+0x1e8/0x2c4
Mar 17 02:34:40 c862f3sq03 kernel: [c00000000f68fec0] [c00000000009705c] .__do_softirq+0x13c/0x284
Mar 17 02:34:40 c862f3sq03 kernel: [c00000000f68ff90] [c00000000002ab4c] .call_do_softirq+0x14/0x24
Mar 17 02:34:40 c862f3sq03 kernel: [c0000000009d3880] [c00000000000db5c] .do_softirq+0x88/0xf0
Mar 17 02:34:40 c862f3sq03 kernel: [c0000000009d3920] [c000000000096e38] .irq_exit+0x5c/0xb4
Mar 17 02:34:40 c862f3sq03 kernel: [c0000000009d39a0] [c000000000027c1c] .timer_interrupt+0xd8/0x104
Mar 17 02:34:40 c862f3sq03 kernel: [c0000000009d3a30] [c000000000003718] decrementer_common+0x118/0x180
Mar 17 02:34:40 c862f3sq03 kernel: --- Exception: 901 at .pseries_dedicated_idle_sleep+0xf0/0x1b8
Mar 17 02:34:40 c862f3sq03 kernel:     LR = .pseries_dedicated_idle_sleep+0xe0/0x1b8
Mar 17 02:34:40 c862f3sq03 kernel: [c0000000009d3d20] [c0000000000501b8] .pseries_dedicated_idle_sleep+0x80/0x1b8 (unreliable)
Mar 17 02:34:40 c862f3sq03 kernel: [c0000000009d3dd0] [c000000000013114] .cpu_idle+0xfc/0x1a4
Mar 17 02:34:40 c862f3sq03 kernel: [c0000000009d3e60] [c00000000051b124] .rest_init+0x7c/0x94
Mar 17 02:34:40 c862f3sq03 kernel: [c0000000009d3ee0] [c000000000760d18] .start_kernel+0x52c/0x554
Mar 17 02:34:40 c862f3sq03 kernel: [c0000000009d3f90] [c000000000008568] .start_here_common+0x3c/0x54
Mar 17 02:34:40 c862f3sq03 kernel: Instruction dump:
Mar 17 02:34:40 c862f3sq03 kernel: 48000064 e97e8018 e81c0330 e93c033a 7d290214 e80b0000 7d604851 40800048 
Mar 17 02:34:40 c862f3sq03 kernel: e93e8028 80090000 2f800000 40fe0014 <0fe00000> 38000001 e93e8028 90090000 
Mar 17 02:34:40 c862f3sq03 kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Mar 17 02:34:40 c862f3sq03 kernel:   Tx Queue             <0>
Mar 17 02:34:40 c862f3sq03 kernel:   TDH                  <d6>
Mar 17 02:34:40 c862f3sq03 kernel:   TDT                  <d1>
Mar 17 02:34:40 c862f3sq03 kernel:   next_to_use          <d1>
Mar 17 02:34:40 c862f3sq03 kernel:   next_to_clean        <d5>
Mar 17 02:34:40 c862f3sq03 kernel: buffer_info[next_to_clean]
Mar 17 02:34:40 c862f3sq03 kernel:   time_stamp           <10053bc21>
Mar 17 02:34:40 c862f3sq03 kernel:   next_to_watch        <da>
Mar 17 02:34:40 c862f3sq03 kernel:   jiffies              <10053bf14>
Mar 17 02:34:40 c862f3sq03 kernel:   next_to_watch.status <0>
Mar 17 02:34:44 c862f3sq03 kernel: e1000: eth1: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
--snip--
Mar 17 15:31:05 c862f3sq04 kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Mar 17 15:31:05 c862f3sq04 kernel:   Tx Queue             <0>
Mar 17 15:31:05 c862f3sq04 kernel:   TDH                  <98>
Mar 17 15:31:05 c862f3sq04 kernel:   TDT                  <93>
Mar 17 15:31:05 c862f3sq04 kernel:   next_to_use          <93>
Mar 17 15:31:05 c862f3sq04 kernel:   next_to_clean        <97>
Mar 17 15:31:05 c862f3sq04 kernel: buffer_info[next_to_clean]
Mar 17 15:31:05 c862f3sq04 kernel:   time_stamp           <10080baf1>
Mar 17 15:31:05 c862f3sq04 kernel:   next_to_watch        <9a>
Mar 17 15:31:05 c862f3sq04 kernel:   jiffies              <10080bca8>
Mar 17 15:31:05 c862f3sq04 kernel:   next_to_watch.status <0>
Mar 17 15:31:06 c862f3sq04 kernel: ------------[ cut here ]------------
Mar 17 15:31:06 c862f3sq04 kernel: Badness at net/sched/sch_generic.c:219
Mar 17 15:31:06 c862f3sq04 kernel: NIP: c000000000498eac LR: c000000000498d8c CTR: 0000000000000001
Mar 17 15:31:06 c862f3sq04 kernel: REGS: c00000000f68fa80 TRAP: 0700   Tainted: G           (2.6.27.19-5-ppc64)
Mar 17 15:31:06 c862f3sq04 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 88000022  XER: 00000010
Mar 17 15:31:06 c862f3sq04 kernel: TASK = c000000000918340[0] 'swapper' THREAD: c0000000009d0000 CPU: 0
Mar 17 15:31:06 c862f3sq04 kernel: GPR00: 0000000000000000 c00000000f68fd00 c0000000009cbc80 0000000000000080 
Mar 17 15:31:06 c862f3sq04 kernel: GPR04: 0000000000000000 c000000000498ce4 c0000000009bb550 c0000001dcf6d180 
Mar 17 15:31:06 c862f3sq04 kernel: GPR08: 0000000000000002 c000000000c91e68 0000000000000080 ffffffffffffffd9 
Mar 17 15:31:06 c862f3sq04 kernel: GPR12: 0000000000000000 c000000000a92c80 0000000000051bc3 0000000000051aa1 
Mar 17 15:31:06 c862f3sq04 kernel: GPR16: 0000000000051bbb c000000000a51280 0000000000000000 0000000000000000 
Mar 17 15:31:06 c862f3sq04 kernel: GPR20: c000000000bda198 c000000000bda598 c000000000bda998 0000000000000002 
Mar 17 15:31:06 c862f3sq04 kernel: GPR24: ffffffffffffffff 0000000000000000 0000000000000000 0000000000000000 
Mar 17 15:31:06 c862f3sq04 kernel: GPR28: c0000001dcb60380 0000000000000001 c000000000961118 c0000001dcf6d180 
Mar 17 15:31:06 c862f3sq04 kernel: NIP [c000000000498eac] .dev_watchdog+0x190/0x2cc
Mar 17 15:31:06 c862f3sq04 kernel: LR [c000000000498d8c] .dev_watchdog+0x70/0x2cc
Mar 17 15:31:06 c862f3sq04 kernel: Call Trace:
Mar 17 15:31:06 c862f3sq04 kernel: [c00000000f68fd00] [c000000000498d8c] .dev_watchdog+0x70/0x2cc (unreliable)
Mar 17 15:31:06 c862f3sq04 kernel: [c00000000f68fdc0] [c00000000009cec4] .run_timer_softirq+0x1e8/0x2c4
Mar 17 15:31:06 c862f3sq04 kernel: [c00000000f68fec0] [c00000000009705c] .__do_softirq+0x13c/0x284
Mar 17 15:31:06 c862f3sq04 kernel: [c00000000f68ff90] [c00000000002ab4c] .call_do_softirq+0x14/0x24
Mar 17 15:31:06 c862f3sq04 kernel: [c0000000009d3880] [c00000000000db5c] .do_softirq+0x88/0xf0
Mar 17 15:31:06 c862f3sq04 kernel: [c0000000009d3920] [c000000000096e38] .irq_exit+0x5c/0xb4
Mar 17 15:31:06 c862f3sq04 kernel: [c0000000009d39a0] [c000000000027c1c] .timer_interrupt+0xd8/0x104
Mar 17 15:31:06 c862f3sq04 kernel: [c0000000009d3a30] [c000000000003718] decrementer_common+0x118/0x180
Mar 17 15:31:06 c862f3sq04 kernel: --- Exception: 901 at .pseries_dedicated_idle_sleep+0xe8/0x1b8
Mar 17 15:31:06 c862f3sq04 kernel:     LR = .pseries_dedicated_idle_sleep+0xe0/0x1b8
Mar 17 15:31:06 c862f3sq04 kernel: [c0000000009d3d20] [c0000000000501b8] .pseries_dedicated_idle_sleep+0x80/0x1b8 (unreliable)
Mar 17 15:31:06 c862f3sq04 kernel: [c0000000009d3dd0] [c000000000013114] .cpu_idle+0xfc/0x1a4
Mar 17 15:31:06 c862f3sq04 kernel: [c0000000009d3e60] [c00000000051b124] .rest_init+0x7c/0x94
Mar 17 15:31:06 c862f3sq04 kernel: [c0000000009d3ee0] [c000000000760d18] .start_kernel+0x52c/0x554
Mar 17 15:31:06 c862f3sq04 kernel: [c0000000009d3f90] [c000000000008568] .start_here_common+0x3c/0x54
Mar 17 15:31:06 c862f3sq04 kernel: Instruction dump:
Mar 17 15:31:06 c862f3sq04 kernel: 48000064 e97e8018 e81c0330 e93c033a 7d290214 e80b0000 7d604851 40800048 
Mar 17 15:31:06 c862f3sq04 kernel: e93e8028 80090000 2f800000 40fe0014 <0fe00000> 38000001 e93e8028 90090000 
Mar 17 15:31:09 c862f3sq04 kernel: e1000: eth1: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
--snip--
Mar 17 15:59:54 c862f3sq02 kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Mar 17 15:59:54 c862f3sq02 kernel:   Tx Queue             <0>
Mar 17 15:59:54 c862f3sq02 kernel:   TDH                  <3d>
Mar 17 15:59:54 c862f3sq02 kernel:   TDT                  <1f>
Mar 17 15:59:54 c862f3sq02 kernel:   next_to_use          <1f>
Mar 17 15:59:54 c862f3sq02 kernel:   next_to_clean        <3c>
Mar 17 15:59:54 c862f3sq02 kernel: buffer_info[next_to_clean]
Mar 17 15:59:54 c862f3sq02 kernel:   time_stamp           <1004d6039>
Mar 17 15:59:54 c862f3sq02 kernel:   next_to_watch        <41>
Mar 17 15:59:54 c862f3sq02 kernel:   jiffies              <1004d6164>
Mar 17 15:59:54 c862f3sq02 kernel:   next_to_watch.status <0>
Mar 17 15:59:54 c862f3sq02 kernel: klogd 1.4.1, ---------- state change ----------
Mar 17 15:59:56 c862f3sq02 kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Mar 17 15:59:56 c862f3sq02 kernel:   Tx Queue             <0>
Mar 17 15:59:56 c862f3sq02 kernel:   TDH                  <3d>
Mar 17 15:59:56 c862f3sq02 kernel:   TDT                  <1f>
Mar 17 15:59:56 c862f3sq02 kernel:   next_to_use          <1f>
Mar 17 15:59:56 c862f3sq02 kernel:   next_to_clean        <3c>
Mar 17 15:59:56 c862f3sq02 kernel: buffer_info[next_to_clean]
Mar 17 15:59:56 c862f3sq02 kernel:   time_stamp           <1004d6039>
Mar 17 15:59:56 c862f3sq02 kernel:   next_to_watch        <41>
Mar 17 15:59:56 c862f3sq02 kernel:   jiffies              <1004d622c>
Mar 17 15:59:56 c862f3sq02 kernel:   next_to_watch.status <0>
Mar 17 15:59:58 c862f3sq02 kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Mar 17 15:59:58 c862f3sq02 kernel:   Tx Queue             <0>
Mar 17 15:59:58 c862f3sq02 kernel:   TDH                  <3d>
Mar 17 15:59:58 c862f3sq02 kernel:   TDT                  <1f>
Mar 17 15:59:58 c862f3sq02 kernel:   next_to_use          <1f>
Mar 17 15:59:58 c862f3sq02 kernel:   next_to_clean        <3c>
Mar 17 15:59:58 c862f3sq02 kernel: buffer_info[next_to_clean]
Mar 17 15:59:58 c862f3sq02 kernel:   time_stamp           <1004d6039>
Mar 17 15:59:58 c862f3sq02 kernel:   next_to_watch        <41>
Mar 17 15:59:58 c862f3sq02 kernel:   jiffies              <1004d62f4>
Mar 17 15:59:58 c862f3sq02 kernel:   next_to_watch.status <0>
Mar 17 16:00:03 c862f3sq02 kernel: e1000: eth1: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX

Mar 17 17:42:59 c862f3sq02 kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Mar 17 17:42:59 c862f3sq02 kernel:   Tx Queue             <0>
Mar 17 17:42:59 c862f3sq02 kernel:   TDH                  <ec>
Mar 17 17:42:59 c862f3sq02 kernel:   TDT                  <e8>
Mar 17 17:42:59 c862f3sq02 kernel:   next_to_use          <e8>
Mar 17 17:42:59 c862f3sq02 kernel:   next_to_clean        <ec>
Mar 17 17:42:59 c862f3sq02 kernel: buffer_info[next_to_clean]
Mar 17 17:42:59 c862f3sq02 kernel:   time_stamp           <10056d08d>
Mar 17 17:42:59 c862f3sq02 kernel:   next_to_watch        <f0>
Mar 17 17:42:59 c862f3sq02 kernel:   jiffies              <10056d168>
Mar 17 17:42:59 c862f3sq02 kernel:   next_to_watch.status <0>
Mar 17 17:43:01 c862f3sq02 kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Mar 17 17:43:01 c862f3sq02 kernel:   Tx Queue             <0>
Mar 17 17:43:01 c862f3sq02 kernel:   TDH                  <ec>
Mar 17 17:43:01 c862f3sq02 kernel:   TDT                  <e8>
Mar 17 17:43:01 c862f3sq02 kernel:   next_to_use          <e8>
Mar 17 17:43:01 c862f3sq02 kernel:   next_to_clean        <ec>
Mar 17 17:43:01 c862f3sq02 kernel: buffer_info[next_to_clean]
Mar 17 17:43:01 c862f3sq02 kernel:   time_stamp           <10056d08d>
Mar 17 17:43:01 c862f3sq02 kernel:   next_to_watch        <f0>
Mar 17 17:43:01 c862f3sq02 kernel:   jiffies              <10056d230>
Mar 17 17:43:01 c862f3sq02 kernel:   next_to_watch.status <0>
Mar 17 17:43:06 c862f3sq02 kernel: e1000: eth1: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex, Flow Control: R
--snip--

Mar 17 18:43:32 c862f3sq03 kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Mar 17 18:43:32 c862f3sq03 kernel:   Tx Queue             <0>
Mar 17 18:43:32 c862f3sq03 kernel:   TDH                  <3d>
Mar 17 18:43:32 c862f3sq03 kernel:   TDT                  <37>
Mar 17 18:43:32 c862f3sq03 kernel:   next_to_use          <37>
Mar 17 18:43:32 c862f3sq03 kernel:   next_to_clean        <3c>
Mar 17 18:43:32 c862f3sq03 kernel: buffer_info[next_to_clean]
Mar 17 18:43:32 c862f3sq03 kernel:   time_stamp           <100ac71f5>
Mar 17 18:43:32 c862f3sq03 kernel:   next_to_watch        <41>
Mar 17 18:43:32 c862f3sq03 kernel:   jiffies              <100ac72e4>
Mar 17 18:43:32 c862f3sq03 kernel:   next_to_watch.status <0>
Mar 17 18:43:32 c862f3sq03 kernel: klogd 1.4.1, ---------- state change ----------
Mar 17 18:43:34 c862f3sq03 kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Mar 17 18:43:34 c862f3sq03 kernel:   Tx Queue             <0>
Mar 17 18:43:34 c862f3sq03 kernel:   TDH                  <3d>
Mar 17 18:43:34 c862f3sq03 kernel:   TDT                  <37>
Mar 17 18:43:34 c862f3sq03 kernel:   next_to_use          <37>
Mar 17 18:43:34 c862f3sq03 kernel:   next_to_clean        <3c>
Mar 17 18:43:34 c862f3sq03 kernel: buffer_info[next_to_clean]
Mar 17 18:43:34 c862f3sq03 kernel:   time_stamp           <100ac71f5>
Mar 17 18:43:34 c862f3sq03 kernel:   next_to_watch        <41>
Mar 17 18:43:34 c862f3sq03 kernel:   jiffies              <100ac73ac>
Mar 17 18:43:34 c862f3sq03 kernel:   next_to_watch.status <0>
Mar 17 18:43:36 c862f3sq03 kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Mar 17 18:43:36 c862f3sq03 kernel:   Tx Queue             <0>
Mar 17 18:43:36 c862f3sq03 kernel:   TDH                  <3d>
Mar 17 18:43:36 c862f3sq03 kernel:   TDT                  <37>
Mar 17 18:43:36 c862f3sq03 kernel:   next_to_use          <37>
Mar 17 18:43:36 c862f3sq03 kernel:   next_to_clean        <3c>
Mar 17 18:43:36 c862f3sq03 kernel: buffer_info[next_to_clean]
Mar 17 18:43:36 c862f3sq03 kernel:   time_stamp           <100ac71f5>
Mar 17 18:43:36 c862f3sq03 kernel:   next_to_watch        <41>
Mar 17 18:43:36 c862f3sq03 kernel:   jiffies              <100ac7474>
Mar 17 18:43:36 c862f3sq03 kernel:   next_to_watch.status <0>
Mar 17 18:43:38 c862f3sq03 kernel: e1000: eth1: e1000_clean_tx_irq: Detected Tx Unit Hang
Mar 17 18:43:38 c862f3sq03 kernel:   Tx Queue             <0>
Mar 17 18:43:38 c862f3sq03 kernel:   TDH                  <3d>
Mar 17 18:43:38 c862f3sq03 kernel:   TDT                  <37>
Mar 17 18:43:38 c862f3sq03 kernel:   next_to_use          <37>
Mar 17 18:43:38 c862f3sq03 kernel:   next_to_clean        <3c>
Mar 17 18:43:38 c862f3sq03 kernel: buffer_info[next_to_clean]
Mar 17 18:43:38 c862f3sq03 kernel:   time_stamp           <100ac71f5>
Mar 17 18:43:38 c862f3sq03 kernel:   next_to_watch        <41>
Mar 17 18:43:38 c862f3sq03 kernel:   jiffies              <100ac753c>
Mar 17 18:43:38 c862f3sq03 kernel:   next_to_watch.status <0>
--snip--
Mar 17 19:21:15 c862f3sq02 kernel: Unable to handle kernel paging request for data at address 0x00000000
Mar 17 19:21:15 c862f3sq02 kernel: Faulting instruction address: 0xc00000000010776c
Mar 17 19:21:15 c862f3sq02 kernel: Oops: Kernel access of bad area, sig: 11 [#1]
Mar 17 19:21:15 c862f3sq02 kernel: SMP NR_CPUS=1024 NUMA pSeries
Mar 17 19:21:15 c862f3sq02 kernel: Modules linked in: mmfs26(X) mmfslinux(X) tracedev(X) nfs lockd nfs_acl sunrpc dm_round_robin scsi_dh_rdac dm_multipath scsi_dh ipv6 af_packet fuse loop dm_mod lpfc sr_mod cdrom ses scsi_transport_fc sg enclosure e100 e1000 scsi_tgt ib_ehca mii ib_core sd_mod crc_t10dif ipr(X) pata_pdc2027x libata scsi_mod
Mar 17 19:21:15 c862f3sq02 kernel: Supported: Yes, External
Mar 17 19:21:15 c862f3sq02 kernel: NIP: c00000000010776c LR: c000000000107734 CTR: 0000000000000000
Mar 17 19:21:15 c862f3sq02 kernel: REGS: c0000001d0f6b560 TRAP: 0300   Tainted: G        W  (2.6.27.19-5-ppc64)
Mar 17 19:21:15 c862f3sq02 kernel: MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 44000002  XER: 00000010
Mar 17 19:21:15 c862f3sq02 kernel: DAR: 0000000000000000, DSISR: 0000000040000000
Mar 17 19:21:15 c862f3sq02 kernel: TASK = c0000001db8bada0[11171] 'bash' THREAD: c0000001d0f68000 CPU: 2
Mar 17 19:21:15 c862f3sq02 kernel: GPR00: 0000000000000000 c0000001d0f6b7e0 c0000000009cbc80 0000000000000000 
Mar 17 19:21:15 c862f3sq02 kernel: GPR04: c0000001da3c2300 00000000000000d0 0000000000000000 c0000001a7310000 
Mar 17 19:21:15 c862f3sq02 kernel: GPR08: 000000000001a731 00000000000001a7 0000000000000000 0000000000000000 
Mar 17 19:21:15 c862f3sq02 kernel: GPR12: 0000000000000005 c000000000a93080 c000000000094818 0000000000000000 
Mar 17 19:21:15 c862f3sq02 kernel: GPR16: 0000000000000000 0000000000000000 0000000000000000 0000000002000000 
Mar 17 19:21:15 c862f3sq02 kernel: GPR20: 00006b3600000093 c0000001da3c2300 000004000003dfd0 c0000001da55c5b0 
Mar 17 19:21:15 c862f3sq02 kernel: GPR24: c0000001db890000 c0000001a7310018 c000000001f50c50 c000000001fa3600 
Mar 17 19:21:15 c862f3sq02 kernel: GPR28: c0000000020d2c00 0000000000000000 c00000000094b070 00006b3600000093 
Mar 17 19:21:15 c862f3sq02 kernel: NIP [c00000000010776c] .do_wp_page+0x520/0x830
Mar 17 19:21:15 c862f3sq02 kernel: LR [c000000000107734] .do_wp_page+0x4e8/0x830
Mar 17 19:21:15 c862f3sq02 kernel: Call Trace:
Mar 17 19:21:15 c862f3sq02 kernel: [c0000001d0f6b7e0] [c0000000001076f4] .do_wp_page+0x4a8/0x830 (unreliable)
Mar 17 19:21:15 c862f3sq02 kernel: [c0000001d0f6b8b0] [c000000000109be8] .handle_mm_fault+0x36c/0x478
Mar 17 19:21:15 c862f3sq02 kernel: [c0000001d0f6b990] [c000000000518b10] .do_page_fault+0x3c4/0x5c0
Mar 17 19:21:15 c862f3sq02 kernel: [c0000001d0f6bac0] [c00000000000567c] handle_page_fault+0x20/0x5c
Mar 17 19:21:15 c862f3sq02 kernel: --- Exception: 301 at .schedule_tail+0x78/0x94
Mar 17 19:21:15 c862f3sq02 kernel:     LR = .schedule_tail+0x70/0x94
Mar 17 19:21:15 c862f3sq02 kernel: [c0000001d0f6bdb0] [c00000000008bdd8] .schedule_tail+0x2c/0x94 (unreliable)
Mar 17 19:21:15 c862f3sq02 kernel: [c0000001d0f6be30] [c000000000008910] .ret_from_fork+0x4/0x74
Mar 17 19:21:15 c862f3sq02 kernel: Instruction dump:
Mar 17 19:21:15 c862f3sq02 kernel: 409e02c8 e8f80000 3c004000 e97e8008 39400000 780007c6 78e905a4 7d290214 
Mar 17 19:21:15 c862f3sq02 kernel: 7920e120 79288402 78001f24 79294602 <7d6b002a> 2fab0000 419e000c 79202428 
Mar 17 19:21:15 c862f3sq02 kernel: ---[ end trace e6c07b27e638f8ff ]---

