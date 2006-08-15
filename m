From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 7009] New: possible recursive locking detected
Date: Tue, 15 Aug 2006 09:51:51 -0700
Message-ID: <20060815095151.88d2e16c.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:2725 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750813AbWHOQvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 12:51:53 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k7FGppnW001283
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 15 Aug 2006 09:51:52 -0700
Received: from akpm.corp.google.com (shell0.pdx.osdl.net [10.9.0.31])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with SMTP id k7FGppIC030048
	for <netdev@vger.kernel.org>; Tue, 15 Aug 2006 09:51:51 -0700
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Tue, 15 Aug 2006 09:43:51 -0700
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 7009] New: possible recursive locking detected


http://bugzilla.kernel.org/show_bug.cgi?id=7009

           Summary: possible recursive locking detected
    Kernel Version: 2.6.18-rc4
            Status: NEW
          Severity: low
             Owner: yoshfuji@linux-ipv6.org
         Submitter: lpiccilli@gelre.com.br


Distribution: Centos 4.3 x84_64

=============================================
[ INFO: possible recursive locking detected ]
---------------------------------------------
java/3069 is trying to acquire lock:
 (slock-AF_INET6){-+..}, at: [<ffffffff804aa9df>] sk_clone+0xcc/0x341

but task is already holding lock:
 (slock-AF_INET6){-+..}, at: [<ffffffff88169f10>] tcp_v6_rcv+0x2e9/0x799 [ipv6]

other info that might help us debug this:
1 lock held by java/3069:
 #0:  (slock-AF_INET6){-+..}, at: [<ffffffff88169f10>] tcp_v6_rcv+0x2e9/0x799 
[ipv6]

stack backtrace:

Call Trace:
 <IRQ> [<ffffffff8029e931>] __lock_acquire+0x8f1/0xd20
 [<ffffffff8029f405>] debug_check_no_locks_freed+0x115/0x14e
 [<ffffffff8029f405>] debug_check_no_locks_freed+0x115/0x14e
 [<ffffffff8029f060>] lock_acquire+0x50/0x6c
 [<ffffffff804aa9df>] sk_clone+0xcc/0x341
 [<ffffffff802693ae>] _spin_lock+0x25/0x34
 [<ffffffff804aa9df>] sk_clone+0xcc/0x341
 [<ffffffff804d6029>] inet_csk_clone+0x11/0x6f
 [<ffffffff804e0182>] tcp_create_openreq_child+0x24/0x482
 [<ffffffff88168e01>] :ipv6:tcp_v6_syn_recv_sock+0x2b7/0x6cb
 [<ffffffff804e07f0>] tcp_check_req+0x210/0x380
 [<ffffffff8816890d>] :ipv6:tcp_v6_do_rcv+0x155/0x392
 [<ffffffff8816a35f>] :ipv6:tcp_v6_rcv+0x738/0x799
 [<ffffffff8814bc47>] :ipv6:ip6_input+0x21b/0x31e
 [<ffffffff8814b9cf>] :ipv6:ipv6_rcv+0x292/0x2ef
 [<ffffffff80232d76>] process_backlog+0x12b/0x145
 [<ffffffff802211c1>] netif_receive_skb+0x3a1/0x3c3
 [<ffffffff80232cf5>] process_backlog+0xaa/0x145
 [<ffffffff80297034>] rcu_process_callbacks+0x42/0x44
 [<ffffffff8020c7ff>] net_rx_action+0xc5/0x206
 [<ffffffff80212344>] __do_softirq+0x7c/0x108
 [<ffffffff8023351d>] release_sock+0xcd/0xd6
 [<ffffffff802649a8>] call_softirq+0x1c/0x28
 <EOI> [<ffffffff8026f889>] do_softirq+0x39/0xa3
 [<ffffffff8028c3c5>] local_bh_enable_ip+0xc5/0xf1
 [<ffffffff802695c1>] _spin_unlock_bh+0x2f/0x36
 [<ffffffff8023351d>] release_sock+0xcd/0xd6
 [<ffffffff8025edbf>] inet_stream_connect+0x17f/0x293
 [<ffffffff802992ea>] autoremove_wake_function+0x0/0x46
 [<ffffffff804a7a99>] sys_connect+0x68/0x91
 [<ffffffff80268f34>] trace_hardirqs_on_thunk+0x35/0x37
 [<ffffffff8029f2be>] trace_hardirqs_on+0x109/0x13b
 [<ffffffff80268f34>] trace_hardirqs_on_thunk+0x35/0x37
 [<ffffffff802636fe>] system_call+0x7e/0x83

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
