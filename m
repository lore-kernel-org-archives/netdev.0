From: Blaschka <frank.blaschka@de.ibm.com>
Subject: Oops in Unix sockets code
Date: Thu, 19 Nov 2009 14:20:28 +0100
Message-ID: <20091119132028.GA22427@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.17.165]:54354 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261AbZKSNUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 08:20:23 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

running disk tests on s390x (kernel 2.6.31) we get following Oops in Unix domain
socket code (hald process). Can somebody help? We do get this Oops from time to
time so we are willing to test a patch or provide additional debug data if
required.

Thanks,
  Frank

    <1>Unable to handle kernel pointer dereference at virtual kernel address 000000007575e000
    <4>Oops: 0011 [#1] PREEMPT SMP DEBUG_PAGEALLOC
    <4>Modules linked in: sunrpc qeth_l3 dm_multipath dm_mod qeth ccwgroup chsc_sch
    <4>CPU: 0 Not tainted 2.6.31-39.x.20091102-s390xdefault #1
    <4>Process hald (pid: 2117, task: 000000007d200c40, ksp: 000000007ab33880)
    <4>Krnl PSW : 0704100180000000 00000000003a15f8 (_raw_read_trylock+0x0/0x28)
    <4>           R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:0 CC:1 PM:0 EA:3
    <4>Krnl GPRS: 16c8a00000000000 000000007d200c40 000000007575ed18 0000000000000003
    <4>           00000000005853d2 000000007d201470 0000000000000002 000000007ab33c30
    <4>           0000000075746c78 000000007a74da48 000000000051a16a 000000007575ed18
    <4>           000000007575ed30 00000000005da190 00000000005853dc 000000007ab338c8
    <4>Krnl Code: 00000000003a15e8: c03000185811        larl    %r3,6ac60a
    <4>           00000000003a15ee: c0e5fffffdd9        brasl   %r14,3a11a0
    <4>           00000000003a15f4: a7f4ffce            brc     15,3a1590
    <4>          >00000000003a15f8: 58302000            l       %r3,0(%r2)
    <4>           00000000003a15fc: b9170033            llgtr   %r3,%r3
    <4>           00000000003a1600: 1853                lr      %r5,%r3
    <4>           00000000003a1602: 1813                lr      %r1,%r3
    <4>           00000000003a1604: a75a0001            ahi     %r5,1
    <4>Call Trace:
    <4>([<00000000005853d2>] _read_lock+0x5a/0x98)
    <4> [<000000000051a16a>] unix_write_space+0x36/0xb0
    <4> [<00000000004788a8>] sock_wfree+0x80/0x84
    <4> [<000000000047dc08>] skb_release_head_state+0x88/0x140
    <4> [<000000000047d7ec>] __kfree_skb+0x28/0x10c
    <4> [<0000000000481d7e>] skb_free_datagram+0x32/0x6c
    <4> [<0000000000517a46>] unix_dgram_recvmsg+0x246/0x38c
    <4> [<0000000000474036>] sock_recvmsg+0xe2/0x118
    <4> [<00000000004754f8>] SyS_recvmsg+0x134/0x310
    <4> [<0000000000472f14>] SyS_socketcall+0xfc/0x31c
    <4> [<0000000000117f9e>] sysc_noemu+0x10/0x16
    <4> [<0000004f131a95ae>] 0x4f131a95ae
    <4>INFO: lockdep is turned off.
    <4>Last Breaking-Event-Address:
    <4> [<00000000005853d6>] _read_lock+0x5e/0x98
    <4>
    <0>Kernel panic - not syncing: Fatal exception: panic_on_oops
    <4>CPU: 0 Tainted: G      D    2.6.31-39.x.20091102-s390xdefault #1
    <4>Process hald (pid: 2117, task: 000000007d200c40, ksp: 000000007ab33880)
    <4>0000000000000000 000000007ab33588 0000000000000002 0000000000000000
    <4>       000000007ab33628 000000007ab335a0 000000007ab335a0 00000000005801b8
    <4>       0000000000000001 0000000000000000 000000007ab33c30 0000000000000000
    <4>       000000000000000d 0000000000000000 000000007ab335f8 000000000000000e
    <4>       000000000058fc18 0000000000105700 000000007ab33588 000000007ab335d0
    <4>Call Trace:
    <4>([<00000000001055fc>] show_trace+0xf0/0x148)
    <4> [<0000000000580022>] panic+0xa2/0x1e4
    <4> [<0000000000105bf8>] die+0x14c/0x168
    <4> [<00000000001012d8>] do_no_context+0xa8/0xe8
    <4> [<000000000058597c>] do_dat_exception+0x134/0x338
    <4> [<0000000000117fa4>] sysc_return+0x0/0x8
    <4> [<00000000003a15f8>] _raw_read_trylock+0x0/0x28
    <4>([<00000000005853d2>] _read_lock+0x5a/0x98)
    <4> [<000000000051a16a>] unix_write_space+0x36/0xb0
    <4> [<00000000004788a8>] sock_wfree+0x80/0x84
    <4> [<000000000047dc08>] skb_release_head_state+0x88/0x140
    <4> [<000000000047d7ec>] __kfree_skb+0x28/0x10c
    <4> [<0000000000481d7e>] skb_free_datagram+0x32/0x6c
    <4> [<0000000000517a46>] unix_dgram_recvmsg+0x246/0x38c
    <4> [<0000000000474036>] sock_recvmsg+0xe2/0x118
    <4> [<00000000004754f8>] SyS_recvmsg+0x134/0x310
    <4> [<0000000000472f14>] SyS_socketcall+0xfc/0x31c
    <4> [<0000000000117f9e>] sysc_noemu+0x10/0x16
    <4> [<0000004f131a95ae>] 0x4f131a95ae
    <4>INFO: lockdep is turned off.

