From: Petr Vandrovec <vandrove@vc.cvut.cz>
Subject: IPV6 possible recursive locking
Date: Fri, 04 Aug 2006 22:31:48 +0200
Message-ID: <44D3AEB4.6030003@vc.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw.cvut.cz ([147.32.3.235]:31953 "EHLO mailgw.cvut.cz")
	by vger.kernel.org with ESMTP id S932626AbWHDUbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 16:31:50 -0400
Received: from mailgw (localhost [127.0.0.1])
	by mailgw.cvut.cz (Postfix) with SMTP id 8ACF813BC8F
	for <netdev@vger.kernel.org>; Fri,  4 Aug 2006 22:31:49 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
	by mailgw.cvut.cz (Postfix) with ESMTP id 6744E13BC74
	for <netdev@vger.kernel.org>; Fri,  4 Aug 2006 22:31:49 +0200 (CEST)
Received: from mailgw.cvut.cz ([127.0.0.1])
	by localhost (mailgw [127.0.0.1]) (amavisd-new, port 10024) with LMTP
	id 14553-01-38 for <netdev@vger.kernel.org>;
	Fri, 4 Aug 2006 22:31:49 +0200 (CEST)
Received: from [127.0.0.1] (buk.vc.cvut.cz [147.32.240.88])
	by mailgw.cvut.cz (Postfix) with ESMTP id 3710E13B71D
	for <netdev@vger.kernel.org>; Fri,  4 Aug 2006 22:31:49 +0200 (CEST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
   I'm not sure whether this was reported already, but just in case...

Box has only link scope IPv6 addresses assigned.  java_vm was running some webex 
conferencing applet.
						Thanks,
							Petr Vandrovec


Linux version 2.6.18-rc3-efe7 (root@ppc) (gcc version 4.1.2 20060729 
(prerelease) (Debian 4.1.1-10)) #2 SMP PREEMPT Fri Aug 4 16:55:30 CEST 2006

=============================================
[ INFO: possible recursive locking detected ]
---------------------------------------------
java_vm/7892 is trying to acquire lock:
  (slock-AF_INET6){-+..}, at: [<ffffffff812a6ac4>] sk_clone+0xd4/0x350

but task is already holding lock:
  (slock-AF_INET6){-+..}, at: [<ffffffff8136fd53>] tcp_v6_rcv+0x323/0x850

other info that might help us debug this:
1 lock held by java_vm/7892:
  #0:  (slock-AF_INET6){-+..}, at: [<ffffffff8136fd53>] tcp_v6_rcv+0x323/0x850

stack backtrace:

Call Trace:
  [<ffffffff8107be05>] show_trace+0xb5/0x3a0
  [<ffffffff8107c105>] dump_stack+0x15/0x20
  [<ffffffff810ba9b2>] __lock_acquire+0x912/0xce0
  [<ffffffff810badcf>] lock_acquire+0x4f/0x70
  [<ffffffff8107400f>] _spin_lock+0x2f/0x40
  [<ffffffff812a6ac4>] sk_clone+0xd4/0x350
  [<ffffffff812f6fb1>] inet_csk_clone+0x11/0x70
  [<ffffffff81300b94>] tcp_create_openreq_child+0x24/0x480
  [<ffffffff8136e7c2>] tcp_v6_syn_recv_sock+0x2c2/0x6f0
  [<ffffffff81301219>] tcp_check_req+0x229/0x3a0
  [<ffffffff8136d7bd>] tcp_v6_do_rcv+0x17d/0x400
  [<ffffffff81370215>] tcp_v6_rcv+0x7e5/0x850
  [<ffffffff8134ff89>] ip6_input+0x259/0x3b0
  [<ffffffff8135076c>] ipv6_rcv+0x28c/0x2f0
  [<ffffffff8102394e>] netif_receive_skb+0x28e/0x370
  [<ffffffff81036e5f>] process_backlog+0xaf/0x150
  [<ffffffff8100ce50>] net_rx_action+0xd0/0x2a0
  [<ffffffff8101320c>] __do_softirq+0x7c/0x110
  [<ffffffff8106d9a8>] call_softirq+0x1c/0x28
  [<ffffffff8107d2dd>] do_softirq+0x3d/0xc0
  [<ffffffff810a60a2>] local_bh_enable_ip+0xc2/0x110
  [<ffffffff81073f89>] _spin_unlock_bh+0x39/0x40
  [<ffffffff8103773f>] release_sock+0xcf/0xe0
  [<ffffffff81068dba>] inet_stream_connect+0x17a/0x2d0
  [<ffffffff812a4297>] sys_connect+0x87/0xc0
  [<ffffffff812bb94d>] compat_sys_socketcall+0x8d/0x1b0
  [<ffffffff8106f7a0>] cstar_do_call+0x1b/0x6f
  [<00000000ffffe405>]
  <IRQ> [<ffffffff810ba9b2>] __lock_acquire+0x912/0xce0
  [<ffffffff810b9b1d>] mark_held_locks+0x5d/0x90
  [<ffffffff810badcf>] lock_acquire+0x4f/0x70
  [<ffffffff812a6ac4>] sk_clone+0xd4/0x350
  [<ffffffff8107400f>] _spin_lock+0x2f/0x40
  [<ffffffff812a6ac4>] sk_clone+0xd4/0x350
  [<ffffffff812f6fb1>] inet_csk_clone+0x11/0x70
  [<ffffffff81300b94>] tcp_create_openreq_child+0x24/0x480
  [<ffffffff8136e7c2>] tcp_v6_syn_recv_sock+0x2c2/0x6f0
  [<ffffffff81301219>] tcp_check_req+0x229/0x3a0
  [<ffffffff8136d7bd>] tcp_v6_do_rcv+0x17d/0x400
  [<ffffffff81370215>] tcp_v6_rcv+0x7e5/0x850
  [<ffffffff8134ff89>] ip6_input+0x259/0x3b0
  [<ffffffff8135076c>] ipv6_rcv+0x28c/0x2f0
  [<ffffffff8102394e>] netif_receive_skb+0x28e/0x370
  [<ffffffff81036e51>] process_backlog+0xa1/0x150
  [<ffffffff81036e5f>] process_backlog+0xaf/0x150
  [<ffffffff8100ce50>] net_rx_action+0xd0/0x2a0
  [<ffffffff8101320c>] __do_softirq+0x7c/0x110
  [<ffffffff8103773f>] release_sock+0xcf/0xe0
  [<ffffffff8106d9a8>] call_softirq+0x1c/0x28
  <EOI> [<ffffffff8107d2dd>] do_softirq+0x3d/0xc0
  [<ffffffff810a60a2>] local_bh_enable_ip+0xc2/0x110
  [<ffffffff81073f89>] _spin_unlock_bh+0x39/0x40
  [<ffffffff8103773f>] release_sock+0xcf/0xe0
  [<ffffffff81068dba>] inet_stream_connect+0x17a/0x2d0
  [<ffffffff810b4c10>] autoremove_wake_function+0x0/0x40
  [<ffffffff812a4297>] sys_connect+0x87/0xc0
  [<ffffffff8105944f>] sock_map_fd+0x5f/0x70
  [<ffffffff81073a7f>] trace_hardirqs_on_thunk+0x35/0x37
  [<ffffffff812bb94d>] compat_sys_socketcall+0x8d/0x1b0
  [<ffffffff8106f7a0>] cstar_do_call+0x1b/0x6f


