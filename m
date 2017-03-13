From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [4.10+] sctp lockdep trace
Date: Mon, 13 Mar 2017 17:10:45 -0300
Message-ID: <20170313201045.GA23552@localhost.localdomain>
References: <20170224222110.csrufaq73lq3twy2@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        Xin Long <lucien.xin@gmail.com>
To: Dave Jones <davej@codemonkey.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60826 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752521AbdCMUKu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Mar 2017 16:10:50 -0400
Content-Disposition: inline
In-Reply-To: <20170224222110.csrufaq73lq3twy2@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 24, 2017 at 05:21:10PM -0500, Dave Jones wrote:
> [  244.251557] ===============================
> [  244.263321] [ ERR: suspicious RCU usage.  ]
> [  244.274982] 4.10.0-think+ #7 Not tainted
> [  244.286511] -------------------------------
> [  244.298008] ./include/linux/rhashtable.h:602 suspicious rcu_dereference_check() usage!
> [  244.309665] 
>                other info that might help us debug this:
> 
> [  244.344629] 
>                rcu_scheduler_active = 2, debug_locks = 1
> [  244.367839] 1 lock held by trinity-c30/1781:
> [  244.379481]  #0: 
> [  244.390848]  (
> [  244.402372] sk_lock-AF_INET
> [  244.413825] ){+.+.+.}
> [  244.425231] , at: [<ffffffffa0302fd0>] sctp_sendmsg+0x330/0xfe0 [sctp]
> [  244.436774] 
>                stack backtrace:
> [  244.459620] CPU: 3 PID: 1781 Comm: trinity-c30 Not tainted 4.10.0-think+ #7 
> [  244.482790] Call Trace:
> [  244.494201]  dump_stack+0x68/0x93
> [  244.505598]  lockdep_rcu_suspicious+0xce/0xf0
> [  244.516924]  sctp_hash_transport+0x406/0x7e0 [sctp]
> [  244.528137]  ? sctp_endpoint_bh_rcv+0x171/0x290 [sctp]
> [  244.539243]  sctp_assoc_add_peer+0x290/0x3c0 [sctp]
> [  244.550291]  sctp_sendmsg+0x8f7/0xfe0 [sctp]
> [  244.561258]  ? rw_copy_check_uvector+0x8e/0x190
> [  244.572308]  ? import_iovec+0x3a/0xe0
> [  244.583232]  inet_sendmsg+0x49/0x1e0
> [  244.594150]  ___sys_sendmsg+0x2d4/0x300
> [  244.605002]  ? debug_smp_processor_id+0x17/0x20
> [  244.615844]  ? debug_smp_processor_id+0x17/0x20
> [  244.626533]  ? get_lock_stats+0x19/0x50
> [  244.637141]  __sys_sendmsg+0x54/0x90
> [  244.647817]  SyS_sendmsg+0x12/0x20
> [  244.658400]  do_syscall_64+0x66/0x1d0
> [  244.668990]  entry_SYSCALL64_slow_path+0x25/0x25
> [  244.679582] RIP: 0033:0x7fe095fcb0f9
> [  244.690079] RSP: 002b:00007ffc5601b1d8 EFLAGS: 00000246
> [  244.700704]  ORIG_RAX: 000000000000002e
> [  244.711248] RAX: ffffffffffffffda RBX: 000000000000002e RCX: 00007fe095fcb0f9
> [  244.721818] RDX: 0000000000000080 RSI: 00005592de12ddc0 RDI: 000000000000012d
> [  244.732282] RBP: 00007fe0965c8000 R08: 000000000000c000 R09: 00000000000000dc
> [  244.742576] R10: 0003021200000088 R11: 0000000000000246 R12: 0000000000000002
> [  244.752804] R13: 00007fe0965c8048 R14: 00007fe0966a1ad8 R15: 00007fe0965c8000
> 
> [  244.775549] ===============================
> [  244.785875] [ ERR: suspicious RCU usage.  ]
> [  244.796951] 4.10.0-think+ #7 Not tainted
> [  244.807185] -------------------------------
> [  244.819213] ./include/linux/rhashtable.h:605 suspicious rcu_dereference_check() usage!
> [  244.829420] 
>                other info that might help us debug this:
> 
> [  244.859963] 
>                rcu_scheduler_active = 2, debug_locks = 1
> [  244.879766] 1 lock held by trinity-c30/1781:
> [  244.889953]  #0: 
> [  244.900000]  (
> [  244.909854] sk_lock-AF_INET
> [  244.919645] ){+.+.+.}
> [  244.929238] , at: [<ffffffffa0302fd0>] sctp_sendmsg+0x330/0xfe0 [sctp]
> [  244.939167] 
>                stack backtrace:
> [  244.958506] CPU: 3 PID: 1781 Comm: trinity-c30 Not tainted 4.10.0-think+ #7 
> [  244.978102] Call Trace:
> [  244.987735]  dump_stack+0x68/0x93
> [  244.997112]  lockdep_rcu_suspicious+0xce/0xf0
> [  245.006588]  sctp_hash_transport+0x4ca/0x7e0 [sctp]
> [  245.016264]  ? sctp_endpoint_bh_rcv+0x171/0x290 [sctp]
> [  245.025797]  sctp_assoc_add_peer+0x290/0x3c0 [sctp]
> [  245.035380]  sctp_sendmsg+0x8f7/0xfe0 [sctp]
> [  245.044883]  ? rw_copy_check_uvector+0x8e/0x190
> [  245.054464]  ? import_iovec+0x3a/0xe0
> [  245.064016]  inet_sendmsg+0x49/0x1e0
> [  245.073516]  ___sys_sendmsg+0x2d4/0x300
> [  245.082967]  ? debug_smp_processor_id+0x17/0x20
> [  245.092448]  ? debug_smp_processor_id+0x17/0x20
> [  245.101850]  ? get_lock_stats+0x19/0x50
> [  245.111170]  __sys_sendmsg+0x54/0x90
> [  245.120451]  SyS_sendmsg+0x12/0x20
> [  245.129649]  do_syscall_64+0x66/0x1d0
> [  245.138783]  entry_SYSCALL64_slow_path+0x25/0x25
> [  245.147678] RIP: 0033:0x7fe095fcb0f9
> [  245.156588] RSP: 002b:00007ffc5601b1d8 EFLAGS: 00000246
> [  245.165503]  ORIG_RAX: 000000000000002e
> [  245.174601] RAX: ffffffffffffffda RBX: 000000000000002e RCX: 00007fe095fcb0f9
> [  245.183861] RDX: 0000000000000080 RSI: 00005592de12ddc0 RDI: 000000000000012d
> [  245.193038] RBP: 00007fe0965c8000 R08: 000000000000c000 R09: 00000000000000dc
> [  245.202214] R10: 0003021200000088 R11: 0000000000000246 R12: 0000000000000002
> [  245.211261] R13: 00007fe0965c8048 R14: 00007fe0966a1ad8 R15: 00007fe0965c8000
> 
> [  245.308216] ===============================
> [  245.317295] [ ERR: suspicious RCU usage.  ]
> [  245.327876] 4.10.0-think+ #7 Not tainted
> [  245.337065] -------------------------------
> [  245.345840] ./include/linux/rhashtable.h:616 suspicious rcu_dereference_check() usage!
> [  245.356501] 
>                other info that might help us debug this:
> 
> [  245.382185] 
>                rcu_scheduler_active = 2, debug_locks = 1
> [  245.399415] 1 lock held by trinity-c30/1781:
> [  245.408138]  #0: 
> [  245.416594]  (
> [  245.424928] sk_lock-AF_INET
> [  245.433279] ){+.+.+.}
> [  245.441889] , at: [<ffffffffa0302fd0>] sctp_sendmsg+0x330/0xfe0 [sctp]
> [  245.450167] 
>                stack backtrace:
> [  245.466352] CPU: 3 PID: 1781 Comm: trinity-c30 Not tainted 4.10.0-think+ #7 
> [  245.482894] Call Trace:
> [  245.491096]  dump_stack+0x68/0x93
> [  245.499314]  lockdep_rcu_suspicious+0xce/0xf0
> [  245.507610]  sctp_hash_transport+0x6c0/0x7e0 [sctp]
> [  245.515972]  ? sctp_endpoint_bh_rcv+0x171/0x290 [sctp]
> [  245.524366]  sctp_assoc_add_peer+0x290/0x3c0 [sctp]
> [  245.532736]  sctp_sendmsg+0x8f7/0xfe0 [sctp]
> [  245.541040]  ? rw_copy_check_uvector+0x8e/0x190
> [  245.549402]  ? import_iovec+0x3a/0xe0
> [  245.557679]  inet_sendmsg+0x49/0x1e0
> [  245.565887]  ___sys_sendmsg+0x2d4/0x300
> [  245.574092]  ? debug_smp_processor_id+0x17/0x20
> [  245.582342]  ? debug_smp_processor_id+0x17/0x20
> [  245.590508]  ? get_lock_stats+0x19/0x50
> [  245.598641]  __sys_sendmsg+0x54/0x90
> [  245.606745]  SyS_sendmsg+0x12/0x20
> [  245.614784]  do_syscall_64+0x66/0x1d0
> [  245.622828]  entry_SYSCALL64_slow_path+0x25/0x25
> [  245.630894] RIP: 0033:0x7fe095fcb0f9
> [  245.638962] RSP: 002b:00007ffc5601b1d8 EFLAGS: 00000246
> [  245.647071]  ORIG_RAX: 000000000000002e
> [  245.655186] RAX: ffffffffffffffda RBX: 000000000000002e RCX: 00007fe095fcb0f9
> [  245.663435] RDX: 0000000000000080 RSI: 00005592de12ddc0 RDI: 000000000000012d
> [  245.671776] RBP: 00007fe0965c8000 R08: 000000000000c000 R09: 00000000000000dc
> [  245.680111] R10: 0003021200000088 R11: 0000000000000246 R12: 0000000000000002
> [  245.688460] R13: 00007fe0965c8048 R14: 00007fe0966a1ad8 R15: 00007fe0965c8000
> 

Cc'ing Xin and linux-sctp@ mailing list.
