From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: [4.10+] sctp lockdep trace
Date: Tue, 14 Mar 2017 12:20:06 -0400
Message-ID: <20170314162006.bg2wttwr45haxwok@codemonkey.org.uk>
References: <20170224222110.csrufaq73lq3twy2@codemonkey.org.uk>
 <20170313201045.GA23552@localhost.localdomain>
 <20170313201156.GA23553@localhost.localdomain>
 <CADvbK_fr5dis-X8znOtjDFqFrDWcK+RcDD8rz=oNidrJJ1h0+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        linux-sctp@vger.kernel.org
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from scorn.kernelslacker.org ([45.56.101.199]:33076 "EHLO
        scorn.kernelslacker.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751073AbdCNQUI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 12:20:08 -0400
Content-Disposition: inline
In-Reply-To: <CADvbK_fr5dis-X8znOtjDFqFrDWcK+RcDD8rz=oNidrJJ1h0+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 14, 2017 at 11:35:33AM +0800, Xin Long wrote:
 > >> > [  245.416594]  (
 > >> > [  245.424928] sk_lock-AF_INET
 > >> > [  245.433279] ){+.+.+.}
 > >> > [  245.441889] , at: [<ffffffffa0302fd0>] sctp_sendmsg+0x330/0xfe0 [sctp]
 > >> > [  245.450167]
 > >> >                stack backtrace:
 > >> > [  245.466352] CPU: 3 PID: 1781 Comm: trinity-c30 Not tainted 4.10.0-think+ #7
 > >> > [  245.482894] Call Trace:
 > >> > [  245.491096]  dump_stack+0x68/0x93
 > >> > [  245.499314]  lockdep_rcu_suspicious+0xce/0xf0
 > >> > [  245.507610]  sctp_hash_transport+0x6c0/0x7e0 [sctp]
 > >> > [  245.515972]  ? sctp_endpoint_bh_rcv+0x171/0x290 [sctp]
 > >> > [  245.524366]  sctp_assoc_add_peer+0x290/0x3c0 [sctp]
 > >> > [  245.532736]  sctp_sendmsg+0x8f7/0xfe0 [sctp]
 > >> > [  245.541040]  ? rw_copy_check_uvector+0x8e/0x190
 > >> > [  245.549402]  ? import_iovec+0x3a/0xe0
 > >> > [  245.557679]  inet_sendmsg+0x49/0x1e0
 > >> > [  245.565887]  ___sys_sendmsg+0x2d4/0x300
 > >> > [  245.574092]  ? debug_smp_processor_id+0x17/0x20
 > >> > [  245.582342]  ? debug_smp_processor_id+0x17/0x20
 > >> > [  245.590508]  ? get_lock_stats+0x19/0x50
 > >> > [  245.598641]  __sys_sendmsg+0x54/0x90
 > >> > [  245.606745]  SyS_sendmsg+0x12/0x20
 > >> > [  245.614784]  do_syscall_64+0x66/0x1d0
 > >> > [  245.622828]  entry_SYSCALL64_slow_path+0x25/0x25
 > >> > [  245.630894] RIP: 0033:0x7fe095fcb0f9
 > >> > [  245.638962] RSP: 002b:00007ffc5601b1d8 EFLAGS: 00000246
 > >> > [  245.647071]  ORIG_RAX: 000000000000002e
 > >> > [  245.655186] RAX: ffffffffffffffda RBX: 000000000000002e RCX: 00007fe095fcb0f9
 > >> > [  245.663435] RDX: 0000000000000080 RSI: 00005592de12ddc0 RDI: 000000000000012d
 > >> > [  245.671776] RBP: 00007fe0965c8000 R08: 000000000000c000 R09: 00000000000000dc
 > >> > [  245.680111] R10: 0003021200000088 R11: 0000000000000246 R12: 0000000000000002
 > >> > [  245.688460] R13: 00007fe0965c8048 R14: 00007fe0966a1ad8 R15: 00007fe0965c8000
 > >> >
 > >>
 > >> Cc'ing Xin and linux-sctp@ mailing list.
 > >
 > > Seems the same as Andrey Konovalov had reported?
 > >
 > I would think so, this patch has fixed it:
 > 
 > commit 5179b26694c92373275e4933f5d0ff32d585c675
 > Author: Xin Long <lucien.xin@gmail.com>
 > Date:   Tue Feb 28 12:41:29 2017 +0800
 > 
 >     sctp: call rcu_read_lock before checking for duplicate transport nodes
 > 
 > not sure which commit your tests are based on, Dave, can you
 > check if this fix has been in your test kernel?

Haven't seen this in a while. Let's call it fixed.

	Dave
