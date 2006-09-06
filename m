From: Matthew Galgoci <mgalgoci@redhat.com>
Subject: ipv6 lockdep
Date: Wed, 6 Sep 2006 11:06:12 -0400
Message-ID: <Pine.LNX.4.64.0609061059200.10137@acis.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40914 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751322AbWIFPGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 11:06:13 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id k86F6CSJ025197
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 11:06:12 -0400
Received: from acis.rdu.redhat.com (acis.rdu.redhat.com [10.11.255.3])
	by int-mx1.corp.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id k86F6CNd009925
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 11:06:12 -0400
Received: from acis.rdu.redhat.com (localhost.localdomain [127.0.0.1])
	by acis.rdu.redhat.com (8.13.1/8.13.1) with ESMTP id k86F6CQR022110
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 11:06:12 -0400
Received: from localhost (mgalgoci@localhost)
	by acis.rdu.redhat.com (8.13.1/8.13.1/Submit) with ESMTP id k86F6Cp2022104
	for <netdev@vger.kernel.org>; Wed, 6 Sep 2006 11:06:12 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I don't know if this is a previously known lockdep spew for
a 2.6.18-rc6 based fedora kernel. DaveJ suggested I send this
to netdev for wider review.

=============================================
[ INFO: possible recursive locking detected ]
2.6.17-1.2614.fc6 #1
---------------------------------------------
java/7112 is trying to acquire lock:
 (slock-AF_INET6){-+..}, at: [<c05b34de>] sk_clone+0xd4/0x2d8
but task is already holding lock:
 (slock-AF_INET6){-+..}, at: [<e0ce94c9>] tcp_v6_rcv+0x327/0x736 [ipv6]
other info that might help us debug this:
1 lock held by java/7112:
 #0:  (slock-AF_INET6){-+..}, at: [<e0ce94c9>] tcp_v6_rcv+0x327/0x736 [ipv6]
stack backtrace:
 [<c04051ee>] show_trace_log_lvl+0x58/0x171
 [<c0405802>] show_trace+0xd/0x10
 [<c040591b>] dump_stack+0x19/0x1b
 [<c043b929>] __lock_acquire+0x778/0x99c
 [<c043c0be>] lock_acquire+0x4b/0x6d
 [<c0613f53>] _spin_lock+0x19/0x28
 [<c05b34de>] sk_clone+0xd4/0x2d8
 [<c05db03f>] inet_csk_clone+0xf/0x72
 [<c05ebe7d>] tcp_create_openreq_child+0x1b/0x3a1
 [<e0ce8155>] tcp_v6_syn_recv_sock+0x271/0x5b3 [ipv6]
 [<c05ec3d8>] tcp_check_req+0x1d5/0x2e9
 [<e0ce7441>] tcp_v6_do_rcv+0x142/0x340 [ipv6]
 [<e0ce9883>] tcp_v6_rcv+0x6e1/0x736 [ipv6]
 [<e0ccfa6f>] ip6_input+0x1c3/0x296 [ipv6]
 [<e0ccffdf>] ipv6_rcv+0x1d2/0x21f [ipv6]
 [<c05b9548>] netif_receive_skb+0x205/0x274
 [<c05baeac>] process_backlog+0x99/0xfa
 [<c05bb08f>] net_rx_action+0x9d/0x196
 [<c04293cb>] __do_softirq+0x78/0xf2
 [<c040668b>] do_softirq+0x5a/0xbe
 [<c04291c2>] local_bh_enable_ip+0xa9/0xcf
 [<c0613ef1>] _spin_unlock_bh+0x25/0x28
 [<c05b22df>] release_sock+0xb0/0xb8
 [<c05f40f6>] inet_stream_connect+0x113/0x206
 [<c05b1242>] sys_connect+0x67/0x84
 [<c05b18b4>] sys_socketcall+0x8c/0x186
 [<c0403faf>] syscall_call+0x7/0xb
DWARF2 unwinder stuck at syscall_call+0x7/0xb
Leftover inexact backtrace:

[no leftovers printed]

-- 
Matthew Galgoci
IS Production Operations
Red Hat, Inc
919.754.3700 x44155
