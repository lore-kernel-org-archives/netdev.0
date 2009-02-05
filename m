From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: Tracing ESP packets with tcpdump
Date: Thu, 5 Feb 2009 11:46:41 +0100
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD13C73F1A@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:38577 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751695AbZBEKxQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 05:53:16 -0500
Received: from exch.facton.local (exch [192.168.200.5])
	by alpha.facton.com (8.13.8/8.13.8/FACTON) with ESMTP id n15Akges019913
	for <netdev@vger.kernel.org>; Thu, 5 Feb 2009 11:46:42 +0100
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Whenever I did that in <2.6.28 I already got invalid truesize messages
(see older post).
Since 2.6.28 things became even worse:

WARNING: at net/core/skbuff.c:154 sock_rfree+0x64/0x70()
SKB BUG: Invalid truesize (344) len=166, sizeof(sk_buff)=216
Modules linked in: ipt_MASQUERADE iptable_nat nf_nat
Pid: 12688, comm: tcpdump Not tainted 2.6.28.3 #7
Call Trace:
[<ffffffff80235d7d>] warn_slowpath+0xcd/0x110
[<ffffffff8023279f>] dequeue_task_fair+0x5f/0x100
[<ffffffff804c8fa0>] thread_return+0x41/0x4f1
[<ffffffff8029761c>] poll_freewait+0x2c/0x90
[<ffffffff804c9635>] schedule_timeout+0x95/0xd0
[<ffffffff8022cda1>] update_curr+0x51/0xb0
[<ffffffff804415d0>] __skb_recv_datagram+0x1f0/0x280
[<ffffffff8032beed>] __ratelimit+0xbd/0xe0
[<ffffffff8043b094>] sock_rfree+0x64/0x70
[<ffffffff8043e88a>] skb_release_head_state+0x4a/0xb0
[<ffffffff8043f0c9>] skb_release_all+0x9/0x20
[<ffffffff8043e759>] __kfree_skb+0x9/0x80
[<ffffffff8044179c>] skb_free_datagram+0xc/0x40
[<ffffffff804b5274>] packet_recvmsg+0x1b4/0x1e0
[<ffffffff80437de5>] sock_recvmsg+0xd5/0x100
[<ffffffff803750ef>] n_tty_receive_buf+0x2bf/0xf30
[<ffffffff8024a480>] autoremove_wake_function+0x0/0x30
[<ffffffff802642e4>] filemap_fault+0x2a4/0x3e0
[<ffffffff8024a679>] remove_wait_queue+0x19/0x60
[<ffffffff804375e1>] sockfd_lookup_light+0x41/0x80
[<ffffffff80439012>] sys_recvfrom+0xe2/0x180
[<ffffffff80220159>] hpet_rtc_interrupt+0xe9/0x350
[<ffffffff804c8fa0>] thread_return+0x41/0x4f1
[<ffffffff8020b58b>] system_call_fastpath+0x16/0x1b
---[ end trace 380124e699f33636 ]---

Daniel
