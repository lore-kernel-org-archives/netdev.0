From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: suspicious RCU usage at ./include/net/sock.h:LINE
Date: Fri, 27 Oct 2017 10:28:10 +0200
Message-ID: <CACT4Y+YQqHnhMV8HmXztYq0eRs-tLdKpeMACTZOHB09j+MYTKA@mail.gmail.com>
References: <001a1143e7dcd82cd1055c830255@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Eric Biggers <ebiggers@google.com>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        john.fastabend@gmail.com, LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, syzkaller-bugs@googlegroups.com,
        tom@quantonium.net, Cong Wang <xiyou.wangcong@gmail.com>
To: syzbot
        <bot+499748b067346b9d6b17edd41668a75c0544ec46@syzkaller.appspotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:45374 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752140AbdJ0I2b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 04:28:31 -0400
Received: by mail-io0-f193.google.com with SMTP id i38so11088923iod.2
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 01:28:31 -0700 (PDT)
In-Reply-To: <001a1143e7dcd82cd1055c830255@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 27, 2017 at 10:24 AM, syzbot
<bot+499748b067346b9d6b17edd41668a75c0544ec46@syzkaller.appspotmail.com>
wrote:
> Hello,
>
> syzkaller hit the following crash on
> c6be5a0e3cebc145127d46a58350e05d2bcf6323
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.


We've seen this one only once and there is no reproducer. So if you
don't see how this could happen in the code, we can write it off as
invalid report. If you agree, please reply with "#syz invalid" (from
new line).
Thanks


> =============================
> WARNING: suspicious RCU usage
> 4.13.0-next-20170907+ #17 Not tainted
> -----------------------------
> sctp: [Deprecated]: syz-executor3 (pid 4299) Use of struct sctp_assoc_value
> in delayed_ack socket option.
> Use struct sctp_sack_info instead
> ------------[ cut here ]------------
> WARNING: CPU: 0 PID: 4316 at ./include/net/sock.h:1505 sock_owned_by_me
> include/net/sock.h:1505 [inline]
> WARNING: CPU: 0 PID: 4316 at ./include/net/sock.h:1505 sock_owned_by_user
> include/net/sock.h:1511 [inline]
> WARNING: CPU: 0 PID: 4316 at ./include/net/sock.h:1505
> strp_data_ready+0x2b7/0x390 net/strparser/strparser.c:404
> Kernel panic - not syncing: panic_on_warn set ...
>
> CPU: 0 PID: 4316 Comm: syz-executor4 Not tainted 4.13.0-next-20170907+ #17
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x194/0x257 lib/dump_stack.c:52
>  panic+0x1e4/0x417 kernel/panic.c:181
>  __warn+0x1c4/0x1d9 kernel/panic.c:542
>  report_bug+0x211/0x2d0 lib/bug.c:183
>  fixup_bug+0x40/0x90 arch/x86/kernel/traps.c:178
>  do_trap_no_signal arch/x86/kernel/traps.c:212 [inline]
>  do_trap+0x260/0x390 arch/x86/kernel/traps.c:261
>  do_error_trap+0x120/0x390 arch/x86/kernel/traps.c:298
>  do_invalid_op+0x1b/0x20 arch/x86/kernel/traps.c:311
>  invalid_op+0x18/0x20 arch/x86/entry/entry_64.S:905
> RIP: 0010:sock_owned_by_me include/net/sock.h:1505 [inline]
> RIP: 0010:sock_owned_by_user include/net/sock.h:1511 [inline]
> RIP: 0010:strp_data_ready+0x2b7/0x390 net/strparser/strparser.c:404
> RSP: 0018:ffff8801d9a37980 EFLAGS: 00010216
> RAX: 0000000000010000 RBX: ffff8801d9ab7748 RCX: ffffc90003ef3000
> RDX: 00000000000001ef RSI: ffffffff846b14c7 RDI: ffffffff85cc1020
> RBP: ffff8801d9a379a0 R08: 0000000000000000 R09: 0000000000000001
> R10: ffff8801d9a37120 R11: ffffffff8705fca0 R12: ffff8801d8e7a000
> R13: ffff8801d9ab7750 R14: ffff8801d9a37b08 R15: ffff8801d8e7a000
>  psock_data_ready+0x56/0x70 net/kcm/kcmsock.c:353
>  unix_dgram_sendmsg+0xa77/0x1600 net/unix/af_unix.c:1808
>  unix_seqpacket_sendmsg+0xf3/0x160 net/unix/af_unix.c:2062
>  sock_sendmsg_nosec net/socket.c:633 [inline]
>  sock_sendmsg+0xca/0x110 net/socket.c:643
>  sock_write_iter+0x320/0x5e0 net/socket.c:912
>  call_write_iter include/linux/fs.h:1744 [inline]
>  new_sync_write fs/read_write.c:457 [inline]
>  __vfs_write+0x68a/0x970 fs/read_write.c:470
>  vfs_write+0x18f/0x510 fs/read_write.c:518
>  SYSC_write fs/read_write.c:565 [inline]
>  SyS_write+0xef/0x220 fs/read_write.c:557
>  entry_SYSCALL_64_fastpath+0x1f/0xbe
> RIP: 0033:0x451e59
> RSP: 002b:00007f370bc06c08 EFLAGS: 00000216 ORIG_RAX: 0000000000000001
> RAX: ffffffffffffffda RBX: 0000000000718160 RCX: 0000000000451e59
> RDX: 000000000000009a RSI: 0000000020ef4000 RDI: 0000000000000005
> RBP: 0000000000000082 R08: 0000000000000000 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000216 R12: 00000000004bda78
> R13: 00000000ffffffff R14: 000000000000001b R15: 0000000000000006
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Kernel Offset: disabled
> Rebooting in 86400 seconds..
>
>
> ---
> This bug is generated by a dumb bot. It may contain errors.
> See https://goo.gl/tpsmEJ for details.
> Direct all questions to syzkaller@googlegroups.com.
>
> syzbot will keep track of this bug report.
> Once a fix for this bug is committed, please reply to this email with:
> #syz fix: exact-commit-title
> To mark this as a duplicate of another syzbot report, please reply with:
> #syz dup: exact-subject-of-another-report
> If it's a one-off invalid bug report, please reply with:
> #syz invalid
> Note: if the crash happens again, it will cause creation of a new bug
> report.
>
> --
> You received this message because you are subscribed to the Google Groups
> "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an
> email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit
> https://groups.google.com/d/msgid/syzkaller-bugs/001a1143e7dcd82cd1055c830255%40google.com.
> For more options, visit https://groups.google.com/d/optout.
