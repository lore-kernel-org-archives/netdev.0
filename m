From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: 2.6.25 crash: EIP: [<c02e2f14>] xfrm_output_resume+0x64/0x100 ss:esp 0068:c03a1e5c
Date: Fri, 9 May 2008 11:50:00 +0200
Message-ID: <BAY103-DAV6446AEC1CBB678E5D0E52B2D30@phx.gbl>
References: <E1Jrtxr-0004in-00@gondolin.me.apana.org.au> <BAY103-DAV594320AC93E33D7335927B2DA0@phx.gbl> <BAY103-DAV122A113843FE9574256A0AB2D60@phx.gbl>
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s31.bay0.hotmail.com ([65.54.246.167]:8515 "EHLO
	bay0-omc2-s31.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752780AbYEIJwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 05:52:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marco Berizzi wrote:

> ok, I can confirm after one week uptime: this problem
> is not happening after removing sch_htb/sch_sfq and
> cls_fw modules.
> What should I do to help track down this problem?

I have rebooted the two boxes with slub_debug.
This is the output taken with network console.
Herbert does it help you?

BUG: unable to handle kernel paging request at 6b6b6b9f
IP: [<c02e3e84>] xfrm_output_resume+0x64/0x100
Oops: 0000 [#1]
Modules linked in: netconsole sch_sfq sch_htb cls_fw nf_nat_pptp
nf_nat_proto_gre nf_conntrack_pptp nf_conntrack_proto_gre nf_nat_ftp
nf_conntrack_ftp 3c59x mii

Pid: 895, comm: squid Not tainted (2.6.25 #1)
EIP: 0060:[<c02e3e84>] EFLAGS: 00010246 CPU: 0
EIP is at xfrm_output_resume+0x64/0x100
EAX: 00000001 EBX: c3f3ed20 ECX: 00000001 EDX: 6b6b6b6b
ESI: 80000000 EDI: c3d9c280 EBP: 0000001c ESP: c91f5bd8
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process squid (pid: 895, ti=c91f4000 task=c918eb00 task.ti=c91f4000)
Stack: 00000001 c039ce60 c3f3ed20 80000000 c3f3ed20 80000000 c02dd147
00000000
       c9c4a0c0 c02dd0d0 80000000 c3f3ed20 c02a6709 c3f3ed20 c02a68e1
c9c4b960
       c9c4a0c0 c02a66f0 80000000 c3f3ed40 00000000 c3f3ed20 c4d446b0
c9c4b960
Call Trace:
 [<c02dd147>] xfrm4_output+0x47/0x90
 [<c02dd0d0>] xfrm4_output_finish+0x0/0x30
 [<c02a6709>] ip_forward_finish+0x19/0x30
 [<c02a68e1>] ip_forward+0x1c1/0x320
 [<c02a66f0>] ip_forward_finish+0x0/0x30
 [<c02a55ab>] ip_rcv_finish+0xeb/0x2b0
 [<c02a54c0>] ip_rcv_finish+0x0/0x2b0
 [<c02a58d7>] ip_rcv+0x167/0x260
 [<c02a54c0>] ip_rcv_finish+0x0/0x2b0
 [<c02804ca>] netif_receive_skb+0x28a/0x360
 [<c0280605>] process_backlog+0x65/0xc0
 [<c02807de>] net_rx_action+0x14e/0x170
 [<c011af04>] __do_softirq+0x74/0x90
 [<c011af46>] do_softirq+0x26/0x30
 [<c011ae12>] local_bh_enable+0x42/0x80
 [<c029a310>] __nf_conntrack_find+0xd0/0xe0
 [<c029a32f>] nf_conntrack_find_get+0xf/0x60
 [<c029ad27>] nf_conntrack_in+0x1b7/0x290
 [<c02990d2>] nf_iterate+0x72/0x90
 [<c02aa500>] dst_output+0x0/0x10
 [<c02aa500>] dst_output+0x0/0x10
 [<c0299156>] nf_hook_slow+0x66/0xe0
 [<c02aa500>] dst_output+0x0/0x10
 [<c02a7c23>] __ip_local_out+0xb3/0xc0
 [<c02aa500>] dst_output+0x0/0x10
 [<c02a7c38>] ip_local_out+0x8/0x20
 [<c02a8649>] ip_queue_xmit+0x2b9/0x370
 [<c0152fd6>] check_bytes_and_report+0x26/0xc0
 [<c02a66f0>] ip_forward_finish+0x0/0x30
 [<c01530d1>] check_pad_bytes+0x61/0x80
 [<c0153280>] check_object+0x80/0x1b0
 [<c02bdd93>] tcp_v4_send_check+0x53/0xf0
 [<c02b9769>] tcp_transmit_skb+0x2b9/0x4b0
 [<c02bbaeb>] tcp_send_fin+0x7b/0xc0
 [<c02bacf1>] tcp_write_xmit+0x151/0x270
 [<c02bae21>] __tcp_push_pending_frames+0x11/0x70
 [<c02b09d7>] tcp_close+0x2a7/0x320
 [<c02ca85e>] inet_release+0x4e/0x60
 [<c0274957>] sock_release+0x67/0x80
 [<c0275261>] sock_close+0x21/0x40
 [<c01599da>] __fput+0x14a/0x160
 [<c01580fa>] filp_close+0x3a/0x70
 [<c0158177>] sys_close+0x47/0x80
 [<c0102d6e>] syscall_call+0x7/0xb
 =======================
Code: 00 00 00 8b 43 70 85 c0 74 05 e8 48 59 f9 ff c7 43 70 00 00 00 00
8b 43 18 8b 50 40 89 d8 ff 52 24 83 f8 01 89 c2 75 3f 8b 53 18 <8b> 42
34 85 c0 74 6a 8b 42 40 8b 4a 0c 0f b7 30 8d 04 f5 04 00
EIP: [<c02e3e84>] xfrm_output_resume+0x64/0x100 SS:ESP 0068:c91f5bd8
Kernel panic - not syncing: Fatal exception in interrupt
Rebooting in 5 seconds..Linux version 2.6.25 (root@Mimosa) (gcc version
3.3.5) #1 Tue Apr 29 19:06:06 CEST 2008


