From: Andrew Morton <akpm@linux-foundation.org>
Subject: git-net, git-netdev-all and everything else on g5
Date: Thu, 28 Jun 2007 02:13:38 -0700
Message-ID: <20070628021338.0d37f95a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46252 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760140AbXF1JNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 05:13:46 -0400
Received: from imap1.linux-foundation.org (imap1.linux-foundation.org [207.189.120.55])
	by smtp2.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with ESMTP id l5S9Dh8a006149
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 28 Jun 2007 02:13:44 -0700
Received: from box (localhost [127.0.0.1])
	by imap1.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with SMTP id l5S9DcWg022092
	for <netdev@vger.kernel.org>; Thu, 28 Jun 2007 02:13:38 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


With the full -mm lineup, my tg3-using powerpc g5 spits lots of these:

windfarm: Drive bay control loop started.
audit(1183017094.732:2): audit_pid=2117 old=0 by auid=4294967295
------------[ cut here ]------------
Badness at net/core/dev.c:1303
Call Trace:
[c00000000b45ead0] [c0000000000108c8] .show_stack+0x50/0x1cc (unreliable)
[c00000000b45eb80] [c0000000001b563c] .report_bug+0xa0/0x110
[c00000000b45ec10] [c0000000000250a0] .program_check_exception+0x1fc/0x738
[c00000000b45ecd0] [c000000000004a84] program_check_common+0x104/0x180
--- Exception: 700 at .skb_gso_segment+0xd0/0x298
    LR = .dev_hard_start_xmit+0x23c/0x33c
[c00000000b45efc0] [0000000000000001] 0x1 (unreliable)
[c00000000b45f060] [c00000000037bc2c] .dev_hard_start_xmit+0x23c/0x33c
[c00000000b45f100] [c000000000394934] .__qdisc_run+0x8c/0x410
[c00000000b45f1b0] [c00000000037c0f4] .dev_queue_xmit+0x3c8/0x408
[c00000000b45f240] [c0000000003a7180] .ip_output+0x1d8/0x3d4
[c00000000b45f300] [c0000000003a63f0] .ip_queue_xmit+0x374/0x51c
[c00000000b45f450] [c0000000003bdcc0] .tcp_transmit_skb+0x54c/0x9dc
[c00000000b45f560] [c0000000003bf8f8] .__tcp_push_pending_frames+0x2fc/0xb58
[c00000000b45f6a0] [c0000000003bbccc] .tcp_rcv_established+0x204/0x900
[c00000000b45f750] [c0000000003c6080] .tcp_v4_do_rcv+0x230/0x598
[c00000000b45f830] [c0000000003b1200] .tcp_prequeue_process+0xa0/0xf4
[c00000000b45f8c0] [c0000000003b19c8] .tcp_recvmsg+0x4f0/0x940
[c00000000b45f9b0] [c000000000370fa0] .sock_common_recvmsg+0x68/0x90
[c00000000b45fa40] [c00000000036b2cc] .sock_aio_read+0x120/0x148
[c00000000b45fb50] [c0000000000d029c] .do_sync_read+0xd0/0x160
[c00000000b45fcf0] [c0000000000d04ec] .vfs_read+0x1c0/0x1d8
[c00000000b45fd90] [c0000000000d0888] .sys_read+0x4c/0x90
[c00000000b45fe30] [c00000000000872c] syscall_exit+0x0/0x40
------------[ cut here ]------------
Badness at net/core/dev.c:1303
Call Trace:
[c00000000b45e9c0] [c0000000000108c8] .show_stack+0x50/0x1cc (unreliable)
[c00000000b45ea70] [c0000000001b563c] .report_bug+0xa0/0x110
[c00000000b45eb00] [c0000000000250a0] .program_check_exception+0x1fc/0x738
[c00000000b45ebc0] [c000000000004a84] program_check_common+0x104/0x180
--- Exception: 700 at .skb_gso_segment+0xd0/0x298
    LR = .dev_hard_start_xmit+0x23c/0x33c
[c00000000b45eeb0] [c000000000079a60] .__wake_up_bit+0x4c/0x60 (unreliable)
[c00000000b45ef50] [c00000000037bc2c] .dev_hard_start_xmit+0x23c/0x33c
[c00000000b45eff0] [c000000000394934] .__qdisc_run+0x8c/0x410
[c00000000b45f0a0] [c00000000037c0f4] .dev_queue_xmit+0x3c8/0x408
[c00000000b45f130] [c0000000003a7180] .ip_output+0x1d8/0x3d4
[c00000000b45f1f0] [c0000000003a63f0] .ip_queue_xmit+0x374/0x51c
[c00000000b45f340] [c0000000003bdcc0] .tcp_transmit_skb+0x54c/0x9dc
[c00000000b45f450] [c0000000003bf8f8] .__tcp_push_pending_frames+0x2fc/0xb58
[c00000000b45f590] [c0000000003bbccc] .tcp_rcv_established+0x204/0x900
[c00000000b45f640] [c0000000003c6080] .tcp_v4_do_rcv+0x230/0x598
[c00000000b45f720] [c00000000036fb8c] .release_sock+0xa0/0x16c
[c00000000b45f7c0] [c00000000036fd08] .sk_wait_data+0xb0/0x148
[c00000000b45f8c0] [c0000000003b1a6c] .tcp_recvmsg+0x594/0x940
[c00000000b45f9b0] [c000000000370fa0] .sock_common_recvmsg+0x68/0x90
[c00000000b45fa40] [c00000000036b2cc] .sock_aio_read+0x120/0x148
[c00000000b45fb50] [c0000000000d029c] .do_sync_read+0xd0/0x160
[c00000000b45fcf0] [c0000000000d04ec] .vfs_read+0x1c0/0x1d8
[c00000000b45fd90] [c0000000000d0888] .sys_read+0x4c/0x90
[c00000000b45fe30] [c00000000000872c] syscall_exit+0x0/0x40

That's here, in skb_gso_segment():

        skb_reset_mac_header(skb);
        skb->mac_len = skb->network_header - skb->mac_header;
        __skb_pull(skb, skb->mac_len);

->        if (WARN_ON(skb->ip_summed != CHECKSUM_PARTIAL)) {


config: http://userweb.kernel.org/~akpm/config-g5.txt
dmesg: http://userweb.kernel.org/~akpm/dmesg-g5.txt

Note that that dmesg contains extra stuff at the end which looks like the
box is trying to oops.

Generally ugly.
