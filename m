From: Tim Hartrick <tim@edgecast.com>
Subject: crash in tcp_fragment
Date: Sun, 26 Feb 2012 19:57:45 -0700
Message-ID: <1330311465.2552.23.camel@boudreau>
Reply-To: tim@edgecast.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:38079 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753831Ab2B0C5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2012 21:57:38 -0500
Received: by iazz13 with SMTP id z13so2694553iaz.19
        for <netdev@vger.kernel.org>; Sun, 26 Feb 2012 18:57:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Netdev,

	We have been seeing the crash cited below on a number of our systems
running kernel version 2.6.34, 2.6.36 and 2.6.38 using a number of
different GigE controllers.  I note that commit
2fceec13375e5d98ef033c6b0ee03943fc460950 introduced a band-aid for the
problem by replacing the BUG_ON() to a WARN().  I have two questions
related to this.

1) Is there a fix for the root cause?  Can I get a pointer to the commit
that claims to address the root cause?

2) Will disabling GSO/TSO make the problem go away?  That is, is
something related to GSO/TSO at the root of the problem?


Thanks

Tim Hartrick

PID: 0      TASK: ffff880bff2e5b80  CPU: 2   COMMAND: "kworker/0:1"
 #0 [ffff880c2fc23580] machine_kexec at ffffffff81032b49
 #1 [ffff880c2fc235f0] crash_kexec at ffffffff810ac042
 #2 [ffff880c2fc236c0] oops_end at ffffffff815d6338
 #3 [ffff880c2fc236f0] die at ffffffff8100fd0b
 #4 [ffff880c2fc23720] do_trap at ffffffff815d5c14
 #5 [ffff880c2fc23780] do_invalid_op at ffffffff8100d9a5
 #6 [ffff880c2fc23820] invalid_op at ffffffff8100ccdb
    [exception RIP: tcp_fragment+818]
    RIP: ffffffff8152fac2  RSP: ffff880c2fc238d0  RFLAGS: 00010287
    RAX: 0000000000000007  RBX: ffff880b35f10000  RCX: 00000000000005b0
    RDX: 00000000000027d0  RSI: ffff880b35f10000  RDI: ffff88084946ce00
    RBP: ffff880c2fc23920   R8: 00000000000027d0   R9: 00000000a5041694
    R10: dead000000200200  R11: 0000000000000000  R12: 0000000000002230
    R13: ffff88084946ce00  R14: 0000000000000016  R15: 0000000000000000
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
 #7 [ffff880c2fc23928] tcp_mark_head_lost at ffffffff815254f6
 #8 [ffff880c2fc23978] tcp_update_scoreboard at ffffffff8152560b
 #9 [ffff880c2fc23998] tcp_fastretrans_alert at ffffffff8152a5ca
#10 [ffff880c2fc239e8] tcp_ack at ffffffff8152c464
#11 [ffff880c2fc23a58] tcp_rcv_established at ffffffff8152d1b0
#12 [ffff880c2fc23aa8] tcp_v4_do_rcv at ffffffff815353b5
#13 [ffff880c2fc23ad8] tcp_v4_rcv at ffffffff81536ba9
#14 [ffff880c2fc23b58] ip_local_deliver_finish at ffffffff8151372d
#15 [ffff880c2fc23b88] ip_local_deliver at ffffffff81513960
#16 [ffff880c2fc23bb8] ip_rcv_finish at ffffffff81512f31
#17 [ffff880c2fc23be8] ip_rcv at ffffffff8151357d
#18 [ffff880c2fc23c28] __netif_receive_skb at ffffffff814dd24a
#19 [ffff880c2fc23ca8] netif_receive_skb at ffffffff814e2910
#20 [ffff880c2fc23ce8] napi_skb_finish at ffffffff814e2a70
#21 [ffff880c2fc23d08] napi_gro_receive at ffffffff814e2f05
#22 [ffff880c2fc23d28] bnx2_rx_int at ffffffffa013866a
#23 [ffff880c2fc23df8] bnx2_poll_work at ffffffffa0138b10
#24 [ffff880c2fc23e28] bnx2_poll_msix at ffffffffa0138b7d
#25 [ffff880c2fc23e68] net_rx_action at ffffffff814e30e8
#26 [ffff880c2fc23ec8] __do_softirq at ffffffff8106beeb
#27 [ffff880c2fc23f38] call_softirq at ffffffff8100cf5c
#28 [ffff880c2fc23f50] do_softirq at ffffffff8100e9c5
#29 [ffff880c2fc23f70] irq_exit at ffffffff8106bdb5
#30 [ffff880c2fc23f80] do_IRQ at ffffffff815dcf66
--- <IRQ stack> ---
#31 [ffff880bff2efda0] ret_from_intr at ffffffff815d5393
    RIP: ffffffffffffff73  RSP: 0000000000000202  RFLAGS: 00000010
    RAX: 00000000fffffffd  RBX: ffff880bff2efea8  RCX: 0000000000000000
    RDX: 0000000000000000  RSI: 0000000000000489  RDI: 0000000000000000
    RBP: ffffffff815d538e   R8: 0000000000000320   R9: 0000000000000001
    R10: 0000000000000000  R11: ffff88019462adc0  R12: ffff880bff2efe18
    R13: ffffffff81051f50  R14: ffff880bff2efdc8  R15: ffffffff812de426
    ORIG_RAX: 000000000011bae9  CS: ffffffff81332a71  SS: ffff880bff2efe58
