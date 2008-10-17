From: "Liqiang Yang" <yliqiang@gmail.com>
Subject: About tcp header misalignment
Date: Fri, 17 Oct 2008 13:49:29 +0800
Message-ID: <127841bd0810162249s54a31c4et12430c48694d5a6d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.189]:11575 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbYJQFtc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 01:49:32 -0400
Received: by fk-out-0910.google.com with SMTP id 18so361237fkq.5
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2008 22:49:30 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,All

We runing linux-2.6.14 on a MIPS like platform,
When running a bittorrent client, there is a misalignment in tcp
header occurs randomly.
Now, we know that it caused by line 319 of net/ipv4/tcp_output.c.

       th = (struct tcphdr *) skb_push(skb, tcp_header_size);
       skb->h.th = th;
       skb_set_owner_w(skb, sk);
       /* Build TCP header and checksum it. */
       th->source = inet->sport;(Line 319 of tcp_output.c)

th: 82ffa881

Call Trace:
 [<80373acc>] tcp_transmit_skb+0xcc0/0xd10
 [<80373ad8>] tcp_transmit_skb+0xccc/0xd10
 [<80374ab4>] tcp_retransmit_skb+0x178/0x8f4
 [<80374aa0>] tcp_retransmit_skb+0x164/0x8f4
 [<8035502c>] ip_rcv+0x4d0/0x704
 [<803778f8>] tcp_write_timer+0x37c/0x8e0
 [<80377a70>] tcp_write_timer+0x4f4/0x8e0
 [<80039a40>] update_process_times+0x90/0x1bc
 [<8037757c>] tcp_write_timer+0x0/0x8e0
 [<80039ccc>] run_timer_softirq+0x160/0x2b4
 [<80008c0c>] timer_interrupt+0x13c/0x2ac
 [<80008c0c>] timer_interrupt+0x13c/0x2ac
 [<80033a80>] __do_softirq+0xa8/0x14c
 [<80033bcc>] do_softirq+0xa8/0xb0
 [<80003888>] do_IRQ+0x34/0x4c
 [<800016cc>] c2IRQ+0x10c/0x1a0
 [<80003b10>] cpu_idle+0x30/0x3c
 [<80003afc>] cpu_idle+0x1c/0x3c
 [<805386d4>] start_kernel+0x268/0x28c
 [<805386cc>] start_kernel+0x260/0x28c
 [<805386a0>] start_kernel+0x234/0x28c
 [<80000800>] kernel_entry_jump+0x0/0x20

Could you give me some advices how to fix the problems.
Thanks.
