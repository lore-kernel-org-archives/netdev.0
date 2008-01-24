From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: Re: 2.6.24-rc8-mm1 Badness at net/ipv4/tcp_input.c:2506
Date: Thu, 24 Jan 2008 12:14:19 +0530
Message-ID: <479833C3.6090905@linux.vnet.ibm.com>
References: <20080117023514.9df393cf.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	LKML <linux-kernel@vger.kernel.org>,
	Andy Whitcroft <apw@shadowen.org>,
	Balbir Singh <balbir@linux.vnet.ibm.com>
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from E23SMTP05.au.ibm.com ([202.81.18.174]:34203 "EHLO
	e23smtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159AbYAXGoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 01:44:20 -0500
In-Reply-To: <20080117023514.9df393cf.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The following call trace is seen in the 2.6.24-rc8-mm1 kernel, which is same as one of
the call trace you have given a debug patch at http://marc.info/?l=linux-netdev&m=120107165228368&w=2
i was not able to apply the debug patch, can you kindly rebase the patch for 2.6.24-rc8-mm1 or let
me know, if i can help you in debugging this call trace.


Jan 24 11:13:57 p55lp6 kernel: [60656.708573] Badness at net/ipv4/tcp_input.c:2506
Jan 24 11:13:57 p55lp6 kernel: [60656.708583] NIP: c0000000003776e0 LR: c0000000003776a8 CTR: c0000000003aaf8c
Jan 24 11:13:57 p55lp6 kernel: [60656.708597] REGS: c00000000f6f34a0 TRAP: 0700   Not tainted  (2.6.24-rc8-mm1)
Jan 24 11:13:57 p55lp6 kernel: [60656.708608] MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 24000088  XER: 00000018
Jan 24 11:13:57 p55lp6 kernel: [60656.708636] TASK = c000000000571710[0] 'swapper' THREAD: c000000000670000 CPU: 0
Jan 24 11:13:57 p55lp6 kernel: [60656.708648] GPR00: 00000000fffffffc c00000000f6f3720 c000000000664ab0 0000000000000000
Jan 24 11:13:57 p55lp6 kernel: [60656.708663] GPR04: 0000000000000001 000000000000040e 00000000000000d0 0000000000000000
Jan 24 11:13:57 p55lp6 kernel: [60656.708677] GPR08: 0000000000000000 00000000001bce5f 0000000000000001 fffffffffffffffc
Jan 24 11:13:57 p55lp6 kernel: [60656.708690] GPR12: c00000000f6f34f0 c000000000572180 0000000000000000 0000000000000004
Jan 24 11:13:57 p55lp6 kernel: [60656.708704] GPR16: 0000000000000001 000000003e3133e9 0000000000000402 000000000000011f
Jan 24 11:13:57 p55lp6 kernel: [60656.708718] GPR20: 000000000000011f 0000000000000004 0000000000000002 000000003e3133e9
Jan 24 11:13:57 p55lp6 kernel: [60656.708732] GPR24: c00000004c09fe80 0000000000000000 0000000000000000 000000000000040e
Jan 24 11:13:57 p55lp6 kernel: [60656.708745] GPR28: 0000000000000002 000000000000040e c000000000628570 c0000001791ff8d8
Jan 24 11:13:57 p55lp6 kernel: [60656.708760] NIP [c0000000003776e0] .tcp_fastretrans_alert+0xfc/0xe20
Jan 24 11:13:58 p55lp6 kernel: [60656.708778] LR [c0000000003776a8] .tcp_fastretrans_alert+0xc4/0xe20
Jan 24 11:13:58 p55lp6 kernel: [60656.708792] Call Trace:
Jan 24 11:13:58 p55lp6 kernel: [60656.708799] [c00000000f6f3720] [c000000000628570] 0xc000000000628570 (unreliable)
Jan 24 11:13:58 p55lp6 kernel: [60656.708819] [c00000000f6f37d0] [c00000000037a3b0] .tcp_ack+0xf34/0x10e4
Jan 24 11:13:58 p55lp6 kernel: [60656.708836] [c00000000f6f3920] [c00000000037dce8] .tcp_rcv_established+0x114/0x8a8
Jan 24 11:13:58 p55lp6 kernel: [60656.708854] [c00000000f6f39d0] [c00000000038599c] .tcp_v4_do_rcv+0x5c/0x260
Jan 24 11:13:58 p55lp6 kernel: [60656.708871] [c00000000f6f3a90] [c000000000387c24] .tcp_v4_rcv+0x8a0/0x93c
Jan 24 11:13:58 p55lp6 kernel: [60656.708888] [c00000000f6f3b50] [c000000000363fec] .ip_local_deliver_finish+0x164/0x284
Jan 24 11:13:58 p55lp6 kernel: [60656.709148] [c00000000f6f3be0] [c000000000363df8] .ip_rcv_finish+0x480/0x510
Jan 24 11:13:58 p55lp6 kernel: [60656.709165] [c00000000f6f3ca0] [c000000000332438] .netif_receive_skb+0x564/0x630
Jan 24 11:13:58 p55lp6 kernel: [60656.709184] [c00000000f6f3d70] [d0000000001e2630] .ibmveth_poll+0x238/0x3b4 [ibmveth]
Jan 24 11:13:58 p55lp6 kernel: [60656.709208] [c00000000f6f3e30] [c0000000003354c4] .net_rx_action+0x118/0x2e4
Jan 24 11:13:58 p55lp6 kernel: [60656.709226] [c00000000f6f3ef0] [c00000000007ca30] .__do_softirq+0xa8/0x164
Jan 24 11:13:58 p55lp6 kernel: [60656.709244] [c00000000f6f3f90] [c00000000002b7f8] .call_do_softirq+0x14/0x24
Jan 24 11:13:58 p55lp6 kernel: [60656.709262] [c000000000673920] [c00000000000bf74] .do_softirq+0x74/0xc0
Jan 24 11:13:58 p55lp6 kernel: [60656.709280] [c0000000006739b0] [c00000000007cb84] .irq_exit+0x54/0x6c
Jan 24 11:13:58 p55lp6 kernel: [60656.709297] [c000000000673a30] [c00000000000c954] .do_IRQ+0x1b8/0x200
Jan 24 11:13:58 p55lp6 kernel: [60656.709314] [c000000000673ae0] [c000000000004c18] hardware_interrupt_entry+0x18/0x1c
Jan 24 11:13:58 p55lp6 kernel: [60656.709332] --- Exception: 501 at .local_irq_restore+0x3c/0x40
Jan 24 11:13:58 p55lp6 kernel: [60656.709349]     LR = .cpu_idle+0x13c/0x240
Jan 24 11:13:58 p55lp6 kernel: [60656.709357] [c000000000673dd0] [c0000000000123c8] .cpu_idle+0x130/0x240 (unreliable)
Jan 24 11:13:58 p55lp6 kernel: [60656.709377] [c000000000673e60] [c000000000009718] .rest_init+0x78/0x90
Jan 24 11:13:58 p55lp6 kernel: [60656.709394] [c000000000673ee0] [c0000000004d09dc] .start_kernel+0x3e8/0x40c
Jan 24 11:13:58 p55lp6 kernel: [60656.709412] [c000000000673f90] [c000000000008580] .start_here_common+0x54/0xd4
Jan 24 11:13:58 p55lp6 kernel: [60656.709429] Instruction dump:
Jan 24 11:13:58 p55lp6 kernel: [60656.709437] 419e0010 38000000 901f06ac 48000010 801f06ac 2f800000 409e0014 801f06b0
Jan 24 11:13:58 p55lp6 kernel: [60656.709464] 38800001 2f800000 409e0008 38800000 <0b040000> e87e80b0 4be81355 60000000

(gdb) p tcp_fastretrans_alert
$1 = {void (struct sock *, int, int)} 0x1ec0 <tcp_fastretrans_alert>
(gdb) p/x 0x1ec0+0xc4
$2 = 0x1f84
(gdb) l *0x1f84
0x1f84 is in tcp_fastretrans_alert (net/ipv4/tcp_input.c:2504).
2499            int is_dupack = !(flag & (FLAG_SND_UNA_ADVANCED | FLAG_NOT_DUP));
2500            int do_lost = is_dupack || ((flag & FLAG_DATA_SACKED) &&
2501                                        (tcp_fackets_out(tp) > tp->reordering));
2502            int fast_rexmit = 0;
2503
2504            if (WARN_ON(!tp->packets_out && tp->sacked_out))
2505                    tp->sacked_out = 0;
2506            if (WARN_ON(!tp->sacked_out && tp->fackets_out))
2507                    tp->fackets_out = 0;
2508


-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.
