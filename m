From: Dave Jones <davej@redhat.com>
Subject: BUG: using __this_cpu_add() in preemptible code (sctp)
Date: Tue, 5 Aug 2014 09:41:15 -0400
Message-ID: <20140805134115.GA25110@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9945 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752020AbaHENlW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2014 09:41:22 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s75DfMKI013906
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 5 Aug 2014 09:41:22 -0400
Received: from gelk.kernelslacker.org (ovpn-113-45.phx2.redhat.com [10.3.113.45])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s75DfGBE015085
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 5 Aug 2014 09:41:21 -0400
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.8/8.14.7) with ESMTP id s75DfF48025116
	for <netdev@vger.kernel.org>; Tue, 5 Aug 2014 09:41:15 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.8/8.14.8/Submit) id s75DfF3A025115
	for netdev@vger.kernel.org; Tue, 5 Aug 2014 09:41:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BUG: using __this_cpu_add() in preemptible [00000000] code: trinity-c117/14551
caller is __this_cpu_preempt_check+0x13/0x20
CPU: 3 PID: 14551 Comm: trinity-c117 Not tainted 3.16.0+ #33
 ffffffff9ec898f0 0000000047ea7e23 ffff88022d32f7f0 ffffffff9e7ee207
 0000000000000003 ffff88022d32f818 ffffffff9e397eaa ffff88023ee70b40
 ffff88022d32f970 ffff8801c026d580 ffff88022d32f828 ffffffff9e397ee3
Call Trace:
 [<ffffffff9e7ee207>] dump_stack+0x4e/0x7a
 [<ffffffff9e397eaa>] check_preemption_disabled+0xfa/0x100
 [<ffffffff9e397ee3>] __this_cpu_preempt_check+0x13/0x20
 [<ffffffffc0839872>] sctp_packet_transmit+0x692/0x710 [sctp]
 [<ffffffffc082a7f2>] sctp_outq_flush+0x2a2/0xc30 [sctp]
 [<ffffffff9e0d985c>] ? mark_held_locks+0x7c/0xb0
 [<ffffffff9e7f8c6d>] ? _raw_spin_unlock_irqrestore+0x5d/0x80
 [<ffffffffc082b99a>] sctp_outq_uncork+0x1a/0x20 [sctp]
 [<ffffffffc081e112>] sctp_cmd_interpreter.isra.23+0x1142/0x13f0 [sctp]
 [<ffffffffc081c86b>] sctp_do_sm+0xdb/0x330 [sctp]
 [<ffffffff9e0b8f1b>] ? preempt_count_sub+0xab/0x100
 [<ffffffffc083b350>] ? sctp_cname+0x70/0x70 [sctp]
 [<ffffffffc08389ca>] sctp_primitive_ASSOCIATE+0x3a/0x50 [sctp]
 [<ffffffffc083358f>] sctp_sendmsg+0x88f/0xe30 [sctp]
 [<ffffffff9e0d673a>] ? lock_release_holdtime.part.28+0x9a/0x160
 [<ffffffff9e0d62ce>] ? put_lock_stats.isra.27+0xe/0x30
 [<ffffffff9e73b624>] inet_sendmsg+0x104/0x220
 [<ffffffff9e73b525>] ? inet_sendmsg+0x5/0x220
 [<ffffffff9e68ac4e>] sock_sendmsg+0x9e/0xe0
 [<ffffffff9e1c0c09>] ? might_fault+0xb9/0xc0
 [<ffffffff9e1c0bae>] ? might_fault+0x5e/0xc0
 [<ffffffff9e68b234>] SYSC_sendto+0x124/0x1c0
 [<ffffffff9e0136b0>] ? syscall_trace_enter+0x250/0x330
 [<ffffffff9e68c3ce>] SyS_sendto+0xe/0x10
 [<ffffffff9e7f9be4>] tracesys+0xdd/0xe2
